import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'payment_webview_page.dart';

import '../../di/service_locator.dart';
import '../../data/datasources/wallet_remote_datasource.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/entities/wallet.dart' as wallet_entities show CoinPackage;
import '../features/wallet/bloc/wallet_bloc.dart';
import '../features/wallet/bloc/wallet_event.dart';
import '../features/wallet/bloc/wallet_state.dart';
import '../../generated/l10n/app_localizations.dart';
import '../widgets/animations/custom_loader.dart';

class WalletRechargePage extends StatefulWidget {
  const WalletRechargePage({
    super.key,
    required this.wallet,
  });

  final Wallet wallet;

  static Route<bool?> route(Wallet wallet) {
    return MaterialPageRoute<bool?>(
      builder: (_) => BlocProvider<WalletBloc>(
        create: (_) => getIt<WalletBloc>()..add(const LoadCoinPackagesEvent()),
        child: WalletRechargePage(wallet: wallet),
      ),
    );
  }

  @override
  State<WalletRechargePage> createState() => _WalletRechargePageState();
}

class _WalletRechargePageState extends State<WalletRechargePage> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.topUp),
        centerTitle: true,
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletError) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is TopUpSuccess) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.topUpSuccessful)),
            );
            Navigator.of(context).pop(true);
          } else if (state is PaiementProInitSuccess) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.redirectingPaiementPro)),
            );
            _launchPaymentUrl(state.redirectUrl);
          } else if (state is WalletLoading && !_isSubmitting) {
            // ignore, handled in builder
          }
        },
        builder: (context, state) {
          if (_isSubmitting) {
            return const Center(child: AppLoader());
          }

          if (state is WalletLoading && !_isSubmitting) {
            return const Center(child: AppLoader());
          }

          if (state is CoinPackagesLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<WalletBloc>().add(const LoadCoinPackagesEvent());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _WalletSummary(wallet: widget.wallet),
                  const SizedBox(height: 24),
                  Text(
                    l10n.availableCoinPackages,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...state.packages.map(
                  (package) => _CoinPackageCard(
                      package: package,
                      coinPriceUsd: widget.wallet.coinPriceUsd,
                      onTap: () => _handlePurchase(package, l10n),
                    ),
                  ),
                  if (state.packages.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 48.0),
                      child: Column(
                        children: [
                          const Icon(Icons.inbox, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noCoinPackagesAvailable,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _handlePurchase(
    wallet_entities.CoinPackage package,
    AppLocalizations l10n,
  ) async {
    if (_isSubmitting) return;

    // Ask the user which payment method to use before starting the top-up.
    final method = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _PaymentMethodPicker(),
    );
    if (method == null || !mounted) return; // dismissed

    setState(() => _isSubmitting = true);
    context.read<WalletBloc>().add(
          InitPaiementProTopupEvent(
            packageId: package.id,
            method: method,
          ),
        );
  }

  Future<void> _launchPaymentUrl(String url) async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid PaiementPro URL')),
      );
      return;
    }
    final bool? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentWebViewPage(
          paymentUrl: url,
          returnUrl: 'https://rabais-ci.com/payment/result',
        ),
      ),
    );
    if (!mounted) return;
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.topUpSuccessful)),
      );
      // Pop back to the wallet page, which reloads and shows the new balance.
      Navigator.of(context).pop(true);
    } else {
      // WebView dismissed without completing: reload packages so the page
      // doesn't get stuck on an empty state.
      context.read<WalletBloc>().add(const LoadCoinPackagesEvent());
    }
  }
}

class _WalletSummary extends StatelessWidget {
  const _WalletSummary({required this.wallet});

  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final coinPriceFormatter = NumberFormat.currency(
      locale: 'fr-FR',
      symbol: 'CFA',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.currentBalance,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                wallet.coins.toStringAsFixed(0),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.coins,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          if (wallet.coinPriceUsd != null) ...[
            const SizedBox(height: 16),
            _SummaryChip(
              icon: Icons.attach_money_rounded,
              label:
                  '${l10n.coinPrice}: ${coinPriceFormatter.format(wallet.coinPriceUsd!)}',
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _CoinPackageCard extends StatelessWidget {
  const _CoinPackageCard({
    required this.package,
    required this.onTap,
    this.coinPriceUsd,
  });

  final wallet_entities.CoinPackage package;
  final VoidCallback onTap;
  final double? coinPriceUsd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // CFA (XOF) is a zero-decimal currency, so priceMinor is already whole CFA.
    final priceMajor = package.priceMinor.toDouble();
    final formatter = NumberFormat.currency(
      locale: 'fr-FR',
      symbol: 'CFA',
      decimalDigits: 0,
    );
    final priceText = formatter.format(priceMajor);
    final pricePerCoin = package.coinAmount > 0
        ? package.priceMinor / package.coinAmount
        : null;
    final cfaEstimate = coinPriceUsd != null
        ? (package.coinAmount * coinPriceUsd!)
        : null;
    final cfaFormatter = NumberFormat.currency(
      locale: 'fr-FR',
      symbol: 'CFA',
      decimalDigits: 0,
    );
    final isNew = package.createdAt != null &&
        DateTime.now().difference(package.createdAt!).inDays <= 14;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceVariant.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    package.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isNew)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      l10n.newBadge,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${package.coinAmount}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.coins,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary.withOpacity(0.8),
                  ),
                ),
                const Spacer(),
                Text(
                  priceText,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (cfaEstimate != null) ...[
              Text(
                '≈ ${cfaFormatter.format(cfaEstimate)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary.withOpacity(0.75),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (package.description != null && package.description!.isNotEmpty)
              Text(
                package.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            if (pricePerCoin != null) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.coinUnitPrice}: ${NumberFormat.currency(locale: 'fr-FR', symbol: 'CFA', decimalDigits: 0).format(pricePerCoin)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.flash_on_rounded),
              label: Text(l10n.buyNow),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            if (!package.isActive)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  l10n.packageCurrentlyUnavailable,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet that lists available payment methods (fetched from the API)
/// and returns the selected method key via Navigator.pop.
class _PaymentMethodPicker extends StatefulWidget {
  const _PaymentMethodPicker();

  @override
  State<_PaymentMethodPicker> createState() => _PaymentMethodPickerState();
}

class _PaymentMethodPickerState extends State<_PaymentMethodPicker> {
  late Future<List<PaymentMethodOption>> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<WalletRemoteDataSource>().getPaymentMethods();
  }

  IconData _iconFor(String method) {
    switch (method) {
      case 'card':
        return Icons.credit_card_rounded;
      case 'orange_money':
        return Icons.account_balance_wallet_rounded;
      case 'mtn_momo':
        return Icons.smartphone_rounded;
      case 'moov':
        return Icons.phone_android_rounded;
      case 'wave':
        return Icons.waves_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  Color _colorFor(String method, BuildContext context) {
    switch (method) {
      case 'orange_money':
        return const Color(0xFFFF7900);
      case 'mtn_momo':
        return const Color(0xFFFFB300);
      case 'moov':
        return const Color(0xFF0066B3);
      case 'wave':
        return const Color(0xFF1DC8FF);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(
              'Choisir le mode de paiement',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Sélectionnez comment vous souhaitez payer',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<PaymentMethodOption>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline_rounded,
                            color: theme.colorScheme.error, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun mode de paiement disponible',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                final methods = snapshot.data!;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: methods.map((m) {
                    final color = _colorFor(m.method, context);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.of(context).pop(m.method),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.colorScheme.outlineVariant),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(_iconFor(m.method), color: color),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    m.label,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded,
                                    color: theme.colorScheme.outline),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
