import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/voucher.dart';
import '../../domain/entities/business_options.dart';

@lazySingleton
class BusinessRemoteDataSource {
  final ApiClient _apiClient;

  BusinessRemoteDataSource(this._apiClient);

  /// Get business categories and types for filters
  Future<List<BusinessCategoryOption>> getBusinessOptions() async {
    try {
      final response = await _apiClient.dio.get(
        AppConstants.businessOptionsEndpoint,
      );

      if (response.statusCode == AppConstants.httpOk) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['categories'] is List) {
          final categories = (data['categories'] as List)
              .whereType<Map<String, dynamic>>()
              .map(BusinessCategoryOption.fromJson)
              .toList();
          return categories;
        }
        return const [];
      } else {
        throw Exception(
          'Failed to get business options: ${response.data['detail'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Get business partners with optional filters
  /// This endpoint is public (no auth required)
  Future<List<Business>> getBusinessPartners({
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.dio.get(
        AppConstants.businessPartnersEndpoint,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      return (response.data as List)
          .map((json) => Business.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Business> getBusinessDetail(String businessId) async {
    try {
      final response = await _apiClient.dio.get(
        '${AppConstants.businessDetailEndpoint}/$businessId',
      );
      return Business.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Get sponsored banners
  /// Note: This is a public endpoint (no auth required)
  Future<List<SponsoredBanner>> getSponsoredBanners() async {
    try {
      final response = await _apiClient.dio.get(AppConstants.sponsoredEndpoint);
      if (response.statusCode == AppConstants.httpOk) {
        return (response.data as List)
            .map((json) => SponsoredBanner.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to get sponsored banners: ${response.data['detail'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      // Extract detailed error message and status code
      String errorMessage = 'Network error occurred';
      int? statusCode;

      if (e.response != null) {
        statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage =
              responseData['detail'] ??
              responseData['message'] ??
              'Request failed with status $statusCode';
        } else if (responseData is String) {
          errorMessage = responseData;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }

      // Include status code in error message for easier detection
      if (statusCode != null) {
        throw Exception('$statusCode: $errorMessage');
      } else {
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(e.toString());
    }
  }
}
