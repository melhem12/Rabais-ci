import 'package:equatable/equatable.dart';

/// Voucher events
abstract class VoucherEvent extends Equatable {
  const VoucherEvent();

  @override
  List<Object?> get props => [];
}

class LoadVouchersEvent extends VoucherEvent {
  final int page;
  final int limit;
  final String? category;
  final String? search;
  final String? businessTypeId;
  final String? businessId;
  final String? status;
  final int? minPrice;
  final int? maxPrice;
  final String? expiresBefore;

  const LoadVouchersEvent({
    this.page = 1,
    this.limit = 20,
    this.category,
    this.search,
    this.businessTypeId,
    this.businessId,
    this.status,
    this.minPrice,
    this.maxPrice,
    this.expiresBefore,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    category,
    search,
    businessTypeId,
    businessId,
    status,
    minPrice,
    maxPrice,
    expiresBefore,
  ];
}

class LoadBusinessVouchersEvent extends VoucherEvent {
  final String businessId;
  final String? status; // Optional status filter (e.g., "active", "inactive")

  const LoadBusinessVouchersEvent(this.businessId, {this.status});

  @override
  List<Object?> get props => [businessId, status];
}

class LoadVoucherDetailsEvent extends VoucherEvent {
  final String voucherId;

  const LoadVoucherDetailsEvent(this.voucherId);

  @override
  List<Object?> get props => [voucherId];
}

class PurchaseVoucherEvent extends VoucherEvent {
  final String voucherId;
  final String paymentMethod; // "wallet", "coins", or "mixed"

  const PurchaseVoucherEvent(this.voucherId, {this.paymentMethod = 'wallet'});

  @override
  List<Object?> get props => [voucherId, paymentMethod];
}

class ClaimVoucherEvent extends VoucherEvent {
  final String voucherId;

  const ClaimVoucherEvent(this.voucherId);

  @override
  List<Object?> get props => [voucherId];
}

class GetVoucherByBarcodeEvent extends VoucherEvent {
  final String barcode;

  const GetVoucherByBarcodeEvent(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class PurchaseVoucherByBarcodeEvent extends VoucherEvent {
  final String barcode;
  final String paymentMethod; // "wallet", "coins", or "mixed"

  const PurchaseVoucherByBarcodeEvent(
    this.barcode, {
    this.paymentMethod = 'wallet',
  });

  @override
  List<Object?> get props => [barcode, paymentMethod];
}

class LoadPurchasesEvent extends VoucherEvent {
  final int page;
  final int limit;
  final String? status;

  const LoadPurchasesEvent({this.page = 1, this.limit = 20, this.status});

  @override
  List<Object?> get props => [page, limit, status];
}

class LoadPurchaseDetailsEvent extends VoucherEvent {
  final String purchaseId;

  const LoadPurchaseDetailsEvent(this.purchaseId);

  @override
  List<Object?> get props => [purchaseId];
}
