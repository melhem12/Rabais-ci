import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../features/voucher/bloc/voucher_bloc.dart';
import '../features/voucher/bloc/voucher_event.dart';
import '../features/voucher/bloc/voucher_state.dart';
import '../features/wallet/bloc/wallet_bloc.dart';
import '../features/wallet/bloc/wallet_event.dart';
import '../features/wallet/bloc/wallet_state.dart';
import '../../domain/entities/voucher.dart';
import '../../domain/entities/business_options.dart';
import '../../data/datasources/business_remote_datasource.dart';
import '../../../core/utils/image_url_helper.dart';
import '../widgets/common/app_widgets.dart';
import '../widgets/payment_method_dialog.dart';
import '../../generated/l10n/app_localizations.dart';
import 'purchase_detail_page.dart';
import '../../core/utils/code_formatter.dart';
import '../../di/service_locator.dart';

/// Vouchers page
class VouchersPage extends StatefulWidget {
  final String? businessId; // Optional: filter vouchers by business ID
  final String? businessName; // Optional: business name for display

  const VouchersPage({super.key, this.businessId, this.businessName});

  @override
  State<VouchersPage> createState() => _VouchersPageState();
}

class _VouchersPageState extends State<VouchersPage> {
  final TextEditingController _searchController = TextEditingController();
  late final BusinessRemoteDataSource _businessRemoteDataSource;
  List<BusinessTypeOption> _businessTypeOptions = [];
  Map<String, String> _categoryNames = {};
  String? _selectedBusinessTypeId;
  bool _isLoadingBusinessTypes = false;
  String? _businessTypesError;
  DateTime? _expiresBefore;
  String? _sortBy; // 'price', 'expiration', 'value'
  bool _filtersChanged = false;

  @override
  void initState() {
    super.initState();
    _businessRemoteDataSource = getIt<BusinessRemoteDataSource>();
    // Load vouchers for the business if businessId is provided, otherwise load all vouchers
    if (widget.businessId != null) {
      context.read<VoucherBloc>().add(
        LoadBusinessVouchersEvent(widget.businessId!),
      );
    } else {
      context.read<VoucherBloc>().add(const LoadVouchersEvent());
      _loadBusinessTypes();
    }
  }

  Future<void> _loadBusinessTypes() async {
    if (widget.businessId != null) return;

    setState(() {
      _isLoadingBusinessTypes = true;
      _businessTypesError = null;
    });

    try {
      final categories = await _businessRemoteDataSource.getBusinessOptions();
      if (!mounted) return;

      final types = <BusinessTypeOption>[];
      final categoryNames = <String, String>{};

      for (final category in categories) {
        categoryNames[category.id] = category.name;
        types.addAll(category.types);
      }

      setState(() {
        _businessTypeOptions = types;
        _categoryNames = categoryNames;
        _isLoadingBusinessTypes = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingBusinessTypes = false;
        _businessTypesError = e.toString();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.businessFiltersLoadError)));
      });
    }
  }

  void _onBusinessTypeSelected(String? typeId) {
    if (widget.businessId != null) return;

    setState(() {
      _selectedBusinessTypeId = typeId;
      _filtersChanged = true;
    });
  }

  String? _currentSearchQuery() {
    final query = _searchController.text.trim();
    return query.isEmpty ? null : query;
  }

  void _onSortChanged(String? value) {
    setState(() {
      _sortBy = value;
      _filtersChanged = true;
    });
  }


  void _clearFilters() {
    setState(() {
      _selectedBusinessTypeId = null;
      _expiresBefore = null;
      _sortBy = null;
      _filtersChanged = false;
    });
    _reloadVouchers();
  }

  void _applyFilters() {
    setState(() {
      _filtersChanged = false;
    });
    _reloadVouchers();
  }

  void _reloadVouchers() {
    if (widget.businessId != null) {
      context.read<VoucherBloc>().add(
        LoadBusinessVouchersEvent(widget.businessId!),
      );
      return;
    }

    context.read<VoucherBloc>().add(
      LoadVouchersEvent(
        search: _currentSearchQuery(),
        businessTypeId: _selectedBusinessTypeId,
        expiresBefore: _expiresBefore?.toUtc().toIso8601String(),
      ),
    );
  }

  Widget _buildBusinessTypeFilters(AppLocalizations l10n) {
    if (_isLoadingBusinessTypes) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_businessTypesError != null && _businessTypeOptions.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          l10n.businessFiltersLoadError,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_businessTypeOptions.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l10n.businessFiltersTitle,
            style: theme.textTheme.labelLarge,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: Text(l10n.all),
              selected: _selectedBusinessTypeId == null,
              onSelected: (selected) {
                if (!selected) return;
                _onBusinessTypeSelected(null);
              },
            ),
            ..._businessTypeOptions.map((type) {
              final categoryName = _categoryNames[type.categoryId];
              final label = categoryName != null && categoryName.isNotEmpty
                  ? '${type.name} (${categoryName})'
                  : type.name;
              return FilterChip(
                label: Text(label),
                selected: _selectedBusinessTypeId == type.id,
                onSelected: (selected) {
                  _onBusinessTypeSelected(selected ? type.id : null);
                },
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildSortingDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      value: _sortBy,
      decoration: InputDecoration(
        labelText: 'Trier par', // Will be localized
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: const [
        DropdownMenuItem(value: 'price', child: Text('Prix')),
        DropdownMenuItem(value: 'expiration', child: Text('Date d\'expiration')),
        DropdownMenuItem(value: 'value', child: Text('Valeur')),
      ],
      onChanged: _onSortChanged,
    );
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<VoucherBloc, VoucherState>(
      listenWhen: (previous, current) {
        // Always listen to PurchaseSuccess and VoucherError
        // This ensures we catch purchase results even if they happen quickly
        return current is PurchaseSuccess || current is VoucherError;
      },
      listener: (context, state) {
        // Only handle purchase-related states, not loading states
        if (state is PurchaseSuccess) {
          // Check if this is a free voucher (no payment)
          final isFreeVoucher =
              state.purchase.amountMinor == 0 && state.purchase.coinAmount == 0;

          // Show success message immediately
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.purchaseSuccess),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }

          // For free vouchers, show QR code in a dialog instead of navigating
          if (isFreeVoucher) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (context.mounted) {
                _showQrCodeDialog(context, state.purchase);
              }
            });
          } else {
            // For paid vouchers, navigate to purchase detail page
            Future.delayed(const Duration(milliseconds: 300), () {
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PurchaseDetailPage(purchaseId: state.purchase.id),
                  ),
                );
              }
            });
          }

          // Reload vouchers to update remaining quantity (after a delay to ensure navigation completes)
          Future.delayed(const Duration(milliseconds: 800), () {
            if (!context.mounted) return;
            _reloadVouchers();

            // Reload wallet to update balance
            context.read<WalletBloc>().add(const LoadWalletEvent());
          });
        } else if (state is VoucherError) {
          // Show error message - check if this is from a purchase operation
          // (we can't distinguish easily, so show all errors but this might show loading errors too)
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.businessName ?? l10n.vouchers),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _reloadVouchers();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Search and Filter
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchVouchers,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (widget.businessId != null) return;
                      _reloadVouchers();
                    },
                  ),
                  if (widget.businessId == null) ...[
                    const SizedBox(height: 8),
                    // Compact filter section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBusinessTypeFilters(l10n),
                          const SizedBox(height: 8),
                          _buildSortingDropdown(l10n),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: _clearFilters,
                                child: Text(l10n.clearFilters),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _filtersChanged ? _applyFilters : null,
                                child: const Text('Appliquer'), // Will be localized
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Vouchers List
            Expanded(
              child: BlocBuilder<VoucherBloc, VoucherState>(
                builder: (context, state) {
                  if (state is VoucherLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is VouchersLoaded) {
                    if (state.vouchers.isEmpty) {
                      final l10n = AppLocalizations.of(context);
                      return Center(
                        child: Text(
                          l10n.noVouchersFound,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    // Sort vouchers based on selected sort option
                    final sortedVouchers = List<Voucher>.from(state.vouchers);
                    if (_sortBy != null) {
                      sortedVouchers.sort((a, b) {
                        switch (_sortBy) {
                          case 'price':
                            return (a.priceMinor + a.coinPrice).compareTo(b.priceMinor + b.coinPrice);
                          case 'expiration':
                            // Sort by remaining quantity (lower = expires sooner) as proxy for expiration
                            // In future, add expires_at field to Voucher entity
                            return a.remainingQuantity.compareTo(b.remainingQuantity);
                          case 'value':
                            // Sort by discount value (higher discount = better value)
                            return b.discountValue.compareTo(a.discountValue);
                          default:
                            return 0;
                        }
                      });
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sortedVouchers.length,
                      itemBuilder: (context, index) {
                        final voucher = sortedVouchers[index];
                        return _buildVoucherCard(context, voucher);
                      },
                    );
                  } else if (state is VoucherError) {
                    return AppErrorWidget(
                      message: state.message,
                      onRetry: _reloadVouchers,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherCard(BuildContext context, Voucher voucher) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showVoucherDetails(context, voucher),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Business Logo
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: voucher.imageUrl != null
                        ? NetworkImage(
                            ImageUrlHelper.buildImageUrl(voucher.imageUrl),
                          )
                        : null,
                    child: voucher.imageUrl == null
                        ? const Icon(Icons.local_offer)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          voucher.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          voucher.type == 'free' ? l10n.free : l10n.paid,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: voucher.status == 'active'
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      voucher.status == 'active' ? l10n.active : l10n.inactive,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                voucher.description,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (voucher.priceMinor > 0)
                        Text(
                          '${voucher.priceMinor.toStringAsFixed(0)} USD',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      if (voucher.coinPrice > 0)
                        Text(
                          '${voucher.coinPrice.toStringAsFixed(0)} coins',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.orange,
                          ),
                        ),
                      if (voucher.priceMinor == 0 && voucher.coinPrice == 0)
                        Text(
                          l10n.free,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed:
                        voucher.status == 'active' &&
                            voucher.remainingQuantity > 0
                        ? () {
                            // For free vouchers, use claim instead of purchase
                            if (voucher.priceMinor == 0 &&
                                voucher.coinPrice == 0) {
                              _claimFreeVoucher(context, voucher);
                            } else {
                              _purchaseVoucher(context, voucher);
                            }
                          }
                        : null,
                    child: Text(
                      voucher.status == 'active' &&
                              voucher.remainingQuantity > 0
                          ? (voucher.priceMinor == 0 && voucher.coinPrice == 0
                                ? l10n.claim
                                : l10n.buy)
                          : l10n.unavailable,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.quantity}: ${voucher.remainingQuantity}/${voucher.quantity}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (voucher.discountValue > 0)
                    Text(
                      '${l10n.discount}: ${voucher.discountValue.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVoucherDetails(BuildContext context, Voucher voucher) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoucherDetailsPage(voucher: voucher),
      ),
    );
  }

  void _purchaseVoucher(BuildContext context, Voucher voucher) async {
    // Load wallet first and wait for it to load
    context.read<WalletBloc>().add(const LoadWalletEvent());

    // Wait for wallet to load
    await Future.delayed(const Duration(milliseconds: 300));

    // Get wallet state after loading
    double walletBalance = 0;
    double coinBalance = 0;

    // Listen to wallet state to get balance
    final walletState = context.read<WalletBloc>().state;
    if (walletState is WalletLoaded) {
      walletBalance = walletState.wallet.balanceMinor;
      coinBalance = walletState.wallet.coins;
    } else {
      // If wallet not loaded yet, wait a bit more
      await Future.delayed(const Duration(milliseconds: 500));
      final updatedWalletState = context.read<WalletBloc>().state;
      if (updatedWalletState is WalletLoaded) {
        walletBalance = updatedWalletState.wallet.balanceMinor;
        coinBalance = updatedWalletState.wallet.coins;
      }
    }

    // Show payment method selection
    final paymentMethod = await PaymentMethodDialog.show(
      context,
      priceMinor: voucher.priceMinor,
      coinPrice: voucher.coinPrice,
      walletBalance: walletBalance,
      coinBalance: coinBalance,
    );

    if (paymentMethod == null) return;

    // Confirm purchase
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmPurchase),
        content: Text(
          '${l10n.wantToBuyVoucher(voucher.title)}\n\n'
          '${l10n.paymentMethod}: ${paymentMethod == 'wallet'
              ? l10n.walletPayment
              : paymentMethod == 'coins'
              ? l10n.coinsPayment
              : l10n.mixedPayment}\n'
          '${l10n.amount}: ${voucher.priceMinor > 0 ? '${voucher.priceMinor.toStringAsFixed(0)} XOF' : ''}'
          '${voucher.priceMinor > 0 && voucher.coinPrice > 0 ? ' ${l10n.or} ' : ''}'
          '${voucher.coinPrice > 0 ? '${voucher.coinPrice.toStringAsFixed(0)} coins' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Dispatch purchase event
      context.read<VoucherBloc>().add(
        PurchaseVoucherEvent(voucher.id, paymentMethod: paymentMethod),
      );
    }
  }

  void _claimFreeVoucher(BuildContext context, Voucher voucher) async {
    final l10n = AppLocalizations.of(context);

    // Confirm claim with correct text
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmPurchase),
        content: const Text(
          'Voulez-vous accepter votre coupon gratuit ?', // Will be localized after regeneration
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Dispatch claim event
      context.read<VoucherBloc>().add(ClaimVoucherEvent(voucher.id));
    }
  }

  void _showQrCodeDialog(BuildContext context, Purchase purchase) {
    final l10n = AppLocalizations.of(context);
    final qrData = purchase.qrPayload ?? purchase.qrCode ?? '';
    final displayCode = sanitizedVoucherCode(
      purchase.redeemCode ?? purchase.qrCode,
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.voucherDetails,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                purchase.voucherTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // QR Code
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: qrData.isNotEmpty
                    ? QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200.0,
                      )
                    : const CircularProgressIndicator(),
              ),
              const SizedBox(height: 16),
              // Redeem Code
              Text(
                displayCode.isEmpty
                    ? (purchase.redeemCode ?? purchase.qrCode ?? 'N/A')
                    : displayCode,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.showQrToMerchant,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(l10n.close),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Voucher details page
class VoucherDetailsPage extends StatelessWidget {
  final Voucher voucher;

  const VoucherDetailsPage({super.key, required this.voucher});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.voucherDetails), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Voucher Image
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: voucher.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        ImageUrlHelper.buildImageUrl(voucher.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image, size: 64);
                        },
                      ),
                    )
                  : const Icon(Icons.image, size: 64),
            ),
            const SizedBox(height: 24),

            // Voucher Info
            Text(
              voucher.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              voucher.business?.name ?? 'Voucher',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            Text(voucher.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            // Price and Discount
            Row(
              children: [
                Text(
                  '${voucher.priceMinor.toStringAsFixed(0)} USD',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '-${voucher.discountValue.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Business Information
            if (voucher.business != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.businessInformation,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: voucher.business!.logoUrl != null
                                ? NetworkImage(
                                    ImageUrlHelper.buildImageUrl(
                                      voucher.business!.logoUrl,
                                    ),
                                  )
                                : null,
                            child: voucher.business!.logoUrl == null
                                ? const Icon(Icons.business)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  voucher.business!.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (voucher.business!.category != null)
                                  Text(
                                    voucher.business!.category!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (voucher.business!.contactPhone != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              voucher.business!.contactPhone!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                      if (voucher.business!.contactEmail != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.email,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              voucher.business!.contactEmail!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Validity
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.validity,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.active),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.availableQuantity}: ${voucher.remainingQuantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Purchase/Claim Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // For free vouchers, use claim instead of purchase
                  if (voucher.priceMinor == 0 && voucher.coinPrice == 0) {
                    _claimFreeVoucher(context);
                  } else {
                    _purchaseVoucher(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  voucher.priceMinor == 0 && voucher.coinPrice == 0
                      ? l10n.claim
                      : l10n.buyNow,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _purchaseVoucher(BuildContext context) async {
    // Load wallet first
    context.read<WalletBloc>().add(const LoadWalletEvent());

    // Show dialog with wallet balance
    final walletState = context.read<WalletBloc>().state;
    double walletBalance = 0;
    double coinBalance = 0;

    if (walletState is WalletLoaded) {
      walletBalance = walletState.wallet.balanceMinor;
      coinBalance = walletState.wallet.coins;
    }

    // Show payment method selection
    final paymentMethod = await PaymentMethodDialog.show(
      context,
      priceMinor: voucher.priceMinor,
      coinPrice: voucher.coinPrice,
      walletBalance: walletBalance,
      coinBalance: coinBalance,
    );

    if (paymentMethod == null) return;

    // Confirm purchase
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmPurchase),
        content: Text(
          '${l10n.wantToBuyVoucher(voucher.title)}\n\n'
          '${l10n.paymentMethod}: ${paymentMethod == 'wallet'
              ? l10n.walletPayment
              : paymentMethod == 'coins'
              ? l10n.coinsPayment
              : l10n.mixedPayment}\n'
          '${l10n.amount}: ${voucher.priceMinor > 0 ? '${voucher.priceMinor.toStringAsFixed(0)} XOF' : ''}'
          '${voucher.priceMinor > 0 && voucher.coinPrice > 0 ? ' ${l10n.or} ' : ''}'
          '${voucher.coinPrice > 0 ? '${voucher.coinPrice.toStringAsFixed(0)} coins' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Dispatch purchase event
      context.read<VoucherBloc>().add(
        PurchaseVoucherEvent(voucher.id, paymentMethod: paymentMethod),
      );
    }
  }

  void _claimFreeVoucher(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    // Confirm claim with correct text
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmPurchase),
        content: const Text(
          'Voulez-vous accepter votre coupon gratuit ?', // Will be localized after regeneration
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Dispatch claim event
      context.read<VoucherBloc>().add(ClaimVoucherEvent(voucher.id));
    }
  }
}
