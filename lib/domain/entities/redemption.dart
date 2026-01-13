/// Redemption entity
class Redemption {
  final String id;
  final String purchaseId;
  final String voucherId;
  final String voucherTitle;
  final double amount;
  final int amountMinor;
  final int coinAmount;
  final String currency;
  final DateTime redemptionDate;
  final String status;
  final String? customerPhone;
  final String? method;
  final String? location;
  final String? businessId;
  final String? businessName;
  final String? cashierName;

  const Redemption({
    required this.id,
    required this.purchaseId,
    required this.voucherId,
    required this.voucherTitle,
    required this.amount,
    required this.amountMinor,
    required this.coinAmount,
    required this.currency,
    required this.redemptionDate,
    required this.status,
    this.customerPhone,
    this.method,
    this.location,
    this.businessId,
    this.businessName,
    this.cashierName,
  });

  factory Redemption.fromJson(Map<String, dynamic> json) {
    final int rawAmountMinor = json['amount_minor'] is int
        ? json['amount_minor'] as int
        : int.tryParse('${json['amount_minor'] ?? 0}') ?? 0;

    final int rawCoinAmount = json['coin_amount'] is int
        ? json['coin_amount'] as int
        : int.tryParse('${json['coin_amount'] ?? 0}') ?? 0;

    return Redemption(
      id: json['id'] ?? '',
      purchaseId: json['purchase_id'] ?? '',
      voucherId: json['voucher_id'] ?? '',
      voucherTitle: json['voucher_title'] ?? '',
      amount: rawAmountMinor / 100,
      amountMinor: rawAmountMinor,
      coinAmount: rawCoinAmount,
      currency: json['currency'] ?? 'XOF',
      redemptionDate: DateTime.tryParse(json['redemption_date'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? '',
      customerPhone: json['customer_phone'],
      method: json['method'],
      location: json['location'],
      businessId: json['business_id'],
      businessName: json['business_name'],
      cashierName: json['cashier_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'voucher_id': voucherId,
      'voucher_title': voucherTitle,
      'amount_minor': amountMinor,
      'coin_amount': coinAmount,
      'amount': amount,
      'currency': currency,
      'redemption_date': redemptionDate.toIso8601String(),
      'status': status,
      'customer_phone': customerPhone,
      'method': method,
      'location': location,
      'business_id': businessId,
      'business_name': businessName,
      'cashier_name': cashierName,
    };
  }
}

/// Redemption Response entity
class RedemptionResponse {
  final bool ok;
  final String message;
  final String? purchaseId;

  const RedemptionResponse({
    required this.ok,
    required this.message,
    this.purchaseId,
  });

  factory RedemptionResponse.fromJson(Map<String, dynamic> json) {
    return RedemptionResponse(
      ok: json['ok'] ?? false,
      message: json['message'] ?? '',
      purchaseId: json['purchase_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ok': ok,
      'message': message,
      'purchase_id': purchaseId,
    };
  }
}






