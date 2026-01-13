import 'package:equatable/equatable.dart';

/// Redemption events
abstract class RedemptionEvent extends Equatable {
  const RedemptionEvent();

  @override
  List<Object?> get props => [];
}

class RedeemVoucherEvent extends RedemptionEvent {
  final String? code;
  final String? barcode;

  const RedeemVoucherEvent({this.code, this.barcode})
      : assert(code != null || barcode != null, 'Either code or barcode must be provided');

  @override
  List<Object?> get props => [code, barcode];
}

class LoadRedemptionsEvent extends RedemptionEvent {
  final int page;
  final int limit;
  final String? startDate;
  final String? endDate;
  final String? status;
  final String? method;
  final String? businessId;

  const LoadRedemptionsEvent({
    this.page = 1,
    this.limit = 20,
    this.startDate,
    this.endDate,
    this.status,
    this.method,
    this.businessId,
  });

  @override
  List<Object?> get props => [page, limit, startDate, endDate, status, method, businessId];
}

class LoadRedemptionStatsEvent extends RedemptionEvent {
  final String? startDate;
  final String? endDate;

  const LoadRedemptionStatsEvent({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}




