import 'package:equatable/equatable.dart';

import '../../../../domain/entities/voucher.dart';

/// Voucher states
abstract class VoucherState extends Equatable {
  const VoucherState();

  @override
  List<Object?> get props => [];
}

class VoucherInitial extends VoucherState {}

class VoucherLoading extends VoucherState {}

class VouchersLoaded extends VoucherState {
  final List<Voucher> vouchers;

  const VouchersLoaded(this.vouchers);

  @override
  List<Object?> get props => [vouchers];
}

class VoucherDetailsLoaded extends VoucherState {
  final Voucher voucher;

  const VoucherDetailsLoaded(this.voucher);

  @override
  List<Object?> get props => [voucher];
}

class PurchaseSuccess extends VoucherState {
  final Purchase purchase;

  const PurchaseSuccess(this.purchase);

  @override
  List<Object?> get props => [purchase];
}

class PurchasesLoaded extends VoucherState {
  final List<Purchase> purchases;

  const PurchasesLoaded(this.purchases);

  @override
  List<Object?> get props => [purchases];
}

class PurchaseDetailsLoaded extends VoucherState {
  final Purchase purchase;

  const PurchaseDetailsLoaded(this.purchase);

  @override
  List<Object?> get props => [purchase];
}

class VoucherError extends VoucherState {
  final String message;

  const VoucherError(this.message);

  @override
  List<Object?> get props => [message];
}

