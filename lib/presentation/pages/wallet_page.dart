import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../features/wallet/bloc/wallet_bloc.dart';
import '../features/wallet/bloc/wallet_event.dart';
import '../features/wallet/bloc/wallet_state.dart';
import '../../domain/entities/wallet.dart';
import '../widgets/common/app_widgets.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/animations/custom_loader.dart';
import '../widgets/animations/fade_in_widget.dart';
import '../widgets/animations/scale_tap_widget.dart';
import 'wallet_recharge_page.dart';

/// Wallet page
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const LoadWalletEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wallet),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WalletBloc>().add(const LoadWalletEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: AppLoader());
          } else if (state is WalletLoaded) {
            return _buildWalletContent(
              context,
              state.wallet,
              state.recentTransactions,
            );
          } else if (state is WalletError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<WalletBloc>().add(const LoadWalletEvent());
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildWalletContent(
    BuildContext context,
    Wallet wallet,
    List<Transaction> recentTransactions,
  ) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.currentBalance,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '${wallet.coins.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.coins,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            l10n.quickActions,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  l10n.topUp,
                  Icons.add_circle,
                  Colors.green,
                  () => _openRechargePage(wallet),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  context,
                  l10n.transactionHistory,
                  Icons.history,
                  Colors.blue,
                  () => _showTransactions(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Transactions
          Text(
            l10n.recentTransactions,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildRecentTransactions(recentTransactions, wallet.currency),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ScaleTapWidget(
      onTap: onTap,
      child: Card(
        elevation: 2,
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
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(List<Transaction> transactions, String currency) {
    final l10n = AppLocalizations.of(context);

    if (transactions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              l10n.noRecentTransactions,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    // Show only 2-3 recent transactions
    final recentTransactions = transactions.take(3).toList();
    
    return Column(
      children: [
        ...recentTransactions.map((transaction) {
          return _buildTransactionTile(transaction, 'CFA', l10n); // Always use CFA
        }),
        if (transactions.length > 3)
          Card(
            child: ListTile(
              title: Text(
                'Voir tout', // Will be localized
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryOrange,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showTransactions(),
            ),
          ),
      ],
    );
  }

  Future<void> _openRechargePage(Wallet wallet) async {
    final recharged = await Navigator.of(context).push<bool?>(
      WalletRechargePage.route(wallet),
    );
    if (!mounted) return;
    if (recharged == true) {
      context.read<WalletBloc>().add(const LoadWalletEvent());
    }
  }

  Future<void> _showTransactions() async {
    final bloc = context.read<WalletBloc>();
    final navigator = Navigator.of(context);
    await navigator.push(
      MaterialPageRoute(builder: (context) => const TransactionsPage()),
    );
    if (!mounted) return;
    bloc.add(const LoadWalletEvent());
  }

}

/// Transactions page
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const LoadTransactionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.transactionHistory), centerTitle: true),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is TransactionsLoaded) {
            final l10n = AppLocalizations.of(context);
            if (state.transactions.isEmpty) {
              return Center(
                child: Text(
                  l10n.noTransactionsFound,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                final transaction = state.transactions[index];
                return FadeInWidget(
                  delay: 0.05 * index,
                  child: _buildTransactionTile(transaction, state.currency, l10n),
                );
              },
            );
          } else if (state is WalletError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<WalletBloc>().add(const LoadTransactionsEvent());
              },
            );
          }
          return const Center(child: AppLoader());
        },
      ),
    );
  }
}

Widget _buildTransactionTile(
  Transaction transaction,
  String currency,
  AppLocalizations l10n,
) {
  final hasAmount = transaction.amountMinor != 0;
  final hasCoinDelta = transaction.coinDelta != 0;

  final bool isCredit = transaction.isCredit;
  IconData icon;
  Color color;
  String trailing;

  if (hasAmount) {
    // Always display in CFA
    final amountMajor = transaction.amountMajor.abs();
    final formattedAmount = '${amountMajor.toStringAsFixed(0)} CFA';
    final sign = transaction.amountMajor == 0 ? '' : (isCredit ? '+' : '-');
    trailing = sign.isEmpty ? formattedAmount : '$sign $formattedAmount';
    color = isCredit ? Colors.green : Colors.red;
    icon = isCredit ? Icons.add_circle : Icons.remove_circle;
  } else if (hasCoinDelta) {
    final sign = transaction.coinDelta > 0 ? '+' : '-';
    trailing = '$sign${transaction.coinDelta.abs()} ${l10n.coins}';
    color = transaction.coinDelta > 0 ? Colors.green : Colors.red;
    icon = transaction.coinDelta > 0 ? Icons.add_circle : Icons.remove_circle;
  } else {
    trailing = transaction.status;
    color = Colors.grey;
    icon = Icons.sync_alt;
  }

  final dateFormat = DateFormat.yMMMd(l10n.localeName).add_Hm();
  final subtitle = dateFormat.format(transaction.createdAt.toLocal());
  final title = _describeTransaction(transaction, l10n);

  return Card(
    elevation: 1,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withOpacity(0.05),
          ],
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        trailing: Text(
          trailing,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: color,
          ),
        ),
      ),
    ),
  );
}

String _describeTransaction(Transaction transaction, AppLocalizations l10n) {
  if (transaction.reference != null && transaction.reference!.isNotEmpty) {
    return transaction.reference!;
  }

  switch (transaction.type) {
    case 'topup':
      return l10n.topUp;
    case 'withdraw':
      return _titleCase(transaction.type);
    case 'voucher':
      return 'Voucher';
    case 'charge':
      return 'Charge';
    case 'promo':
      return 'Promotion';
    default:
      return _titleCase(transaction.type);
  }
}

String _titleCase(String input) {
  if (input.isEmpty) return input;
  final normalized = input.replaceAll('_', ' ');
  return normalized.split(' ').map((word) {
    if (word.isEmpty) return word;
    if (word.length == 1) return word.toUpperCase();
    return '${word[0].toUpperCase()}${word.substring(1)}';
  }).join(' ');
}
