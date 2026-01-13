import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/voucher.dart';

@lazySingleton
class PurchaseRemoteDataSource {
  final ApiClient _apiClient;

  PurchaseRemoteDataSource(this._apiClient);

  /// Get user purchases
  Future<List<Purchase>> getPurchases() async {
    try {
      final response = await _apiClient.dio.get(AppConstants.purchasesEndpoint);
      return (response.data as List)
          .map((json) => Purchase.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Get purchase detail
  Future<Purchase> getPurchaseDetail(String purchaseId) async {
    try {
      final response = await _apiClient.dio.get(
        '${AppConstants.purchasesEndpoint}/$purchaseId',
      );
      return Purchase.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Get purchase QR code
  Future<String> getPurchaseQrCode(String purchaseId) async {
    try {
      final response = await _apiClient.dio.get(
        '${AppConstants.purchasesEndpoint}/$purchaseId/qr',
      );

      if (response.statusCode == AppConstants.httpOk) {
        return response.data['qr_payload'] ?? '';
      } else {
        throw Exception('Failed to get QR code: ${response.data['detail']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }
}
