import 'package:equatable/equatable.dart';

import '../../../../domain/entities/wallet.dart';

/// Wallet states
abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final Wallet wallet;
  final List<Transaction> recentTransactions;

  const WalletLoaded(this.wallet, {this.recentTransactions = const []});

  @override
  List<Object?> get props => [wallet, recentTransactions];
}

class TransactionsLoaded extends WalletState {
  final List<Transaction> transactions;
  final String currency;

  const TransactionsLoaded(this.transactions, {required this.currency});

  @override
  List<Object?> get props => [transactions, currency];
}

class CoinPackagesLoaded extends WalletState {
  final List<CoinPackage> packages;

  const CoinPackagesLoaded(this.packages);

  @override
  List<Object?> get props => [packages];
}

class TopUpSuccess extends WalletState {
  final Transaction transaction;

  const TopUpSuccess(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaiementProInitSuccess extends WalletState {
  final String redirectUrl;

  const PaiementProInitSuccess(this.redirectUrl);

  @override
  List<Object?> get props => [redirectUrl];
}

/// Wave: a pending request was recorded; the user now pays [amount] CFA
/// through [paymentUrl] and an admin credits [coins] within 24 hours.
class WaveManualPaymentReady extends WalletState {
  final String paymentUrl;
  final int amount;
  final int coins;

  const WaveManualPaymentReady({
    required this.paymentUrl,
    required this.amount,
    required this.coins,
  });

  @override
  List<Object?> get props => [paymentUrl, amount, coins];
}
