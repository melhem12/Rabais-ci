import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';

/// Payment method selection dialog
class PaymentMethodDialog extends StatelessWidget {
  final double priceMinor;
  final double coinPrice;
  final double walletBalance;
  final double coinBalance;

  const PaymentMethodDialog({
    super.key,
    required this.priceMinor,
    required this.coinPrice,
    required this.walletBalance,
    required this.coinBalance,
  });

  static Future<String?> show(
    BuildContext context, {
    required double priceMinor,
    required double coinPrice,
    required double walletBalance,
    required double coinBalance,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => PaymentMethodDialog(
        priceMinor: priceMinor,
        coinPrice: coinPrice,
        walletBalance: walletBalance,
        coinBalance: coinBalance,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const SizedBox.shrink();
    }
    
    final canPayWithWallet = walletBalance >= priceMinor && priceMinor > 0;
    final canPayWithCoins = coinBalance >= coinPrice && coinPrice > 0;
    final canPayWithMixed = walletBalance < priceMinor && 
                           coinBalance < coinPrice && 
                           (walletBalance + (coinBalance * (priceMinor / coinPrice))) >= priceMinor;

    return AlertDialog(
      title: Text(l10n.choosePaymentMethod),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (priceMinor > 0) ...[
              _buildPaymentOption(
                context,
                l10n.walletPayment,
                '${priceMinor.toStringAsFixed(0)} XOF',
                canPayWithWallet,
                'wallet',
                Icons.account_balance_wallet,
                Colors.blue,
              ),
              const SizedBox(height: 12),
            ],
            if (coinPrice > 0) ...[
              _buildPaymentOption(
                context,
                l10n.coinsPayment,
                '${coinPrice.toStringAsFixed(0)} coins',
                canPayWithCoins,
                'coins',
                Icons.monetization_on,
                Colors.orange,
              ),
              const SizedBox(height: 12),
            ],
            if (canPayWithMixed && priceMinor > 0 && coinPrice > 0) ...[
              _buildPaymentOption(
                context,
                l10n.mixedPayment,
                l10n.walletAndCoins,
                canPayWithMixed,
                'mixed',
                Icons.swap_horiz,
                Colors.purple,
              ),
            ],
            if (!canPayWithWallet && !canPayWithCoins && !canPayWithMixed) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.insufficientBalance,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    String title,
    String amount,
    bool isEnabled,
    String value,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: isEnabled
          ? () => Navigator.of(context).pop(value)
          : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEnabled ? color.withOpacity(0.1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEnabled ? color : Colors.grey,
            width: isEnabled ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isEnabled ? color : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isEnabled ? null : Colors.grey,
                    ),
                  ),
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 14,
                      color: isEnabled ? Colors.grey[700] : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isEnabled)
              Icon(Icons.check_circle, color: color)
            else
              Icon(Icons.cancel, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

