import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/localization_service.dart';
import '../../generated/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_state.dart';
import '../features/auth/bloc/auth_event.dart';
import '../pages/splash_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/otp_verification_page.dart';
import '../pages/auth/profile_completion_page.dart';
import '../pages/customer_home_page.dart';
import '../pages/merchant_home_page.dart';

/// A widget that properly handles locale changes by forcing complete rebuilds
class LocalizedApp extends StatefulWidget {
  final Locale locale;

  const LocalizedApp({
    super.key,
    required this.locale,
  });

  @override
  State<LocalizedApp> createState() => _LocalizedAppState();
}

class _LocalizedAppState extends State<LocalizedApp> with WidgetsBindingObserver {
  late GlobalKey<NavigatorState> _navigatorKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _navigatorKey = GlobalKey<NavigatorState>();
    // Add a small delay to ensure state is stable before checking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _refreshSession();
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshSession();
    }
  }

  void _refreshSession() {
    if (!mounted) return;
    final currentState = context.read<AuthBloc>().state;
    // Don't refresh session if:
    // 1. We're in the middle of OTP flow or loading
    // 2. We're not authenticated (Unauthenticated or AuthInitial)
    // This prevents unnecessary API calls when user hasn't logged in
    if (currentState is OtpVerificationRequired || 
        currentState is AuthLoading ||
        currentState is Unauthenticated ||
        currentState is AuthInitial) {
      return;
    }
    // Only refresh if we're authenticated or in a state that needs it
    context.read<AuthBloc>().add(const RefreshSessionEvent());
  }

  @override
  void didUpdateWidget(LocalizedApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale != widget.locale) {
      // Force a complete rebuild when locale changes
      setState(() {
        _navigatorKey = GlobalKey<NavigatorState>();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('LocalizedApp: Building with locale: ${widget.locale.languageCode}');
    return MaterialApp(
      key: ValueKey(widget.locale.languageCode), // Force rebuild when locale changes
      navigatorKey: _navigatorKey,
      title: 'RABAIS CI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      locale: widget.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,
      home: const RouterWrapper(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}

/// A wrapper that handles routing manually
class RouterWrapper extends StatefulWidget {
  const RouterWrapper({super.key});

  @override
  State<RouterWrapper> createState() => _RouterWrapperState();
}

class _RouterWrapperState extends State<RouterWrapper> {
  AuthState? _lastNonLoadingState;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Track the last non-loading state to preserve context during loading
        if (state is! AuthLoading) {
          _lastNonLoadingState = state;
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            if (state.user.role == 'merchant') {
              return const MerchantHomePage();
            }
            return const CustomerHomePage();
          } else if (state is ProfileCompletionRequired) {
            return const ProfileCompletionPage();
          } else if (state is OtpVerificationRequired) {
            return OtpVerificationPage(
              phone: state.phone,
              otpResponse: state.response,
            );
          } else if (state is AuthLoading) {
            // During loading, preserve the current page context
            // This prevents showing login page during OTP verification
            if (_lastNonLoadingState is OtpVerificationRequired) {
              final lastState = _lastNonLoadingState as OtpVerificationRequired;
              return OtpVerificationPage(
                phone: lastState.phone,
                otpResponse: lastState.response,
              );
            } else if (_lastNonLoadingState is Authenticated) {
              final lastState = _lastNonLoadingState as Authenticated;
              if (lastState.user.role == 'merchant') {
                return const MerchantHomePage();
              }
              return const CustomerHomePage();
            } else if (_lastNonLoadingState is ProfileCompletionRequired) {
              return const ProfileCompletionPage();
            }
            // Default to splash during loading if no previous state
            return const SplashPage();
          } else if (state is Unauthenticated) {
            return const LoginPage();
          } else {
            return const SplashPage();
          }
        },
      ),
    );
  }
}

/// A widget that can restart the entire app
class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({super.key, required this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key _key = UniqueKey();

  void restartApp() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}