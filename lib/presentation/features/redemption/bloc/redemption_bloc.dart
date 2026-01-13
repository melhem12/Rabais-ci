import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../data/datasources/redemption_remote_datasource.dart';
import 'redemption_event.dart';
import 'redemption_state.dart';

/// Redemption BLoC (for merchants)
@injectable
class RedemptionBloc extends Bloc<RedemptionEvent, RedemptionState> {
  final RedemptionRemoteDataSource _redemptionDataSource;

  RedemptionBloc(this._redemptionDataSource) : super(RedemptionInitial()) {
    on<RedeemVoucherEvent>(_onRedeemVoucher);
    on<LoadRedemptionsEvent>(_onLoadRedemptions);
    on<LoadRedemptionStatsEvent>(_onLoadRedemptionStats);
  }

  Future<void> _onRedeemVoucher(RedeemVoucherEvent event, Emitter<RedemptionState> emit) async {
    emit(RedemptionLoading());
    
    try {
      final response = await _redemptionDataSource.redeemVoucher(
        code: event.code,
        barcode: event.barcode,
      );
      emit(RedemptionSuccess(response));
    } on ServerFailure catch (e) {
      // Use the server error message directly from the backend
      emit(RedemptionError(e.message));
    } catch (e) {
      // Extract error message from exception - prioritize backend message
      String errorMessage = e.toString();
      
      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      
      // If we have a meaningful backend message, use it directly
      // Only apply fallback translations for generic network/unknown errors
      if (errorMessage.isEmpty || 
          errorMessage == 'Exception' ||
          errorMessage == 'Unknown error: $e' ||
          errorMessage.contains('Unknown error')) {
        errorMessage = 'Une erreur est survenue lors de la rédemption.';
      } else if (errorMessage.contains('Network error') && 
                 !errorMessage.contains('Failed to redeem voucher')) {
        // Only translate network errors if they're truly generic
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      }
      // Otherwise, use the backend message as-is
      
      emit(RedemptionError(errorMessage));
    }
  }

  Future<void> _onLoadRedemptions(LoadRedemptionsEvent event, Emitter<RedemptionState> emit) async {
    emit(RedemptionLoading());
    
    try {
      final redemptions = await _redemptionDataSource.getRedemptions(
        page: event.page,
        limit: event.limit,
        startDate: event.startDate,
        endDate: event.endDate,
        status: event.status,
        method: event.method,
        businessId: event.businessId,
      );
      emit(RedemptionsLoaded(redemptions));
    } on ServerFailure catch (e) {
      emit(RedemptionError(e.message));
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      }
      emit(RedemptionError(errorMessage));
    }
  }

  Future<void> _onLoadRedemptionStats(LoadRedemptionStatsEvent event, Emitter<RedemptionState> emit) async {
    emit(RedemptionLoading());
    
    try {
      final stats = await _redemptionDataSource.getRedemptionStats(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(RedemptionStatsLoaded(stats));
    } on ServerFailure catch (e) {
      emit(RedemptionError(e.message));
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      }
      emit(RedemptionError(errorMessage));
    }
  }
}
