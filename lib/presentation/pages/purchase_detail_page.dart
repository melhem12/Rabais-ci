import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../domain/entities/voucher.dart';
import '../../core/utils/code_formatter.dart';
import '../features/purchase/bloc/purchase_bloc.dart';
import '../features/purchase/bloc/purchase_event.dart';
import '../features/purchase/bloc/purchase_state.dart';
import '../widgets/common/app_widgets.dart';
import '../widgets/animations/custom_loader.dart';

class PurchaseDetailPage extends StatefulWidget {
  final String purchaseId;

  const PurchaseDetailPage({
    super.key,
    required this.purchaseId,
  });

  @override
  State<PurchaseDetailPage> createState() => _PurchaseDetailPageState();
}

class _PurchaseDetailPageState extends State<PurchaseDetailPage> {
  String? _qrCode;
  Purchase? _cachedPurchase; // Cache purchase to prevent losing it during state changes

  @override
  void initState() {
    super.initState();
    // Load purchase detail immediately
    context.read<PurchaseBloc>().add(LoadPurchaseDetailEvent(widget.purchaseId));
    // Only load QR code separately if it's not in the purchase detail response
    // The purchase detail response should already include qr_code/qr_payload
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.purchaseDetails),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<PurchaseBloc>().add(LoadPurchaseDetailEvent(widget.purchaseId));
                context.read<PurchaseBloc>().add(LoadPurchaseQrCodeEvent(widget.purchaseId));
              },
            ),
          ],
        ),
        body: BlocListener<PurchaseBloc, PurchaseState>(
          listener: (context, state) {
            if (!mounted) return;
            // Update QR code from any state that might contain it
            if (state is PurchaseDetailLoaded) {
              // Cache the purchase to prevent losing it during state changes
              _cachedPurchase = state.purchase;
              // Purchase details loaded, QR code might be in the purchase object
              if (state.purchase.qrPayload != null || state.purchase.qrCode != null) {
                setState(() {
                  _qrCode = state.purchase.qrPayload ?? state.purchase.qrCode;
                });
              }
            } else if (state is PurchaseQrCodeLoaded) {
              // QR code loaded separately - update QR code but keep cached purchase
              setState(() {
                _qrCode = state.qrCode;
              });
            }
          },
          child: BlocBuilder<PurchaseBloc, PurchaseState>(
            builder: (context, state) {
              // If we have cached purchase, always show it (even if state changes temporarily)
              if (_cachedPurchase != null) {
                return _buildPurchaseDetail(context, _cachedPurchase!);
              }

              // Show loading state if we're loading or if state is initial (waiting for data)
              if (state is PurchaseLoading || state is PurchaseInitial) {
                return const Center(child: AppLoader());
              } else if (state is PurchaseDetailLoaded) {
                // Cache the purchase
                _cachedPurchase = state.purchase;
                return _buildPurchaseDetail(context, state.purchase);
              } else if (state is PurchaseError) {
                return AppErrorWidget(
                  message: state.message,
                  onRetry: () {
                    _cachedPurchase = null; // Clear cache on retry
                    context.read<PurchaseBloc>().add(LoadPurchaseDetailEvent(widget.purchaseId));
                    context.read<PurchaseBloc>().add(LoadPurchaseQrCodeEvent(widget.purchaseId));
                  },
                );
              }
              // If state is not recognized, show loading (might be transitioning)
                return const Center(child: AppLoader());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseDetail(BuildContext context, Purchase purchase) {
    final l10n = AppLocalizations.of(context);
    final displayCode = sanitizedVoucherCode(purchase.redeemCode ?? purchase.qrCode ?? _qrCode);
    final displayCodeText = displayCode.isEmpty
        ? (purchase.redeemCode ?? purchase.qrCode ?? _qrCode ?? 'N/A')
        : displayCode;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Voucher Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    purchase.voucherTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${purchase.amount.toInt()} ${purchase.currency}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(purchase.status),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getStatusText(purchase.status, l10n),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // QR Code Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.qrCode,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: (purchase.qrPayload ?? purchase.qrCode ?? _qrCode) != null
                          ? QrImageView(
                              data: purchase.qrPayload ?? purchase.qrCode ?? _qrCode ?? '',
                              version: QrVersions.auto,
                              size: 200.0,
                            )
                          : const AppLoader(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      displayCodeText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      l10n.showQrToMerchant,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Purchase Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.purchaseDetails,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(l10n.code,
                      displayCode.isEmpty ? (purchase.qrCode ?? 'N/A') : displayCode),
                  _buildDetailRow(
                    l10n.purchasedOn,
                    _formatDate(purchase.purchaseDate),
                  ),
                  if (purchase.validUntil != null)
                    _buildDetailRow(
                      l10n.expiresOn,
                      _formatDate(purchase.validUntil!),
                    ),
                  _buildDetailRow(
                    l10n.amount,
                    '${purchase.amount.toInt()} ${purchase.currency}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'used':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'active':
        return l10n.active;
      case 'used':
        return l10n.used;
      case 'expired':
        return l10n.expired;
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
