import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../core/utils/code_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/image_url_helper.dart';
import '../../domain/entities/voucher.dart';
import '../features/purchase/bloc/purchase_bloc.dart';
import '../features/purchase/bloc/purchase_event.dart';
import '../features/purchase/bloc/purchase_state.dart';
import '../widgets/common/app_widgets.dart';
import '../widgets/animations/custom_loader.dart';
import '../widgets/animations/fade_in_widget.dart';
import '../widgets/animations/scale_tap_widget.dart';
import 'purchase_detail_page.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  @override
  void initState() {
    super.initState();
    context.read<PurchaseBloc>().add(const LoadPurchasesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).myCoupons),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PurchaseBloc>().add(const LoadPurchasesEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<PurchaseBloc, PurchaseState>(
        builder: (context, state) {
          if (state is PurchaseLoading) {
            return const Center(child: AppLoader());
          } else if (state is PurchasesLoaded) {
            if (state.purchases.isEmpty) {
              return AppEmptyStateWidget(
                message: l10n.noPurchasesFound,
                icon: Icons.shopping_bag_outlined,
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PurchaseBloc>().add(const LoadPurchasesEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.purchases.length,
                itemBuilder: (context, index) {
                  final purchase = state.purchases[index];
                  return FadeInWidget(
                    delay: 0.05 * index,
                    child: _buildPurchaseItem(context, purchase),
                  );
                },
              ),
            );
          } else if (state is PurchaseError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<PurchaseBloc>().add(const LoadPurchasesEvent());
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPurchaseItem(BuildContext context, Purchase purchase) {
    final l10n = AppLocalizations.of(context);
    final sanitizedCode = sanitizedVoucherCode(purchase.redeemCode ?? purchase.qrCode);
    final codeForDisplay =
        sanitizedCode.isEmpty ? purchase.qrCode ?? 'N/A' : sanitizedCode;
    final statusColor = _getStatusColor(purchase.status);
    // Value paid: coins or CFA — never the wallet's raw 'USD' currency code.
    String valueLabel;
    Color valueColor;
    if (purchase.amountMinor > 0) {
      valueLabel = '${purchase.amountMinor.toInt()} CFA';
      valueColor = AppTheme.primaryTurquoise;
    } else if ((purchase.coinAmount ?? 0) > 0) {
      valueLabel = '${purchase.coinAmount!.toInt()} ${l10n.coins}';
      valueColor = AppTheme.primaryOrange;
    } else {
      valueLabel = l10n.free;
      valueColor = Colors.green;
    }

    return ScaleTapWidget(
      onTap: () async {
        final bloc = context.read<PurchaseBloc>();
        final navigator = Navigator.of(context);
        await navigator.push<bool>(
          MaterialPageRoute(
            builder: (context) => PurchaseDetailPage(purchaseId: purchase.id),
          ),
        );
        if (!mounted) return;
        bloc.add(const LoadPurchasesEvent());
      },
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: (purchase.voucherDetails?.imageUrl != null)
                      ? Image.network(
                          ImageUrlHelper.buildImageUrl(
                              purchase.voucherDetails!.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _purchaseImageFallback(),
                        )
                      : _purchaseImageFallback(),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.45)
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2), blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      _getStatusText(purchase.status, l10n),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if ((purchase.voucherDetails?.discountValue ?? 0) > 0)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 6),
                        ],
                      ),
                      child: Text(
                        '-${purchase.voucherDetails!.discountValue.toInt()}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    purchase.voucherTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: valueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: valueColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                            purchase.amountMinor > 0
                                ? Icons.payments
                                : Icons.monetization_on,
                            size: 15,
                            color: valueColor),
                        const SizedBox(width: 6),
                        Text(valueLabel,
                            style: TextStyle(
                                fontSize: 14,
                                color: valueColor,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.confirmation_number,
                            size: 16, color: AppTheme.primaryOrange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            codeForDisplay,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: codeForDisplay));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${l10n.code} ✓'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.copy,
                                size: 16, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 15, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        '${l10n.purchasedOn}: ${_formatDate(purchase.purchaseDate)}',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _purchaseImageFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryOrange, AppTheme.primaryTurquoise],
        ),
      ),
      child: const Center(
        child: Icon(Icons.local_offer, color: Colors.white, size: 44),
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
