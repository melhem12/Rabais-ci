import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/voucher.dart';
import '../../core/network/api_client.dart';

/// Remote data source for voucher operations
@injectable
class VoucherRemoteDataSource {
  final ApiClient _apiClient;

  VoucherRemoteDataSource(this._apiClient);

  /// Get available vouchers
  Future<List<Voucher>> getVouchers({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    String? businessTypeId,
    String? businessId,
    String? status,
    int? minPrice,
    int? maxPrice,
    String? expiresBefore,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['q'] = search;
      }
      if (businessTypeId != null && businessTypeId.isNotEmpty) {
        queryParams['business_type_id'] = businessTypeId;
      }
      if (businessId != null && businessId.isNotEmpty) {
        queryParams['business_id'] = businessId;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (minPrice != null) {
        queryParams['min_price'] = minPrice;
      }
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice;
      }
      if (expiresBefore != null && expiresBefore.isNotEmpty) {
        queryParams['expires_before'] = expiresBefore;
      }

      final response = await _apiClient.dio.get(
        AppConstants.vouchersEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == AppConstants.httpOk) {
        final List<dynamic> data = response.data;
        return data.map((json) => Voucher.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get vouchers: ${response.data['detail']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  /// Get vouchers for a specific business
  Future<List<Voucher>> getBusinessVouchers(
    String businessId, {
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;

      final response = await _apiClient.dio.get(
        '${AppConstants.businessVouchersEndpoint}/$businessId/vouchers',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == AppConstants.httpOk) {
        final List<dynamic> data = response.data;
        return data.map((json) => Voucher.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to get business vouchers: ${response.data['detail']}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  /// Get voucher details
  Future<Voucher> getVoucher(String voucherId) async {
    try {
      final response = await _apiClient.dio.get(
        '${AppConstants.vouchersEndpoint}/$voucherId',
      );

      if (response.statusCode == AppConstants.httpOk) {
        return Voucher.fromJson(response.data);
      } else {
        throw Exception('Failed to get voucher: ${response.data['detail']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  /// Purchase a voucher
  Future<Purchase> purchaseVoucher(
    String voucherId, {
    required String paymentMethod,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${AppConstants.vouchersEndpoint}/$voucherId/buy',
        data: {'payment_method': paymentMethod},
      );

      if (response.statusCode == AppConstants.httpCreated) {
        return Purchase.fromJson(response.data);
      } else {
        final errorMsg = response.data is Map<String, dynamic>
            ? (response.data['detail'] ??
                  response.data['message'] ??
                  'Failed to purchase voucher')
            : 'Failed to purchase voucher';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      // Extract detailed error message from response
      String errorMessage = 'Network error occurred';

      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage =
              responseData['detail'] ??
              responseData['message'] ??
              'Purchase failed with status ${e.response?.statusCode}';
        } else if (responseData is String) {
          errorMessage = responseData;
        } else {
          errorMessage =
              'Purchase failed with status ${e.response?.statusCode}';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
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

  /// Claim a voucher (auto-spends coins if coin_price > 0)
  Future<Purchase> claimVoucher(String voucherId) async {
    try {
      final response = await _apiClient.dio.post(
        '${AppConstants.vouchersEndpoint}/$voucherId/claim',
        data: {}, // API requires a body, even if empty
      );

      if (response.statusCode == AppConstants.httpCreated ||
          response.statusCode == AppConstants.httpOk) {
        return Purchase.fromJson(response.data);
      } else {
        throw Exception('Failed to claim voucher: ${response.data['detail']}');
      }
    } on DioException catch (e) {
      // Extract detailed error message from response
      String errorMessage = 'Failed to claim voucher';
      if (e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map) {
          if (responseData.containsKey('detail')) {
            final detail = responseData['detail'];
            if (detail is String) {
              errorMessage = detail;
            } else if (detail is List && detail.isNotEmpty) {
              final firstError = detail[0];
              if (firstError is Map && firstError.containsKey('msg')) {
                errorMessage = firstError['msg'] as String;
              } else {
                errorMessage = detail.toString();
              }
            } else {
              errorMessage = detail.toString();
            }
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'] as String;
          }
        }
      } else if (e.message != null) {
        errorMessage = 'Network error: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Get voucher by barcode
  Future<Voucher> getVoucherByBarcode(String barcode) async {
    try {
      final response = await _apiClient.dio.get(
        '${AppConstants.vouchersEndpoint}/by-barcode/$barcode',
      );

      if (response.statusCode == AppConstants.httpOk) {
        return Voucher.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to get voucher by barcode: ${response.data['detail']}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  /// Purchase voucher by barcode
  Future<Purchase> purchaseVoucherByBarcode(
    String barcode, {
    required String paymentMethod,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${AppConstants.vouchersEndpoint}/buy-by-barcode',
        data: {'barcode': barcode, 'payment_method': paymentMethod},
      );

      if (response.statusCode == AppConstants.httpCreated) {
        return Purchase.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to purchase voucher by barcode: ${response.data['detail']}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  /// Get user purchases
  Future<List<Purchase>> getPurchases({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (status != null) queryParams['status'] = status;

      final response = await _apiClient.dio.get(
        AppConstants.purchasesEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == AppConstants.httpOk) {
        final List<dynamic> data = response.data;
        return data.map((json) => Purchase.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get purchases: ${response.data['detail']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  /// Get purchase details
  Future<Purchase> getPurchase(String purchaseId) async {
    try {
      final response = await _apiClient.dio.get(
        '${AppConstants.purchasesEndpoint}/$purchaseId',
      );

      if (response.statusCode == AppConstants.httpOk) {
        return Purchase.fromJson(response.data);
      } else {
        throw Exception('Failed to get purchase: ${response.data['detail']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  /// Get purchase QR code
  Future<Map<String, String>> getPurchaseQrCode(String purchaseId) async {
    try {
      final response = await _apiClient.dio.get(
        '${AppConstants.purchasesEndpoint}/$purchaseId/qr',
      );

      if (response.statusCode == AppConstants.httpOk) {
        return {
          'qr_payload': response.data['qr_payload'] ?? '',
          'barcode': response.data['barcode'] ?? '',
          'redeem_code': response.data['redeem_code'] ?? '',
        };
      } else {
        throw Exception('Failed to get QR code: ${response.data['detail']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  /// Get sponsored banners
  Future<List<SponsoredBanner>> getSponsoredBanners() async {
    try {
      final response = await _apiClient.dio.get(AppConstants.sponsoredEndpoint);

      if (response.statusCode == AppConstants.httpOk) {
        final List<dynamic> data = response.data;
        return data.map((json) => SponsoredBanner.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to get sponsored banners: ${response.data['detail']}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }
}
