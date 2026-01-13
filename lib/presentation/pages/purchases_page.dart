import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../core/utils/code_formatter.dart';
import '../../core/theme/app_theme.dart';
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
        title: const Text('Mes Coupons'), // Will be localized
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
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                statusColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        purchase.voucherTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _getStatusText(purchase.status, l10n),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTurquoise.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryTurquoise.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${purchase.amount.toInt()} ${purchase.currency}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryTurquoise,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.confirmation_number,
                        size: 16,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${l10n.code}: $codeForDisplay',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTurquoise.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.primaryTurquoise,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n.purchasedOn}: ${_formatDate(purchase.purchaseDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
