import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../data/datasources/auth_local_datasource.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/datasources/wallet_remote_datasource.dart';
import '../data/datasources/voucher_remote_datasource.dart';
import '../data/datasources/redemption_remote_datasource.dart';
import '../data/datasources/purchase_remote_datasource.dart';
import '../data/datasources/business_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../presentation/features/auth/bloc/auth_bloc.dart';
import '../presentation/features/wallet/bloc/wallet_bloc.dart';
import '../presentation/features/voucher/bloc/voucher_bloc.dart';
import '../presentation/features/redemption/bloc/redemption_bloc.dart';
import '../presentation/features/purchase/bloc/purchase_bloc.dart';
import '../presentation/features/business/bloc/business_bloc.dart';

/// Global service locator instance
final GetIt getIt = GetIt.instance;

/// Configure dependency injection
Future<void> configureDependencies() async {
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register secure storage
  getIt.registerSingleton<SecureStorageService>(SecureStorageService());

  // Register core services
  getIt.registerSingleton<ApiClient>(
    ApiClient(sharedPreferences, getIt<SecureStorageService>()),
  );
  getIt.registerSingleton<Dio>(getIt<ApiClient>().dio);

  // Register data sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(
      getIt<SharedPreferences>(),
      getIt<SecureStorageService>(),
    ),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<VoucherRemoteDataSource>(
    () => VoucherRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<RedemptionRemoteDataSource>(
    () => RedemptionRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<PurchaseRemoteDataSource>(
    () => PurchaseRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<BusinessRemoteDataSource>(
    () => BusinessRemoteDataSource(getIt<ApiClient>()),
  );

  // Register repositories
  getIt.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<AuthLocalDataSource>(),
    ),
  );

  // Register BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerFactory<WalletBloc>(
    () => WalletBloc(getIt<WalletRemoteDataSource>()),
  );
  getIt.registerFactory<VoucherBloc>(
    () => VoucherBloc(getIt<VoucherRemoteDataSource>()),
  );
  getIt.registerFactory<RedemptionBloc>(
    () => RedemptionBloc(getIt<RedemptionRemoteDataSource>()),
  );
  getIt.registerFactory<PurchaseBloc>(
    () => PurchaseBloc(getIt<PurchaseRemoteDataSource>()),
  );
  getIt.registerFactory<BusinessBloc>(
    () => BusinessBloc(getIt<BusinessRemoteDataSource>()),
  );
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}