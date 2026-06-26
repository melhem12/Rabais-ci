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
import '../features/purchase/bloc/purchase_bloc.dart';
import '../features/purchase/bloc/purchase_event.dart' as purchase_evt;
import '../../domain/entities/voucher.dart';
import '../../domain/entities/business_options.dart';
import '../../data/datasources/business_remote_datasource.dart';
import '../../data/datasources/wallet_remote_datasource.dart';
import '../../../core/utils/image_url_helper.dart';
import '../widgets/animations/custom_loader.dart';
import '../widgets/animations/fade_in_widget.dart';
import '../widgets/animations/slide_in_widget.dart';
import '../widgets/animations/scale_tap_widget.dart';
import '../widgets/common/app_widgets.dart';
import '../widgets/payment_method_dialog.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
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
          child: const AppLoader(size: 24),
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: Text(l10n.all),
                selected: _selectedBusinessTypeId == null,
                selectedColor: AppTheme.primaryOrange.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryOrange,
                labelStyle: TextStyle(
                  color: _selectedBusinessTypeId == null ? AppTheme.primaryOrange : Colors.grey[700],
                  fontWeight: _selectedBusinessTypeId == null ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (!selected) return;
                  _onBusinessTypeSelected(null);
                },
              ),
              const SizedBox(width: 8),
              ..._businessTypeOptions.map((type) {
                final categoryName = _categoryNames[type.categoryId];
                final label = categoryName != null && categoryName.isNotEmpty
                    ? '${type.name} (${categoryName})'
                    : type.name;
                final isSelected = _selectedBusinessTypeId == type.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryOrange.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryOrange,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryOrange : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      _onBusinessTypeSelected(selected ? type.id : null);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortingDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      value: _sortBy,
      decoration: InputDecoration(
        labelText: l10n.sortBy,
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

          // Refresh purchases now so the home "Coupons" count updates.
          context.read<PurchaseBloc>().add(const purchase_evt.LoadPurchasesEvent());

          // Reload vouchers to update remaining quantity (after a delay to ensure navigation completes)
          Future.delayed(const Duration(milliseconds: 800), () {
            if (!context.mounted) return;
            _reloadVouchers();

            // Reload wallet to update balance + purchases for the coupons count.
            context.read<WalletBloc>().add(const LoadWalletEvent());
            context.read<PurchaseBloc>().add(const purchase_evt.LoadPurchasesEvent());
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
                                child: Text(l10n.apply),
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
                    return const Center(child: AppLoader());
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
                        return FadeInWidget(
                          delay: 0.05 * index,
                          child: _buildVoucherCard(context, voucher),
                        );
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
    return ScaleTapWidget(
      onTap: () => _showVoucherDetails(context, voucher),
      child: _ModernVoucherCard(
        voucher: voucher,
        l10n: l10n,
        onBuy: () => _purchaseVoucher(context, voucher),
        onClaim: () => _claimFreeVoucher(context, voucher),
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
    // Refresh the wallet in the background (for the rest of the UI)…
    context.read<WalletBloc>().add(const LoadWalletEvent());

    // …but fetch the live balance directly so the payment dialog is accurate
    // regardless of bloc state timing.
    final balances = await _fetchBalances(context);
    final double walletBalance = balances.$1;
    final double coinBalance = balances.$2;

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
                    : const AppLoader(),
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
    final isActive = voucher.status == 'active' && voucher.remainingQuantity > 0;
    final isFree = voucher.priceMinor == 0 && voucher.coinPrice == 0;
    final hasLimit = voucher.quantity > 0;
    final soldRatio = hasLimit
        ? (1 - (voucher.remainingQuantity / voucher.quantity)).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 290,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primaryOrange,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  voucher.imageUrl != null
                      ? Image.network(
                          ImageUrlHelper.buildImageUrl(voucher.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _heroFallback(),
                        )
                      : _heroFallback(),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black54, Colors.transparent, Colors.black87],
                        stops: [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                  if (voucher.discountValue > 0)
                    Positioned(
                      top: 104,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
                        ),
                        child: Text('-${voucher.discountValue.toInt()}%',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(children: [
                          _heroBadge(isFree ? l10n.free : l10n.paid, isFree ? Colors.green : AppTheme.primaryTurquoise),
                          const SizedBox(width: 8),
                          _heroBadge(voucher.status == 'active' ? l10n.active : l10n.inactive,
                              voucher.status == 'active' ? Colors.green : Colors.red),
                        ]),
                        const SizedBox(height: 10),
                        Text(voucher.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
                        if (voucher.business?.name != null) ...[
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.storefront, color: Colors.white70, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(voucher.business!.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                            ),
                          ]),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 6))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.price, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            const SizedBox(height: 6),
                            if (voucher.priceMinor > 0)
                              Text('${voucher.priceMinor.toStringAsFixed(0)} CFA',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryTurquoise)),
                            if (voucher.coinPrice > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Row(children: [
                                  const Icon(Icons.monetization_on, size: 18, color: AppTheme.primaryOrange),
                                  const SizedBox(width: 4),
                                  Text('${voucher.coinPrice.toStringAsFixed(0)} ${l10n.coins}',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryOrange)),
                                ]),
                              ),
                            if (isFree)
                              Text(l10n.free, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                        if (voucher.discountValue > 0)
                          Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: AppTheme.primaryOrange.withOpacity(0.1), shape: BoxShape.circle),
                            child: Text('-${voucher.discountValue.toInt()}%',
                                style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold, fontSize: 17)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (voucher.description.isNotEmpty) ...[
                    Text(l10n.description, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(voucher.description, style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey[800])),
                    const SizedBox(height: 18),
                  ],
                  if (hasLimit) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(l10n.availableQuantity, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                            Text('${voucher.remainingQuantity}/${voucher.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: soldRatio,
                              minHeight: 8,
                              backgroundColor: AppTheme.primaryOrange.withOpacity(0.12),
                              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryOrange),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  if (voucher.business != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                      ),
                      child: Row(children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                          backgroundImage: voucher.business!.logoUrl != null
                              ? NetworkImage(ImageUrlHelper.buildImageUrl(voucher.business!.logoUrl))
                              : null,
                          child: voucher.business!.logoUrl == null
                              ? const Icon(Icons.storefront, color: AppTheme.primaryOrange)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(voucher.business!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              if (voucher.business!.category != null && voucher.business!.category!.isNotEmpty)
                                Text(voucher.business!.category!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isActive
                    ? () {
                        if (isFree) {
                          _claimFreeVoucher(context);
                        } else {
                          _purchaseVoucher(context);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? AppTheme.primaryOrange : Colors.grey,
                  foregroundColor: Colors.white,
                  elevation: isActive ? 2 : 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  isActive ? (isFree ? l10n.claim : l10n.buyNow) : l10n.unavailable,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryOrange, AppTheme.primaryTurquoise],
        ),
      ),
      child: const Center(child: Icon(Icons.local_offer, color: Colors.white, size: 64)),
    );
  }

  Widget _heroBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  void _purchaseVoucher(BuildContext context) async {
    // Refresh the wallet in the background…
    context.read<WalletBloc>().add(const LoadWalletEvent());

    // …and fetch the live balance directly for an accurate payment dialog.
    final balances = await _fetchBalances(context);
    final double walletBalance = balances.$1;
    final double coinBalance = balances.$2;

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

/// Fetches the user's live wallet balance (money + coins) for the payment
/// dialog. Reads directly from the API so it doesn't depend on WalletBloc
/// state timing; falls back to the current bloc state, then to zero.
Future<(double, double)> _fetchBalances(BuildContext context) async {
  final walletBloc = context.read<WalletBloc>();
  try {
    final wallet = await getIt<WalletRemoteDataSource>().getWallet();
    return (wallet.balanceMinor, wallet.coins);
  } catch (_) {
    final s = walletBloc.state;
    if (s is WalletLoaded) {
      return (s.wallet.balanceMinor, s.wallet.coins);
    }
    return (0.0, 0.0);
  }
}

/// Modern, attractive voucher card (browse list) — banner image, overlaid
/// badges, discount ribbon, quantity progress bar and a clear buy/claim CTA.
class _ModernVoucherCard extends StatelessWidget {
  const _ModernVoucherCard({
    required this.voucher,
    required this.l10n,
    required this.onBuy,
    required this.onClaim,
  });

  final Voucher voucher;
  final AppLocalizations l10n;
  final VoidCallback onBuy;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final isActive = voucher.status == 'active' && voucher.remainingQuantity > 0;
    final isFree = voucher.priceMinor == 0 && voucher.coinPrice == 0;
    final hasLimit = voucher.quantity > 0;
    final soldRatio = hasLimit
        ? (1 - (voucher.remainingQuantity / voucher.quantity)).clamp(0.0, 1.0)
        : 0.0;

    return Card(
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
                height: 150,
                width: double.infinity,
                child: voucher.imageUrl != null
                    ? Image.network(
                        ImageUrlHelper.buildImageUrl(voucher.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallback(),
                        loadingBuilder: (c, child, p) =>
                            p == null ? child : _fallback(loading: true),
                      )
                    : _fallback(),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.45)],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: _badge(isFree ? l10n.free : l10n.paid,
                    isFree ? Colors.green : AppTheme.primaryTurquoise),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _badge(
                    voucher.status == 'active' ? l10n.active : l10n.inactive,
                    voucher.status == 'active' ? Colors.green : Colors.red),
              ),
              if (voucher.discountValue > 0)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.25), blurRadius: 6),
                      ],
                    ),
                    child: Text(
                      '-${voucher.discountValue.toStringAsFixed(0)}%',
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
                Text(voucher.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                if (voucher.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(voucher.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[600], height: 1.3)),
                ],
                const SizedBox(height: 12),
                if (hasLimit) ...[
                  Text(
                      '${l10n.quantity}: ${voucher.remainingQuantity}/${voucher.quantity}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: soldRatio,
                      minHeight: 6,
                      backgroundColor: AppTheme.primaryOrange.withOpacity(0.12),
                      valueColor: const AlwaysStoppedAnimation(
                          AppTheme.primaryOrange),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (voucher.priceMinor > 0)
                          Text('${voucher.priceMinor.toStringAsFixed(0)} CFA',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTurquoise)),
                        if (voucher.coinPrice > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(children: [
                              const Icon(Icons.monetization_on,
                                  size: 16, color: AppTheme.primaryOrange),
                              const SizedBox(width: 4),
                              Text(
                                  '${voucher.coinPrice.toStringAsFixed(0)} ${l10n.coins}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.primaryOrange,
                                      fontWeight: FontWeight.w700)),
                            ]),
                          ),
                        if (isFree)
                          Text(l10n.free,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: isActive ? (isFree ? onClaim : onBuy) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isActive ? AppTheme.primaryOrange : Colors.grey,
                        foregroundColor: Colors.white,
                        elevation: isActive ? 2 : 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                      ),
                      child: Text(
                          isActive
                              ? (isFree ? l10n.claim : l10n.buy)
                              : l10n.unavailable,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback({bool loading = false}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryOrange, AppTheme.primaryTurquoise],
        ),
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.local_offer, color: Colors.white, size: 44),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)],
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
