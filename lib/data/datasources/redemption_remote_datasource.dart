import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/redemption.dart';
import '../../core/network/api_client.dart';

/// Remote data source for redemption operations (merchant)
@injectable
class RedemptionRemoteDataSource {
  final ApiClient _apiClient;

  RedemptionRemoteDataSource(this._apiClient);

  /// Redeem a voucher using QR code or manual code
  Future<RedemptionResponse> redeemVoucher({String? code, String? barcode}) async {
    if ((code == null || code.isEmpty) && (barcode == null || barcode.isEmpty)) {
      throw Exception('Code or barcode must be provided');
    }

    final payload = <String, String>{};
    if (code != null && code.isNotEmpty) {
      payload['code'] = code;
    }
    if (barcode != null && barcode.isNotEmpty) {
      payload['barcode'] = barcode;
    }

    try {
      // Log the payload to help debug invalid-code reports (scanner vs manual entry)
      // ignore: avoid_print
      print('[Redeem API] POST body -> $payload');

      final response = await _apiClient.dio.post(
        AppConstants.redeemEndpoint,
        data: payload,
      );

      if (response.statusCode == AppConstants.httpOk) {
        return RedemptionResponse.fromJson(response.data);
      } else {
        // Extract error message from response - prioritize backend message
        String errorMsg = 'Failed to redeem voucher';
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          if (data.containsKey('detail')) {
            final detail = data['detail'];
            if (detail is String) {
              errorMsg = detail;
            } else if (detail is List && detail.isNotEmpty) {
              final firstError = detail[0];
              if (firstError is Map && firstError.containsKey('msg')) {
                errorMsg = firstError['msg'] as String;
              } else if (firstError is Map && firstError.containsKey('message')) {
                errorMsg = firstError['message'] as String;
              }
            }
          } else if (data.containsKey('message')) {
            errorMsg = data['message'] as String;
          }
        }
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      // Extract detailed error message from response - prioritize backend message
      String errorMessage = 'Failed to redeem voucher';
      if (e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          // Prioritize 'detail' field (most common in API responses)
          if (responseData.containsKey('detail')) {
            final detail = responseData['detail'];
            if (detail is String) {
              errorMessage = detail;
            } else if (detail is List && detail.isNotEmpty) {
              final firstError = detail[0];
              if (firstError is Map && firstError.containsKey('msg')) {
                errorMessage = firstError['msg'] as String;
              } else if (firstError is Map && firstError.containsKey('message')) {
                errorMessage = firstError['message'] as String;
              } else {
                errorMessage = detail.toString();
              }
            } else {
              errorMessage = detail.toString();
            }
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'] as String;
          } else if (responseData.containsKey('error')) {
            errorMessage = responseData['error'] as String;
          }
        } else if (responseData is String) {
          // Sometimes APIs return plain string error messages
          errorMessage = responseData;
        }
      } else if (e.message != null) {
        // Only use generic network error if no backend message available
        errorMessage = 'Network error: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      // Preserve the original error message
      if (e is Exception) {
        rethrow;
      }
      throw Exception(e.toString());
    }
  }

  /// Get redemption history
  Future<List<Redemption>> getRedemptions({
    int page = 1,
    int limit = 20,
    String? startDate,
    String? endDate,
    String? status,
    String? method,
    String? businessId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (method != null && method.isNotEmpty) queryParams['method'] = method;
      if (businessId != null && businessId.isNotEmpty) {
        queryParams['business_id'] = businessId;
      }

      final response = await _apiClient.dio.get(
        AppConstants.redemptionsEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == AppConstants.httpOk) {
        final data = response.data;
        List<dynamic> items;
        if (data is Map<String, dynamic> && data['items'] is List<dynamic>) {
          items = data['items'] as List<dynamic>;
        } else if (data is List<dynamic>) {
          items = data;
        } else {
          items = const [];
        }

        return items.map((json) => Redemption.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        final detail = response.data is Map<String, dynamic>
            ? (response.data['detail'] ?? response.data['message'] ?? 'Failed to get redemptions')
            : 'Failed to get redemptions';
        throw Exception(detail);
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  /// Get redemption statistics
  Future<Map<String, dynamic>> getRedemptionStats({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _apiClient.dio.get(
        '${AppConstants.redemptionsEndpoint}/stats',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == AppConstants.httpOk) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get redemption stats: ${response.data['detail']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }
}
