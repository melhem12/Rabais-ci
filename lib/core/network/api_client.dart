import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../errors/refresh_token_exception.dart';
import '../storage/secure_storage_service.dart';

/// Dio client configuration for API communication
@injectable
class ApiClient {
  late final Dio _dio;
  final SharedPreferences _prefs;
  final SecureStorageService _secureStorage;

  ApiClient(this._prefs, this._secureStorage) {
    _dio = Dio();
    _setupInterceptors();
  }

  /// Configure Dio with base options and interceptors
  void _setupInterceptors() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add auth interceptor
    _dio.interceptors.add(_AuthInterceptor(_prefs, _secureStorage, _dio));

    // Add logging interceptor (only in debug mode)
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('API: $obj'),
      ));
    }
  }

  /// Get the configured Dio instance
  Dio get dio => _dio;
}

/// Authentication interceptor for adding tokens to requests
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._prefs, this._secureStorage, this._dio)
      : _refreshClient = Dio(
          BaseOptions(
            baseUrl: AppConstants.baseUrl,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            connectTimeout: AppConstants.connectTimeout,
            receiveTimeout: AppConstants.receiveTimeout,
            sendTimeout: AppConstants.sendTimeout,
          ),
        );

  final SharedPreferences _prefs;
  final SecureStorageService _secureStorage;
  final Dio _dio;
  final Dio _refreshClient;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.readAccessToken();
    if (token != null && token.isNotEmpty && !_isPublicEndpoint(options.path)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_shouldAttemptRefresh(err)) {
      handler.next(err);
      return;
    }

    final refreshToken = await _secureStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _handleRefreshFailure();
      handler.next(err);
      return;
    }

    final completer = Completer<Response<dynamic>>();
    _pendingRequests.add(_PendingRequest(err.requestOptions, completer));

    if (!_isRefreshing) {
      _isRefreshing = true;
      try {
        final response = await _refreshClient.post(
          AppConstants.authRefreshEndpoint,
          data: {'refresh_token': refreshToken},
        );
        // ignore: avoid_print
        print('[AuthInterceptor] refresh payload sent: ${response.requestOptions.data}');

        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : const <String, dynamic>{};

        final newAccessToken = data['access_token'] as String? ?? '';
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken.isEmpty) {
          throw RefreshTokenException(
            message: 'Token refresh failed: empty access token',
            isInvalidToken: true,
          );
        }

        await _secureStorage.saveAccessToken(newAccessToken);
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await _secureStorage.saveRefreshToken(newRefreshToken);
        }

        // ignore: avoid_print
        print('[AuthInterceptor] refresh succeeded: access(${newAccessToken.length}), refresh(${newRefreshToken?.length ?? 0})');

        for (final pending in _pendingRequests) {
          final updatedHeaders = Map<String, dynamic>.from(pending.requestOptions.headers);
          updatedHeaders['Authorization'] = 'Bearer $newAccessToken';

          final clonedOptions = pending.requestOptions.copyWith(headers: updatedHeaders);
          try {
            final replayResponse = await _dio.fetch<dynamic>(clonedOptions);
            pending.completer.complete(replayResponse);
          } catch (error) {
            pending.completer.completeError(error);
          }
        }
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        final detail = e.response?.data is Map<String, dynamic>
            ? e.response?.data['detail']?.toString()
            : null;
        final refreshError = RefreshTokenException(
          message: detail ?? e.message ?? 'Token refresh failed',
          isInvalidToken: status == AppConstants.httpUnauthorized ||
              status == AppConstants.httpForbidden ||
              status == 400,
        );
        // ignore: avoid_print
        print('[AuthInterceptor] Refresh failed (status: $status, detail: ${refreshError.message})');
        await _handleRefreshFailure();
        for (final pending in _pendingRequests) {
          pending.completer.completeError(refreshError);
        }
      } on RefreshTokenException catch (e) {
        await _handleRefreshFailure();
        for (final pending in _pendingRequests) {
          pending.completer.completeError(e);
        }
      } catch (error) {
        for (final pending in _pendingRequests) {
          pending.completer.completeError(error);
        }
      } finally {
        _pendingRequests.clear();
        _isRefreshing = false;
      }
    }

    try {
      final response = await completer.future;
      handler.resolve(response);
    } on RefreshTokenException catch (e) {
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: e,
          type: DioExceptionType.badResponse,
          response: err.response,
        ),
      );
    } catch (error) {
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: error,
          type: DioExceptionType.unknown,
          response: err.response,
        ),
      );
    }
  }

  /// Determine whether an endpoint is public (no auth header required)
  bool _isPublicEndpoint(String path) {
    const publicPrefixes = [
      '/auth/phone/otp',
      '/auth/login',
      '/business/partners',
      '/sponsored',
    ];

    return publicPrefixes.any((prefix) => path.startsWith(prefix));
  }

  bool _shouldAttemptRefresh(DioException err) {
    if (err.requestOptions.path == AppConstants.authRefreshEndpoint) {
      return false;
    }

    if (_isPublicEndpoint(err.requestOptions.path)) {
      return false;
    }

    final statusCode = err.response?.statusCode;
    return statusCode == AppConstants.httpUnauthorized;
  }

  Future<void> _handleRefreshFailure() async {
    await _secureStorage.deleteTokens();
    await _prefs.remove(AppConstants.accessTokenKey);
    await _prefs.remove(AppConstants.refreshTokenKey);
    await _prefs.remove(AppConstants.userRoleKey);
    await _prefs.remove(AppConstants.firstTimeLoginKey);
  }
}

class _PendingRequest {
  _PendingRequest(this.requestOptions, this.completer);

  final RequestOptions requestOptions;
  final Completer<Response<dynamic>> completer;
}
