import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/wallet.dart';
import '../../core/network/api_client.dart';

/// Remote data source for wallet operations
@injectable
class WalletRemoteDataSource {
  final ApiClient _apiClient;

  WalletRemoteDataSource(this._apiClient);

  /// Get wallet information
  Future<Wallet> getWallet() async {
    try {
      final response = await _apiClient.dio.get(AppConstants.walletEndpoint);

      if (response.statusCode == AppConstants.httpOk) {
        return Wallet.fromJson(response.data);
      } else {
        throw Exception('Failed to get wallet: ${response.data['detail']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  /// Get wallet transactions (newest first)
  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await _apiClient.dio.get(AppConstants.walletTransactionsEndpoint);

      if (response.statusCode == AppConstants.httpOk) {
        final List<dynamic> data = response.data;
        return data.map((json) => Transaction.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get transactions: ${response.data['detail']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  /// Get available coin packages
  Future<List<CoinPackage>> getCoinPackages() async {
    try {
      final response = await _apiClient.dio.get(AppConstants.walletPackagesEndpoint);

      if (response.statusCode == AppConstants.httpOk) {
        final List<dynamic> data = response.data;
        final packages = data.map((json) => CoinPackage.fromJson(json)).toList();
        packages.sort((a, b) => a.priceMinor.compareTo(b.priceMinor));
        return packages;
      } else {
        throw Exception('Failed to get coin packages: ${response.data['detail']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  /// Top up wallet with coin package
  Future<Transaction> topUpWallet({
    String? packageId,
    double? amount,
    String provider = 'internal',
    String? currency,
  }) async {
    try {
      Map<String, dynamic> requestData = {
        'provider': provider,
      };

      if (packageId != null) {
        requestData['package_id'] = packageId;
      } else if (amount != null) {
        requestData['amount'] = amount;
        if (currency != null) {
          requestData['currency'] = currency;
        }
      } else {
        throw Exception('Either package_id or amount must be provided');
      }

      final response = await _apiClient.dio.post(
        AppConstants.walletTopupEndpoint,
        data: requestData,
      );

      if (response.statusCode == AppConstants.httpOk || 
          response.statusCode == AppConstants.httpCreated) {
        return Transaction.fromJson(response.data);
      } else {
        throw Exception('Failed to top up wallet: ${response.data['detail']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  /// Init PaiementPro top-up and return redirect URL
  Future<String> initPaiementProTopup({
    String? packageId,
    double? amount,
    String? currency,
  }) async {
    if (packageId == null && amount == null) {
      throw Exception('Either package_id or amount must be provided');
    }
    try {
      final requestData = <String, dynamic>{
        if (packageId != null) 'package_id': packageId,
        if (amount != null) 'amount': amount,
        if (currency != null) 'currency': currency,
      };

      final response = await _apiClient.dio.post(
        AppConstants.walletPaiementProTopupEndpoint,
        data: requestData,
      );

      if (response.statusCode == AppConstants.httpOk ||
          response.statusCode == AppConstants.httpCreated) {
        final url = response.data['url'] ?? response.data['payment_url'];
        if (url is String && url.isNotEmpty) {
          return url;
        }
        throw Exception('PaiementPro URL not returned by server');
      } else {
        throw Exception('Failed to init PaiementPro: ${response.data['detail']}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }
}
