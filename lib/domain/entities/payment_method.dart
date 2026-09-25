/// A payment method option returned by GET /wallet/payment-methods.
///
/// `method` is the logical key sent back to the API when starting a top-up
/// (e.g. "orange_money"); `channel` is the underlying PaiementPro channel
/// (e.g. "OMCIV2"); `label` is the human-friendly display name.
class PaymentMethodOption {
  final String method;
  final String channel;
  final String label;

  const PaymentMethodOption({
    required this.method,
    required this.channel,
    required this.label,
  });

  factory PaymentMethodOption.fromJson(Map<String, dynamic> json) {
    return PaymentMethodOption(
      method: json['method']?.toString() ?? '',
      channel: json['channel']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

/// Result of POST /wallet/topup/paiementpro.
///
/// `flow` is "redirect" for PaiementPro (open [url] in the in-app WebView) or
/// "manual_link" for Wave: the user pays [amount] CFA through the merchant
/// link and an admin credits [coins] after checking the payment.
class TopupInitResult {
  final String url;
  final String flow;
  final int? amount;
  final int? coins;

  const TopupInitResult({
    required this.url,
    this.flow = 'redirect',
    this.amount,
    this.coins,
  });

  bool get isManualLink => flow == 'manual_link';
}
