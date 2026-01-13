/// Business entity
class Business {
  final String id;
  final String name;
  final String? logoUrl;
  final String? category;
  final String? contactPhone;
  final String? contactEmail;
  final String? address;
  final int? activeVouchersCount;

  const Business({
    required this.id,
    required this.name,
    this.logoUrl,
    this.category,
    this.contactPhone,
    this.contactEmail,
    this.address,
    this.activeVouchersCount,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logoUrl: json['logo_url'],
      category: json['category'],
      contactPhone: json['contact_phone'],
      contactEmail: json['contact_email'],
      address: json['address'],
      activeVouchersCount: json['active_vouchers_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'category': category,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'address': address,
      'active_vouchers_count': activeVouchersCount,
    };
  }
}

/// Voucher entity
class Voucher {
  final String id;
  final String? businessId;
  final String title;
  final String description;
  final double priceMinor;
  final double coinPrice;
  final double discountValue;
  final String type;
  final int quantity;
  final bool isUnlimited;
  final int remainingQuantity;
  final String status;
  final String? imageUrl;
  final String? barcode;
  final Business? business;

  const Voucher({
    required this.id,
    this.businessId,
    required this.title,
    required this.description,
    required this.priceMinor,
    required this.coinPrice,
    required this.discountValue,
    required this.type,
    required this.quantity,
    required this.isUnlimited,
    required this.remainingQuantity,
    required this.status,
    this.imageUrl,
    this.barcode,
    this.business,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'] ?? '',
      businessId: json['business_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priceMinor: (json['price_minor'] ?? 0).toDouble(),
      coinPrice: (json['coin_price'] ?? 0).toDouble(),
      discountValue: (json['discount_value'] ?? 0).toDouble(),
      type: json['type'] ?? 'paid',
      quantity: json['quantity'] ?? 0,
      isUnlimited: json['is_unlimited'] ?? false,
      remainingQuantity: json['remaining_quantity'] ?? 0,
      status: json['status'] ?? 'active',
      imageUrl: json['image_url'],
      barcode: json['barcode'],
      business: json['business'] != null ? Business.fromJson(json['business']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'title': title,
      'description': description,
      'price_minor': priceMinor,
      'coin_price': coinPrice,
      'discount_value': discountValue,
      'type': type,
      'quantity': quantity,
      'is_unlimited': isUnlimited,
      'remaining_quantity': remainingQuantity,
      'status': status,
      'image_url': imageUrl,
      'barcode': barcode,
      'business': business?.toJson(),
    };
  }
}

/// Payment Details entity
class PaymentDetails {
  final String paymentMethod;
  final double amountPaid;
  final double coinsUsed;
  final double walletBalanceAfter;
  final double coinsBalanceAfter;

  const PaymentDetails({
    required this.paymentMethod,
    required this.amountPaid,
    required this.coinsUsed,
    required this.walletBalanceAfter,
    required this.coinsBalanceAfter,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      paymentMethod: json['payment_method'] ?? '',
      amountPaid: (json['amount_paid'] ?? 0).toDouble(),
      coinsUsed: (json['coins_used'] ?? 0).toDouble(),
      walletBalanceAfter: (json['wallet_balance_after'] ?? 0).toDouble(),
      coinsBalanceAfter: (json['coins_balance_after'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_method': paymentMethod,
      'amount_paid': amountPaid,
      'coins_used': coinsUsed,
      'wallet_balance_after': walletBalanceAfter,
      'coins_balance_after': coinsBalanceAfter,
    };
  }
}

/// Voucher Details in Purchase
class VoucherDetails {
  final String id;
  final String title;
  final double discountValue;
  final String? imageUrl;
  final Business? business;

  const VoucherDetails({
    required this.id,
    required this.title,
    required this.discountValue,
    this.imageUrl,
    this.business,
  });

  factory VoucherDetails.fromJson(Map<String, dynamic> json) {
    return VoucherDetails(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      discountValue: (json['discount_value'] ?? 0).toDouble(),
      imageUrl: json['image_url'],
      business: json['business'] != null ? Business.fromJson(json['business']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'discount_value': discountValue,
      'image_url': imageUrl,
      'business': business?.toJson(),
    };
  }
}

/// Purchase entity
class Purchase {
  final String id;
  final String voucherId;
  final String voucherTitle;
  final double amountMinor;
  final double? coinAmount;
  final String currency;
  final String status;
  final DateTime purchaseDate;
  final DateTime? validUntil;
  final String? qrCode;
  final String? qrPayload;
  final String? barcode;
  final String? redeemCode;
  final bool isRedeemed;
  final DateTime? redeemedAt;
  final PaymentDetails? paymentDetails;
  final VoucherDetails? voucherDetails;

  const Purchase({
    required this.id,
    required this.voucherId,
    required this.voucherTitle,
    required this.amountMinor,
    this.coinAmount,
    required this.currency,
    required this.status,
    required this.purchaseDate,
    this.validUntil,
    this.qrCode,
    this.qrPayload,
    this.barcode,
    this.redeemCode,
    this.isRedeemed = false,
    this.redeemedAt,
    this.paymentDetails,
    this.voucherDetails,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] ?? '',
      voucherId: json['voucher_id'] ?? '',
      voucherTitle: json['voucher_title'] ?? '',
      amountMinor: (json['amount_minor'] ?? json['amount'] ?? 0).toDouble(),
      coinAmount: json['coin_amount'] != null ? (json['coin_amount'] as num).toDouble() : null,
      currency: json['currency'] ?? 'XOF',
      status: json['status'] ?? '',
      purchaseDate: DateTime.tryParse(json['purchase_date'] ?? '') ?? DateTime.now(),
      validUntil: json['valid_until'] != null 
          ? DateTime.tryParse(json['valid_until']) 
          : null,
      qrCode: json['qr_code'],
      qrPayload: json['qr_payload'] ?? json['qr_code'],
      barcode: json['barcode'],
      redeemCode: json['redeem_code'],
      isRedeemed: json['is_redeemed'] ?? false,
      redeemedAt: json['redeemed_at'] != null 
          ? DateTime.tryParse(json['redeemed_at']) 
          : null,
      paymentDetails: json['payment_details'] != null 
          ? PaymentDetails.fromJson(json['payment_details']) 
          : null,
      voucherDetails: json['voucher_details'] != null 
          ? VoucherDetails.fromJson(json['voucher_details']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'voucher_id': voucherId,
      'voucher_title': voucherTitle,
      'amount_minor': amountMinor,
      'coin_amount': coinAmount,
      'currency': currency,
      'status': status,
      'purchase_date': purchaseDate.toIso8601String(),
      'valid_until': validUntil?.toIso8601String(),
      'qr_code': qrCode,
      'qr_payload': qrPayload,
      'barcode': barcode,
      'redeem_code': redeemCode,
      'is_redeemed': isRedeemed,
      'redeemed_at': redeemedAt?.toIso8601String(),
      'payment_details': paymentDetails?.toJson(),
      'voucher_details': voucherDetails?.toJson(),
    };
  }
  
  // Legacy getter for backward compatibility
  double get amount => amountMinor;
}

/// Sponsored Banner entity
class SponsoredBanner {
  final String id;
  final String businessId;
  final String businessName;
  final String? businessLogoUrl;
  final String businessStatus;
  final int priority;
  final String? imageUrl;

  const SponsoredBanner({
    required this.id,
    required this.businessId,
    required this.businessName,
    this.businessLogoUrl,
    required this.businessStatus,
    required this.priority,
    this.imageUrl,
  });

  factory SponsoredBanner.fromJson(Map<String, dynamic> json) {
    return SponsoredBanner(
      id: json['id'] ?? '',
      businessId: json['business_id'] ?? '',
      businessName: json['business_name'] ?? '',
      businessLogoUrl: json['business_logo_url'],
      businessStatus: json['business_status'] ?? 'pending',
      priority: json['priority'] ?? 0,
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'business_name': businessName,
      'business_logo_url': businessLogoUrl,
      'business_status': businessStatus,
      'priority': priority,
      'image_url': imageUrl,
    };
  }
}




