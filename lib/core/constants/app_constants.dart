/// Application-wide constants and configuration
class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://72.61.163.98/api';
  static const String stagingBaseUrl = 'http://72.61.163.98/api';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';
  static const String languageKey = 'language';
  static const String firstTimeLoginKey = 'first_time_login';

  // User Roles
  static const String customerRole = 'client';
  static const String merchantRole = 'merchant';
  static const String adminRole = 'admin';

  // Supported Languages
  static const String defaultLanguage = 'fr';
  static const String englishLanguage = 'en';

  // API Endpoints
  static const String authPhoneOtpRequestEndpoint = '/auth/phone/otp/request';
  static const String authPhoneOtpVerifyEndpoint = '/auth/phone/otp/verify';
  static const String authRefreshEndpoint = '/auth/refresh';
  static const String authMeEndpoint = '/auth/me';

  static const String walletEndpoint = '/wallet';
  static const String walletTransactionsEndpoint = '/wallet/transactions';
  static const String walletPackagesEndpoint = '/wallet/packages';
  static const String walletTopupEndpoint = '/wallet/topup';
  static const String walletPaiementProTopupEndpoint = '/wallet/topup/paiementpro';

  static const String vouchersEndpoint = '/vouchers';
  static const String purchasesEndpoint = '/purchases';
  static const String sponsoredEndpoint = '/sponsored'; // Public endpoint
  static const String redeemEndpoint = '/redeem';
  static const String redemptionsEndpoint = '/redeem/history';

  static const String businessPartnersEndpoint = '/business/partners';
  static const String businessDetailEndpoint = '/business';
  static const String businessVouchersEndpoint =
      '/business'; // /business/{business_id}/vouchers
  static const String businessOptionsEndpoint = '/business/options';

  static const String uploadBusinessLogoEndpoint = '/uploads/business/logo';
  static const String uploadVoucherImageEndpoint = '/uploads/voucher/image';
  static const String uploadSponsoredImageEndpoint = '/uploads/sponsored/image';
  static const String uploadUserProfileImageEndpoint = '/uploads/user/profile';
  static const String authPasswordChangeEndpoint = '/auth/password/change';

  // HTTP Status Codes
  static const int httpOk = 200;
  static const int httpCreated = 201;
  static const int httpUnauthorized = 401;
  static const int httpForbidden = 403;
  static const int httpNotFound = 404;
  static const int httpUnprocessableEntity = 422;

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minPhoneLength = 8;
  static const int maxPhoneLength = 15;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // OTP Configuration
  static const int otpLength = 4;
  static const String devOtpCode = '1234';
}
