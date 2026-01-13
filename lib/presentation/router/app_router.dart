import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_event.dart';
import '../features/auth/bloc/auth_state.dart';
import '../pages/splash_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/otp_verification_page.dart';
import '../pages/auth/profile_completion_page.dart';
import '../pages/customer_home_page.dart';
import '../pages/merchant_home_page.dart';

/// Application router configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) => const OtpVerificationPage(),
      ),
      GoRoute(
        path: '/profile-completion',
        builder: (context, state) => const ProfileCompletionPage(),
      ),
      GoRoute(
        path: '/customer-home',
        builder: (context, state) => const CustomerHomePage(),
      ),
      GoRoute(
        path: '/merchant-home',
        builder: (context, state) => const MerchantHomePage(),
      ),
    ],
  );
}