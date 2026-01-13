/// Wallet entity
class Wallet {
  final String id;
  final double coins;
  final double balanceMinor;
  final String currency;
  final DateTime lastUpdated;
  final double? coinPriceUsd;

  const Wallet({
    required this.id,
    required this.coins,
    required this.balanceMinor,
    required this.currency,
    required this.lastUpdated,
    this.coinPriceUsd,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] ?? '',
      coins: (json['coins'] ?? 0).toDouble(),
      balanceMinor: (json['balance_minor'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'XOF',
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated']) ?? DateTime.now()
          : DateTime.now(),
      coinPriceUsd: json['coin_price_usd'] != null
          ? (json['coin_price_usd'] is num
              ? (json['coin_price_usd'] as num).toDouble()
              : double.tryParse(json['coin_price_usd'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coins': coins,
      'balance_minor': balanceMinor,
      'currency': currency,
      'last_updated': lastUpdated.toIso8601String(),
      'coin_price_usd': coinPriceUsd,
    };
  }
}

/// Transaction entity aligned with `/wallet/transactions`
class Transaction {
  final String id;
  final String type;
  final int amountMinor;
  final int coinDelta;
  final String status;
  final DateTime createdAt;
  final String? reference;
  final Map<String, dynamic>? metadata;

  const Transaction({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.coinDelta,
    required this.status,
    required this.createdAt,
    this.reference,
    this.metadata,
  });

  /// Amount expressed in major currency units (e.g. XOF)
  double get amountMajor => amountMinor / 100.0;

  /// Whether this transaction increases the user's balance.
  bool get isCredit {
    if (coinDelta != 0) return coinDelta > 0;
    return _creditTypes.contains(type);
  }

  /// Whether this transaction decreases the user's balance.
  bool get isDebit => !isCredit;

  static const _creditTypes = {'topup', 'promo'};

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final rawAmountMinor = json['amount_minor'] ?? json['amount'];
    final rawCoinDelta = json['coin_delta'] ?? json['coinDelta'];
    final parsedAmountMinor = _parseInt(rawAmountMinor);
    final parsedCoinDelta = _parseInt(rawCoinDelta);

    return Transaction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      amountMinor: parsedAmountMinor,
      coinDelta: parsedCoinDelta,
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : (json['date'] != null
              ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
              : DateTime.now()),
      reference: json['ref']?.toString() ?? json['reference']?.toString(),
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount_minor': amountMinor,
      'coin_delta': coinDelta,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'ref': reference,
      'metadata': metadata,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}

/// Coin Package entity
class CoinPackage {
  final String id;
  final String name;
  final int coinAmount;
  final int priceMinor;
  final String currency;
  final bool isActive;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CoinPackage({
    required this.id,
    required this.name,
    required this.coinAmount,
    required this.priceMinor,
    required this.currency,
    required this.isActive,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  /// Price expressed in major units (e.g. XOF)
  double get priceMajor => priceMinor / 100.0;

  /// Whether the package has a visible description.
  bool get hasDescription => (description ?? '').trim().isNotEmpty;

  factory CoinPackage.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    DateTime? parseDate(dynamic raw) {
      if (raw == null) return null;
      if (raw is DateTime) return raw;
      return DateTime.tryParse(raw.toString());
    }

    final rawCoinAmount = json['coin_amount'] ?? json['coins'];
    final rawPriceMinor = json['price_minor'] ?? json['price'];

    return CoinPackage(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      coinAmount: parseInt(rawCoinAmount),
      priceMinor: parseInt(rawPriceMinor),
      currency: json['currency']?.toString() ?? 'XOF',
      isActive: json['is_active'] is bool
          ? json['is_active'] as bool
          : json['is_active'] == null
              ? true
              : json['is_active'].toString().toLowerCase() == 'true',
      description: json['description']?.toString(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coin_amount': coinAmount,
      'price_minor': priceMinor,
      'currency': currency,
      'is_active': isActive,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}




