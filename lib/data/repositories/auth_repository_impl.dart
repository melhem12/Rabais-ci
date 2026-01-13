import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../../core/errors/refresh_token_exception.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  Future<OtpRequestResponse> requestOtp(String phone);
  Future<AuthSession> verifyOtp(String phone, String otp);
  Future<User> getCurrentUser();
  Future<User> updateProfile(Map<String, dynamic> profileData);
  Future<String> uploadProfileImage(String imagePath);
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<String?> getAccessToken();
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<TokenRefreshResult?> refreshSession();
  Future<void> clearStoredSession();
}

/// Implementation of AuthRepository
@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<OtpRequestResponse> requestOtp(String phone) async {
    try {
      return await _remoteDataSource.requestOtp(phone);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<AuthSession> verifyOtp(String phone, String otp) async {
    try {
      final result = await _remoteDataSource.verifyOtp(phone, otp);

      if (result.accessToken.isEmpty || result.refreshToken.isEmpty) {
        throw ServerFailure(message: 'Authentication session missing tokens');
      }

      // Debug log for token receipt
      // ignore: avoid_print
      print('[AuthRepository] verifyOtp received tokens: access(${result.accessToken.length}), refresh(${result.refreshToken.length})');

      // Save tokens locally
      await _localDataSource.saveAccessToken(result.accessToken);
      await _localDataSource.saveRefreshToken(result.refreshToken);
      await _localDataSource.saveUserRole(result.user.role);
      await _localDataSource.saveFirstTimeLogin(result.user.firstTimeLogin);

      return result;
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      return await _remoteDataSource.getCurrentUser();
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final user = await _remoteDataSource.updateProfile(profileData);
      // After profile update, save firstTimeLogin status locally
      // The backend should return firstTimeLogin = false after profile completion
      await _localDataSource.saveFirstTimeLogin(user.firstTimeLogin);
      return user;
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearAuthData();
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _localDataSource.isAuthenticated();
  }

  @override
  Future<String?> getAccessToken() async {
    return await _localDataSource.getAccessToken();
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw ServerFailure(message: 'Cannot persist empty authentication tokens');
    }
    // ignore: avoid_print
    print('[AuthRepository] saveTokens access(${accessToken.length}), refresh(${refreshToken.length})');
    await _localDataSource.saveAccessToken(accessToken);
    await _localDataSource.saveRefreshToken(refreshToken);
  }

  @override
  Future<TokenRefreshResult?> refreshSession() async {
    final refreshToken = await _localDataSource.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final result = await _remoteDataSource.refreshSession(refreshToken);

      if (result.accessToken.isEmpty) {
        throw ServerFailure(message: 'Token refresh failed: empty access token');
      }

      await _localDataSource.saveAccessToken(result.accessToken);

      if (result.refreshToken != null && result.refreshToken!.isNotEmpty) {
        // ignore: avoid_print
        print('[AuthRepository] refreshSession received tokens: access(${result.accessToken.length}), refresh(${result.refreshToken!.length})');
        await _localDataSource.saveRefreshToken(result.refreshToken!);
      } else {
        // Backend should always rotate refresh tokens; treat missing value as invalid
        throw RefreshTokenException(
          message: 'Token refresh response missing refresh token',
          isInvalidToken: true,
        );
      }

      return result;
    } on RefreshTokenException catch (e) {
      if (e.isInvalidToken) {
        await _localDataSource.clearAuthData();
      }
      rethrow;
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<void> clearStoredSession() async {
    await _localDataSource.clearAuthData();
  }

  @override
  Future<String> uploadProfileImage(String imagePath) async {
    try {
      return await _remoteDataSource.uploadProfileImage(imagePath);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await _remoteDataSource.changePassword(oldPassword, newPassword);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}