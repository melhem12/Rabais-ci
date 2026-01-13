/// Data Transfer Object for OTP Request Response
class OtpRequestResponseDto {
  final bool ok;
  final String otp;
  final bool userExists;
  final String role;
  final bool phoneVerified;

  const OtpRequestResponseDto({
    required this.ok,
    required this.otp,
    required this.userExists,
    required this.role,
    required this.phoneVerified,
  });

  factory OtpRequestResponseDto.fromJson(Map<String, dynamic> json) {
    return OtpRequestResponseDto(
      ok: json['ok'] as bool,
      otp: json['otp'] as String,
      userExists: json['user_exists'] as bool,
      role: json['role'] as String,
      phoneVerified: json['phone_verified'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ok': ok,
      'otp': otp,
      'user_exists': userExists,
      'role': role,
      'phone_verified': phoneVerified,
    };
  }
}

/// Data Transfer Object for Auth Session
class AuthSessionDto {
  final String accessToken;
  final String refreshToken;
  final UserDto user;

  const AuthSessionDto({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) {
    return AuthSessionDto(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
    };
  }
}

/// Data Transfer Object for User
class UserDto {
  final String id;
  final String name;
  final String phone;
  final String role;
  final bool firstTimeLogin;
  final bool phoneVerified;
  final String? email;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? additionalInfo;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final WalletDto? wallet;
  final List<VoucherDto>? vouchers;
  final List<PurchaseDto>? purchases;

  const UserDto({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.firstTimeLogin,
    required this.phoneVerified,
    this.email,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.additionalInfo,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
    this.wallet,
    this.vouchers,
    this.purchases,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      firstTimeLogin: json['first_time_login'] as bool,
      phoneVerified: json['phone_verified'] as bool,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth'] as String) 
          : null,
      gender: json['gender'] as String?,
      additionalInfo: json['additional_info'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      wallet: json['wallet'] != null 
          ? WalletDto.fromJson(json['wallet'] as Map<String, dynamic>) 
          : null,
      vouchers: json['vouchers'] != null 
          ? (json['vouchers'] as List<dynamic>)
              .map((v) => VoucherDto.fromJson(v as Map<String, dynamic>))
              .toList() 
          : null,
      purchases: json['purchases'] != null 
          ? (json['purchases'] as List<dynamic>)
              .map((p) => PurchaseDto.fromJson(p as Map<String, dynamic>))
              .toList() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'first_time_login': firstTimeLogin,
      'phone_verified': phoneVerified,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'additional_info': additionalInfo,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'wallet': wallet?.toJson(),
      'vouchers': vouchers?.map((v) => v.toJson()).toList(),
      'purchases': purchases?.map((p) => p.toJson()).toList(),
    };
  }
}

/// Data Transfer Object for Wallet
class WalletDto {
  final int coins;
  final int balanceMinor;

  const WalletDto({
    required this.coins,
    required this.balanceMinor,
  });

  factory WalletDto.fromJson(Map<String, dynamic> json) {
    return WalletDto(
      coins: json['coins'] as int,
      balanceMinor: json['balance_minor'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'balance_minor': balanceMinor,
    };
  }
}

/// Data Transfer Object for Voucher
class VoucherDto {
  final String id;
  final String title;
  final String description;
  final int price;
  final int discount;
  final String currency;
  final String? imageUrl;
  final String? businessId;
  final String? businessName;
  final DateTime? validFrom;
  final DateTime? validTo;
  final bool isActive;
  final int? stock;

  const VoucherDto({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discount,
    required this.currency,
    this.imageUrl,
    this.businessId,
    this.businessName,
    this.validFrom,
    this.validTo,
    required this.isActive,
    this.stock,
  });

  factory VoucherDto.fromJson(Map<String, dynamic> json) {
    return VoucherDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      discount: json['discount'] as int,
      currency: json['currency'] as String,
      imageUrl: json['image_url'] as String?,
      businessId: json['business_id'] as String?,
      businessName: json['business_name'] as String?,
      validFrom: json['valid_from'] != null 
          ? DateTime.parse(json['valid_from'] as String) 
          : null,
      validTo: json['valid_to'] != null 
          ? DateTime.parse(json['valid_to'] as String) 
          : null,
      isActive: json['is_active'] as bool,
      stock: json['stock'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'discount': discount,
      'currency': currency,
      'image_url': imageUrl,
      'business_id': businessId,
      'business_name': businessName,
      'valid_from': validFrom?.toIso8601String(),
      'valid_to': validTo?.toIso8601String(),
      'is_active': isActive,
      'stock': stock,
    };
  }
}

/// Data Transfer Object for Purchase
class PurchaseDto {
  final String id;
  final String voucherId;
  final String code;
  final String status;
  final DateTime? purchasedAt;
  final DateTime? redeemedAt;

  const PurchaseDto({
    required this.id,
    required this.voucherId,
    required this.code,
    required this.status,
    this.purchasedAt,
    this.redeemedAt,
  });

  factory PurchaseDto.fromJson(Map<String, dynamic> json) {
    return PurchaseDto(
      id: json['id'] as String,
      voucherId: json['voucher_id'] as String,
      code: json['code'] as String,
      status: json['status'] as String,
      purchasedAt: json['purchased_at'] != null 
          ? DateTime.parse(json['purchased_at'] as String) 
          : null,
      redeemedAt: json['redeemed_at'] != null 
          ? DateTime.parse(json['redeemed_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'voucher_id': voucherId,
      'code': code,
      'status': status,
      'purchased_at': purchasedAt?.toIso8601String(),
      'redeemed_at': redeemedAt?.toIso8601String(),
    };
  }
}

/// Data Transfer Object for Redemption
class RedemptionDto {
  final String id;
  final String purchaseId;
  final String code;
  final String method;
  final String? location;
  final DateTime redeemedAt;

  const RedemptionDto({
    required this.id,
    required this.purchaseId,
    required this.code,
    required this.method,
    this.location,
    required this.redeemedAt,
  });

  factory RedemptionDto.fromJson(Map<String, dynamic> json) {
    return RedemptionDto(
      id: json['id'] as String,
      purchaseId: json['purchase_id'] as String,
      code: json['code'] as String,
      method: json['method'] as String,
      location: json['location'] as String?,
      redeemedAt: DateTime.parse(json['redeemed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'code': code,
      'method': method,
      'location': location,
      'redeemed_at': redeemedAt.toIso8601String(),
    };
  }
}

/// Data Transfer Object for Sponsored Banner
class SponsoredBannerDto {
  final String id;
  final String businessId;
  final String businessName;
  final String? businessLogoUrl;
  final String imageUrl;
  final int priority;

  const SponsoredBannerDto({
    required this.id,
    required this.businessId,
    required this.businessName,
    this.businessLogoUrl,
    required this.imageUrl,
    required this.priority,
  });

  factory SponsoredBannerDto.fromJson(Map<String, dynamic> json) {
    return SponsoredBannerDto(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      businessName: json['business_name'] as String,
      businessLogoUrl: json['business_logo_url'] as String?,
      imageUrl: json['image_url'] as String,
      priority: json['priority'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'business_name': businessName,
      'business_logo_url': businessLogoUrl,
      'image_url': imageUrl,
      'priority': priority,
    };
  }
}

/// Data Transfer Object for Transaction
class TransactionDto {
  final String id;
  final String type;
  final int amount;
  final String description;
  final DateTime createdAt;

  const TransactionDto({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: json['amount'] as int,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Data Transfer Object for Coin Package
class CoinPackageDto {
  final String id;
  final String name;
  final int coinAmount;
  final int priceMinor;
  final String currency;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CoinPackageDto({
    required this.id,
    required this.name,
    required this.coinAmount,
    required this.priceMinor,
    required this.currency,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory CoinPackageDto.fromJson(Map<String, dynamic> json) {
    return CoinPackageDto(
      id: json['id'] as String,
      name: json['name'] as String,
      coinAmount: json['coin_amount'] as int,
      priceMinor: json['price_minor'] as int,
      currency: json['currency'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coin_amount': coinAmount,
      'price_minor': priceMinor,
      'currency': currency,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}