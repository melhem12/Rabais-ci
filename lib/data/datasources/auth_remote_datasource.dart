import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/refresh_token_exception.dart';

/// Remote data source for authentication operations
@injectable
class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  /// Request OTP for phone number
  Future<OtpRequestResponse> requestOtp(String phone) async {
    try {
      final response = await _apiClient.dio.post(
        AppConstants.authPhoneOtpRequestEndpoint,
        data: {'phone': phone},
      );

      if (response.statusCode == AppConstants.httpOk || 
          response.statusCode == AppConstants.httpCreated) {
        return OtpRequestResponse.fromJson(response.data);
      } else {
        final errorMsg = response.data is Map<String, dynamic>
            ? (response.data['detail'] ?? response.data['message'] ?? 'OTP request failed')
            : 'OTP request failed';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      // Extract detailed error message from response
      String errorMessage = 'Network error occurred';

      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['detail'] ??
              responseData['message'] ??
              'Request failed with status ${e.response?.statusCode}';
        } else if (responseData is String) {
          errorMessage = responseData;
        } else {
          errorMessage = 'Request failed with status ${e.response?.statusCode}';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      } else {
        errorMessage = e.message ?? 'Network error occurred';
      }

      throw Exception(errorMessage);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(e.toString());
    }
  }

  /// Verify OTP and get authentication session
  Future<AuthSession> verifyOtp(String phone, String otp) async {
    try {
      final response = await _apiClient.dio.post(
        AppConstants.authPhoneOtpVerifyEndpoint,
        data: {
          'phone': phone,
          'otp': otp,
        },
      );

      if (response.statusCode == AppConstants.httpOk || 
          response.statusCode == AppConstants.httpCreated) {
        return AuthSession.fromJson(response.data);
      } else {
        final errorMsg = response.data is Map<String, dynamic>
            ? (response.data['detail'] ?? response.data['message'] ?? 'OTP verification failed')
            : 'OTP verification failed';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      // Extract detailed error message from response
      String errorMessage = 'Network error occurred';
      
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['detail'] ?? 
                        responseData['message'] ?? 
                        'Verification failed with status ${e.response?.statusCode}';
        } else if (responseData is String) {
          errorMessage = responseData;
        } else {
          errorMessage = 'Verification failed with status ${e.response?.statusCode}';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      } else {
        errorMessage = e.message ?? 'Network error occurred';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unknown error: $e');
    }
  }

  /// Refresh the authentication session using the refresh token
  Future<TokenRefreshResult> refreshSession(String refreshToken) async {
    try {
      final response = await _apiClient.dio.post(
        AppConstants.authRefreshEndpoint,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == AppConstants.httpOk) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : const <String, dynamic>{};
        return TokenRefreshResult(
          accessToken: data['access_token'] as String? ?? '',
          refreshToken: data['refresh_token'] as String?,
          tokenType: data['token_type'] as String? ?? 'bearer',
        );
      } else {
        final errorMsg = response.data is Map<String, dynamic>
            ? (response.data['detail'] ??
                response.data['message'] ??
                'Token refresh failed')
            : 'Token refresh failed';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';

      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['detail'] ??
              responseData['message'] ??
              'Token refresh failed with status ${e.response?.statusCode}';
        } else if (responseData is String) {
          errorMessage = responseData;
        } else {
          errorMessage =
              'Token refresh failed with status ${e.response?.statusCode}';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      final statusCode = e.response?.statusCode;
      final detail = e.response is Map
          ? e.response?.data['detail']?.toString()
          : null;
      final isInvalidToken = statusCode == AppConstants.httpUnauthorized ||
          statusCode == AppConstants.httpForbidden ||
          statusCode == 400;

      // ignore: avoid_print
      print('[AuthRemoteDataSource] refreshSession failed (status: $statusCode, detail: ${detail ?? errorMessage})');

      throw RefreshTokenException(
        message: detail ?? errorMessage,
        isInvalidToken: isInvalidToken,
      );
    } catch (e) {
      if (e is RefreshTokenException) rethrow;
      throw RefreshTokenException(message: e.toString(), isInvalidToken: false);
    }
  }

  /// Get current user information
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get(AppConstants.authMeEndpoint);

      if (response.statusCode == AppConstants.httpOk) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Failed to get user info: ${response.data['detail']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  /// Update user profile
  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiClient.dio.put(
        AppConstants.authMeEndpoint,
        data: profileData,
      );

      if (response.statusCode == AppConstants.httpOk) {
        return User.fromJson(response.data);
      } else {
        final errorMessage = response.data is Map<String, dynamic> 
            ? response.data['detail'] ?? 'Profile update failed'
            : 'Profile update failed';
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  /// Upload profile image
  Future<String> uploadProfileImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final fileName = file.path.split('/').last;
      
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        ),
      });

      final response = await _apiClient.dio.post(
        AppConstants.uploadUserProfileImageEndpoint,
        data: formData,
      );

      if (response.statusCode == AppConstants.httpOk || 
          response.statusCode == AppConstants.httpCreated) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        return data['url'] as String? ?? '';
      } else {
        final errorMessage = response.data is Map<String, dynamic>
            ? response.data['detail'] ?? 'Image upload failed'
            : 'Image upload failed';
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  /// Change password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _apiClient.dio.post(
        AppConstants.authPasswordChangeEndpoint,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == AppConstants.httpOk) {
        return;
      } else {
        final errorMessage = response.data is Map<String, dynamic>
            ? response.data['detail'] ?? 'Password change failed'
            : 'Password change failed';
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data is Map<String, dynamic>
          ? e.response?.data['detail'] ?? e.message ?? 'Password change failed'
          : e.message ?? 'Password change failed';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }
}
