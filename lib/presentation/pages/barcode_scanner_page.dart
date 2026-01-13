import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/voucher/bloc/voucher_bloc.dart';
import '../features/voucher/bloc/voucher_event.dart';
import '../features/voucher/bloc/voucher_state.dart';
import '../features/wallet/bloc/wallet_bloc.dart';
import '../features/wallet/bloc/wallet_state.dart';
import '../widgets/payment_method_dialog.dart';
import '../widgets/animations/custom_loader.dart';
import '../../generated/l10n/app_localizations.dart';

/// Barcode scanner page for purchasing vouchers by scanning barcode
class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final TextEditingController _barcodeController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    if (l10n == null) {
      return const Scaffold(
        body: const Center(child: AppLoader()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanBarcode),
        centerTitle: true,
      ),
      body: BlocListener<VoucherBloc, VoucherState>(
        listener: (context, state) {
          if (state is PurchaseSuccess) {
            setState(() => _isProcessing = false);
            final l10n = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n?.purchaseSuccess ?? 'Purchase successful!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is VoucherError) {
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 64,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n?.scanBarcode ?? 'Scan or enter a barcode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scannez le code-barres d\'un bon ou entrez-le manuellement pour l\'acheter.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Barcode Input
              TextField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: l10n.barcode ?? 'Barcode',
                  hintText: l10n.scanBarcode ?? 'Enter or scan barcode',
                  prefixIcon: const Icon(Icons.qr_code),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _barcodeController.clear(),
                  ),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                enabled: !_isProcessing,
              ),
              const SizedBox(height: 16),
              
              // Manual Entry Button
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : () => _handleBarcodeLookup(_barcodeController.text),
                icon: const Icon(Icons.search),
                label: Text(l10n.searchVoucher ?? 'Search Voucher'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              
              // Scan Button (Note: For full implementation, integrate a barcode scanner package)
              OutlinedButton.icon(
                onPressed: _isProcessing
                    ? null
                    : () {
                        // TODO: Integrate barcode scanner package (e.g., mobile_scanner)
                        // For now, show manual entry dialog
                        _showManualEntryDialog();
                      },
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(l10n.scanBarcode ?? 'Scan Barcode'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              
              if (_isProcessing) ...[
                const SizedBox(height: 24),
                const Center(child: AppLoader()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleBarcodeLookup(String barcode) async {
    final l10n = AppLocalizations.of(context);
    if (barcode.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.pleaseEnterBarcode ?? 'Please enter a barcode'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // First, get voucher by barcode
    context.read<VoucherBloc>().add(GetVoucherByBarcodeEvent(barcode.trim()));

    // Wait for voucher to load
    await Future.delayed(const Duration(milliseconds: 500));

    // Check state and proceed to purchase
    final voucherState = context.read<VoucherBloc>().state;
    if (voucherState is VoucherDetailsLoaded) {
      await _showPurchaseDialog(voucherState.voucher);
    } else if (voucherState is VoucherError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(voucherState.message),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _showPurchaseDialog(voucher) async {
    // Load wallet
    context.read<WalletBloc>().add(const LoadWalletEvent());

    final walletState = context.read<WalletBloc>().state;
    double walletBalance = 0;
    double coinBalance = 0;

    if (walletState is WalletLoaded) {
      walletBalance = walletState.wallet.balanceMinor;
      coinBalance = walletState.wallet.coins;
    }

    final paymentMethod = await PaymentMethodDialog.show(
      context,
      priceMinor: voucher.priceMinor,
      coinPrice: voucher.coinPrice,
      walletBalance: walletBalance,
      coinBalance: coinBalance,
    );

    if (paymentMethod == null) {
      setState(() => _isProcessing = false);
      return;
    }

    // Confirm purchase
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.confirmPurchase ?? 'Confirm Purchase'),
        content: Text(
          '${l10n.wantToBuyVoucher(voucher.title)}\n\n'
          '${l10n.barcode}: ${_barcodeController.text}\n'
          '${l10n.paymentMethod}: ${paymentMethod == 'wallet' ? l10n.walletPayment : paymentMethod == 'coins' ? l10n.coinsPayment : l10n.mixedPayment}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n?.confirm ?? 'Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Purchase by barcode
      context.read<VoucherBloc>().add(
        PurchaseVoucherByBarcodeEvent(
          _barcodeController.text.trim(),
          paymentMethod: paymentMethod,
        ),
      );
    } else {
      setState(() => _isProcessing = false);
    }
  }

  void _showManualEntryDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.manualEntryTitle ?? 'Manual Entry'),
        content: TextField(
          controller: _barcodeController,
          decoration: InputDecoration(
            labelText: l10n?.barcode ?? 'Barcode',
            hintText: l10n?.pleaseEnterBarcode ?? 'Enter barcode',
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleBarcodeLookup(_barcodeController.text);
            },
            child: Text(l10n?.searchVoucher ?? 'Search'),
          ),
        ],
      ),
    );
  }
}

