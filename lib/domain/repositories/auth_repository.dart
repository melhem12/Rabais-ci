import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Register a new user
  Future<Either<Failure, AuthResult>> register(RegistrationData data);

  /// Login with credentials
  Future<Either<Failure, AuthResult>> login(LoginCredentials credentials);

  /// Logout the current user
  Future<Either<Failure, void>> logout();

  /// Refresh authentication token
  Future<Either<Failure, AuthResult>> refreshToken();

  /// Get current user information
  Future<Either<Failure, User>> getCurrentUser();

  /// Verify OTP code
  Future<Either<Failure, AuthResult>> verifyOtp(OtpVerificationData data);

  /// Resend OTP code
  Future<Either<Failure, void>> resendOtp(String email);

  /// Complete user profile
  Future<Either<Failure, User>> completeProfile(ProfileCompletionData data);

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get stored access token
  Future<String?> getAccessToken();

  /// Get stored refresh token
  Future<String?> getRefreshToken();

  /// Save authentication tokens
  Future<void> saveTokens(String accessToken, String refreshToken);

  /// Clear stored tokens
  Future<void> clearTokens();

  /// Save user role
  Future<void> saveUserRole(String role);

  /// Get stored user role
  Future<String?> getUserRole();

  /// Check if user has completed profile
  Future<bool> hasCompletedProfile();
}
