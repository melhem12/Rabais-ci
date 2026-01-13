import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_state.dart';
import '../features/wallet/bloc/wallet_bloc.dart';
import '../features/wallet/bloc/wallet_event.dart';
import '../features/wallet/bloc/wallet_state.dart';
import '../features/business/bloc/business_bloc.dart';
import '../features/business/bloc/business_event.dart';
import '../features/business/bloc/business_state.dart';
import '../features/purchase/bloc/purchase_bloc.dart';
import '../features/purchase/bloc/purchase_event.dart';
import '../features/purchase/bloc/purchase_state.dart';
import '../../domain/entities/voucher.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../../core/utils/image_url_helper.dart';
import '../../core/theme/app_theme.dart';
import 'wallet_page.dart';
import 'vouchers_page.dart';
import 'settings_page.dart';
import 'partners_directory_page.dart';
import '../../core/theme/app_icons.dart';
import '../widgets/navigation_drawer.dart';
import '../widgets/animations/fade_in_widget.dart';
import '../widgets/animations/slide_in_widget.dart';
import '../widgets/animations/scale_tap_widget.dart';
import '../widgets/animations/custom_loader.dart';

/// Customer home page
class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();

  @override
  void initState() {
    super.initState();
    // Load wallet data when the page initializes
    context.read<WalletBloc>().add(const LoadWalletEvent());
    // Load sponsored banners
    context.read<BusinessBloc>().add(const LoadSponsoredBannersEvent());
    // Load purchases to get coupons count
    context.read<PurchaseBloc>().add(const LoadPurchasesEvent());
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      drawer: const AppNavigationDrawer(),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/mylogo.png',
              height: 24,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Text(
              'Rabaisci',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryTurquoise,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return RefreshIndicator(
                      onRefresh: () async {
                        context.read<WalletBloc>().add(const LoadWalletEvent());
                        context.read<BusinessBloc>().add(const LoadSponsoredBannersEvent());
                      },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card - Username clickable to Profile
                    FadeInWidget(
                      delay: 0.1,
                      child: SlideInWidget(
                        delay: 0.1,
                        begin: const Offset(0, -0.2),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primaryOrange.withOpacity(0.1),
                                  AppTheme.primaryTurquoise.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: ScaleTapWidget(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => const SettingsPage(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        )),
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 300),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.welcome,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${state.user.firstName ?? l10n.customer}!',
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryOrange.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                        color: AppTheme.primaryOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                            const SizedBox(height: 24),
                            
                            // Sponsored Banners Carousel
                            BlocBuilder<BusinessBloc, BusinessState>(
                              builder: (context, businessState) {
                                if (businessState is SponsoredBannersLoaded) {
                                  if (businessState.banners.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return _buildSponsoredBannersCarousel(context, businessState.banners);
                                } else if (businessState is BusinessLoading) {
                                  return Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: AppLoader(),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            
                            const SizedBox(height: 24),
                    
                    // Wallet Summary Card - Clickable to Wallet page
                    BlocBuilder<WalletBloc, WalletState>(
                      builder: (context, walletState) {
                        if (walletState is WalletLoaded) {
                          return FadeInWidget(
                            delay: 0.2,
                            child: SlideInWidget(
                              delay: 0.2,
                              begin: const Offset(0, 0.2),
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white,
                                        AppTheme.primaryTurquoise.withOpacity(0.05),
                                      ],
                                    ),
                                  ),
                                  child: ScaleTapWidget(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) => const WalletPage(),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            return SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(1.0, 0.0),
                                                end: Offset.zero,
                                              ).animate(CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutCubic,
                                              )),
                                              child: FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              ),
                                            );
                                          },
                                          transitionDuration: const Duration(milliseconds: 300),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: const Icon(
                                                      Icons.account_balance_wallet,
                                                      color: Colors.blue,
                                                      size: 24,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    l10n.wallet,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Coins
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      l10n.coins,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${walletState.wallet.coins.toInt()}',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Coupons count from purchases
                                              Expanded(
                                                child: BlocBuilder<PurchaseBloc, PurchaseState>(
                                                  builder: (context, purchaseState) {
                                                    int couponsCount = 0;
                                                    
                                                    if (purchaseState is PurchasesLoaded) {
                                                      // Count all purchased coupons (bought vouchers)
                                                      // Show total count of all purchases, regardless of redemption status
                                                      couponsCount = purchaseState.purchases.length;
                                                    } else if (purchaseState is PurchaseLoading) {
                                                      // Show loading indicator while fetching
                                                      return Column(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            'Coupons', // Will be localized
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.grey[600],
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          const AppLoader(size: 16),
                                                        ],
                                                      );
                                                    }
                                                    
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          'Coupons', // Will be localized
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey[600],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          '$couponsCount',
                                                          style: const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.orange,
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else if (walletState is WalletLoading) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.account_balance_wallet, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.wallet,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: const AppLoader(size: 20),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (walletState is WalletError) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.error, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      walletState.message,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.read<WalletBloc>().add(const LoadWalletEvent());
                                    },
                                    child: Text(l10n.retry),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    FadeInWidget(
                      delay: 0.3,
                      child: Text(
                        l10n.availableFeatures,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Feature Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        FadeInWidget(
                          delay: 0.35,
                          child: SlideInWidget(
                            delay: 0.35,
                            begin: const Offset(-0.2, 0),
                            child: _buildThemedFeatureCard(
                              context,
                              l10n.wallet,
                              AppIcons.walletIcon,
                              () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => const WalletPage(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        )),
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 300),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        FadeInWidget(
                          delay: 0.4,
                          child: SlideInWidget(
                            delay: 0.4,
                            begin: const Offset(0.2, 0),
                            child: _buildThemedFeatureCard(
                              context,
                              'Coupons',
                              AppIcons.voucherIcon,
                              () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => const VouchersPage(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        )),
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 300),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        FadeInWidget(
                          delay: 0.45,
                          child: SlideInWidget(
                            delay: 0.45,
                            begin: const Offset(-0.2, 0),
                            child: _buildThemedFeatureCard(
                              context,
                              l10n.merchantPartners,
                              AppIcons.businessIcon,
                              () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => const PartnersDirectoryPage(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        )),
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 300),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        FadeInWidget(
                          delay: 0.5,
                          child: SlideInWidget(
                            delay: 0.5,
                            begin: const Offset(0.2, 0),
                            child: _buildThemedFeatureCard(
                              context,
                              l10n.profile,
                              AppIcons.profileIcon,
                              () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => const SettingsPage(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        )),
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 300),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: AppLoader());
        },
      ),
    );
  }

  Widget _buildThemedFeatureCard(
    BuildContext context,
    String title,
    Widget Function({double size, Color? color}) iconBuilder,
    VoidCallback onTap,
  ) {
    return ScaleTapWidget(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                AppTheme.primaryOrange.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: iconBuilder(size: 32, color: AppTheme.primaryOrange),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSponsoredBannersCarousel(BuildContext context, List<SponsoredBanner> banners) {
    final l10n = AppLocalizations.of(context);
    
    // Randomize first banner on each launch
    final shuffledBanners = List<SponsoredBanner>.from(banners);
    if (shuffledBanners.length > 1) {
      shuffledBanners.shuffle();
      // Reset to first page if controller is attached
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_bannerController.hasClients) {
          _bannerController.jumpToPage(0);
        }
      });
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.specialOffers,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              PageView.builder(
                controller: _bannerController,
                itemCount: shuffledBanners.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentBannerIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final banner = shuffledBanners[index];
                  // Use image_url if available, fallback to business_logo_url
                  final imageUrl = banner.imageUrl ?? banner.businessLogoUrl;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        // Navigate to vouchers page filtered by business_id
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VouchersPage(
                              businessId: banner.businessId,
                              businessName: banner.businessName,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[200],
                          image: imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(ImageUrlHelper.buildImageUrl(imageUrl)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                banner.businessName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.discoverExclusive,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Carousel indicators (3 dots)
              if (shuffledBanners.length > 1)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      shuffledBanners.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentBannerIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
