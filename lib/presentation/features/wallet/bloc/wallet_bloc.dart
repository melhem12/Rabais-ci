import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/wallet.dart';
import '../../../../data/datasources/wallet_remote_datasource.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

/// Wallet BLoC
@injectable
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRemoteDataSource _walletDataSource;

  WalletBloc(this._walletDataSource) : super(WalletInitial()) {
    on<LoadWalletEvent>(_onLoadWallet);
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<LoadCoinPackagesEvent>(_onLoadCoinPackages);
    on<TopUpWalletEvent>(_onTopUpWallet);
    on<InitPaiementProTopupEvent>(_onInitPaiementProTopup);
  }

  Future<void> _onLoadWallet(
    LoadWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    try {
      final wallet = await _walletDataSource.getWallet();
      List<Transaction> transactions = const [];
      try {
        transactions = await _walletDataSource.getTransactions();
      } catch (_) {
        transactions = const [];
      }
      emit(
        WalletLoaded(
          wallet,
          recentTransactions: transactions.take(5).toList(),
        ),
      );
    } on ServerFailure catch (e) {
      emit(WalletError(e.message));
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Accès refusé. Veuillez vous reconnecter.';
      }
      emit(WalletError(errorMessage));
    }
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<WalletState> emit,
  ) async {
    try {
      final transactions = await _walletDataSource.getTransactions();
      final currentState = state;
      final currency = currentState is WalletLoaded ? currentState.wallet.currency : 'XOF';
      emit(TransactionsLoaded(transactions, currency: currency));
    } on ServerFailure catch (e) {
      emit(WalletError(e.message));
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      }
      emit(WalletError(errorMessage));
    }
  }

  Future<void> _onLoadCoinPackages(
    LoadCoinPackagesEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    try {
      final packages = await _walletDataSource.getCoinPackages();
      emit(CoinPackagesLoaded(packages));
    } on ServerFailure catch (e) {
      emit(WalletError(e.message));
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      }
      emit(WalletError(errorMessage));
    }
  }

  Future<void> _onTopUpWallet(
    TopUpWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    try {
      final transaction = await _walletDataSource.topUpWallet(
        packageId: event.packageId,
        amount: event.amount,
        provider: event.provider,
        currency: event.currency,
      );
      emit(TopUpSuccess(transaction));
    } on ServerFailure catch (e) {
      emit(WalletError(e.message));
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      }
      emit(WalletError(errorMessage));
    }
  }

  Future<void> _onInitPaiementProTopup(
    InitPaiementProTopupEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    try {
      final url = await _walletDataSource.initPaiementProTopup(
        packageId: event.packageId,
        amount: event.amount,
        currency: event.currency,
      );
      emit(PaiementProInitSuccess(url));
    } on ServerFailure catch (e) {
      emit(WalletError(e.message));
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      }
      emit(WalletError(errorMessage));
    }
  }
}
