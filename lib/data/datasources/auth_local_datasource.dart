import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/storage/secure_storage_service.dart';

/// Local data source for authentication operations
@injectable
class AuthLocalDataSource {
  final SharedPreferences _prefs;
  final SecureStorageService _secureStorage;

  AuthLocalDataSource(this._prefs, this._secureStorage);

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.saveAccessToken(token);
    await _prefs.remove(AppConstants.accessTokenKey); // cleanup legacy storage
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    final token = await _secureStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      return token;
    }

    // Migrate from legacy SharedPreferences storage if present
    final legacy = _prefs.getString(AppConstants.accessTokenKey);
    if (legacy != null && legacy.isNotEmpty) {
      await saveAccessToken(legacy);
      return legacy;
    }
    return null;
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.saveRefreshToken(token);
    await _prefs.remove(AppConstants.refreshTokenKey);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    final token = await _secureStorage.readRefreshToken();
    if (token != null && token.isNotEmpty) {
      return token;
    }

    final legacy = _prefs.getString(AppConstants.refreshTokenKey);
    if (legacy != null && legacy.isNotEmpty) {
      await saveRefreshToken(legacy);
      return legacy;
    }
    return null;
  }

  /// Save user role
  Future<void> saveUserRole(String role) async {
    await _prefs.setString(AppConstants.userRoleKey, role);
  }

  /// Get user role
  Future<String?> getUserRole() async {
    return _prefs.getString(AppConstants.userRoleKey);
  }

  /// Save first time login status
  Future<void> saveFirstTimeLogin(bool isFirstTime) async {
    await _prefs.setBool(AppConstants.firstTimeLoginKey, isFirstTime);
  }

  /// Get first time login status
  Future<bool> getFirstTimeLogin() async {
    return _prefs.getBool(AppConstants.firstTimeLoginKey) ?? false;
  }

  /// Clear all authentication data
  Future<void> clearAuthData() async {
    await _secureStorage.deleteTokens();
    await _prefs.remove(AppConstants.accessTokenKey);
    await _prefs.remove(AppConstants.refreshTokenKey);
    await _prefs.remove(AppConstants.userRoleKey);
    await _prefs.remove(AppConstants.firstTimeLoginKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}