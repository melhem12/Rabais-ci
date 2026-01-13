import 'package:flutter/material.dart';

// Import the actual auth pages
export 'auth/login_page.dart';
export 'auth/register_page.dart';
export 'auth/otp_verification_page.dart';
export 'auth/profile_completion_page.dart';

/// Home page placeholder
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: const Center(
        child: Text('Home Page - To be implemented'),
      ),
    );
  }
}

/// Wallet page placeholder
class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portefeuille')),
      body: const Center(
        child: Text('Wallet Page - To be implemented'),
      ),
    );
  }
}

/// Vouchers page placeholder
class VouchersPage extends StatelessWidget {
  const VouchersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bons')),
      body: const Center(
        child: Text('Vouchers Page - To be implemented'),
      ),
    );
  }
}

/// Purchases page placeholder
class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achats')),
      body: const Center(
        child: Text('Purchases Page - To be implemented'),
      ),
    );
  }
}

/// Profile page placeholder
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const Center(
        child: Text('Profile Page - To be implemented'),
      ),
    );
  }
}

/// Merchant redemption page placeholder
class MerchantRedemptionPage extends StatelessWidget {
  const MerchantRedemptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Échange')),
      body: const Center(
        child: Text('Merchant Redemption Page - To be implemented'),
      ),
    );
  }
}
