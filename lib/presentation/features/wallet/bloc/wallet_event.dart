import 'package:equatable/equatable.dart';

/// Wallet events
abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWalletEvent extends WalletEvent {
  const LoadWalletEvent();
}

class LoadTransactionsEvent extends WalletEvent {
  const LoadTransactionsEvent();
}

class LoadCoinPackagesEvent extends WalletEvent {
  const LoadCoinPackagesEvent();
}

class TopUpWalletEvent extends WalletEvent {
  final String? packageId;
  final double? amount;
  final String provider;
  final String? currency;

  const TopUpWalletEvent({
    this.packageId,
    this.amount,
    this.provider = 'internal',
    this.currency,
  }) : assert(packageId != null || amount != null, 'Either packageId or amount must be provided');

  @override
  List<Object?> get props => [packageId, amount, provider, currency];
}

class InitPaiementProTopupEvent extends WalletEvent {
  final String? packageId;
  final double? amount;
  final String? currency;

  const InitPaiementProTopupEvent({
    this.packageId,
    this.amount,
    this.currency,
  }) : assert(packageId != null || amount != null, 'Either packageId or amount must be provided');

  @override
  List<Object?> get props => [packageId, amount, currency];
}



