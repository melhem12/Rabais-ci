import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../data/datasources/purchase_remote_datasource.dart';
import 'purchase_event.dart';
import 'purchase_state.dart';

@injectable
class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final PurchaseRemoteDataSource _purchaseRemoteDataSource;

  PurchaseBloc(this._purchaseRemoteDataSource) : super(PurchaseInitial()) {
    on<LoadPurchasesEvent>(_onLoadPurchases);
    on<LoadPurchaseDetailEvent>(_onLoadPurchaseDetail);
    on<LoadPurchaseQrCodeEvent>(_onLoadPurchaseQrCode);
  }

  Future<void> _onLoadPurchases(
    LoadPurchasesEvent event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    try {
      final purchases = await _purchaseRemoteDataSource.getPurchases();
      emit(PurchasesLoaded(purchases));
    } catch (e) {
      emit(PurchaseError(e.toString()));
    }
  }

  Future<void> _onLoadPurchaseDetail(
    LoadPurchaseDetailEvent event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    try {
      final purchase = await _purchaseRemoteDataSource.getPurchaseDetail(event.purchaseId);
      emit(PurchaseDetailLoaded(purchase));
    } catch (e) {
      emit(PurchaseError(e.toString()));
    }
  }

  Future<void> _onLoadPurchaseQrCode(
    LoadPurchaseQrCodeEvent event,
    Emitter<PurchaseState> emit,
  ) async {
    // Don't emit any state change if we already have purchase details loaded
    // This prevents the page from flickering or closing
    final currentState = state;
    if (currentState is PurchaseDetailLoaded) {
      // If we already have purchase details, just load QR code silently
      // Check if QR code is already in the purchase object
      final purchase = currentState.purchase;
      if (purchase.qrPayload != null || purchase.qrCode != null) {
        // QR code already available in purchase, no need to load separately
        return;
      }
      
      // Load QR code silently without emitting state changes
      try {
        await _purchaseRemoteDataSource.getPurchaseQrCode(event.purchaseId);
        // Don't emit any state - keep the PurchaseDetailLoaded state
        // The QR code will be updated via the purchase detail which already has it
        return;
      } catch (e) {
        // If QR code loading fails, silently fail (non-critical)
        // Keep the PurchaseDetailLoaded state
        return;
      }
    }
    
    // If we don't have purchase details, show loading
    if (currentState is! PurchaseDetailLoaded) {
      emit(PurchaseLoading());
    }
    
    try {
      final qrCode = await _purchaseRemoteDataSource.getPurchaseQrCode(event.purchaseId);
      // If no purchase details, emit QR code state (shouldn't normally happen)
      emit(PurchaseQrCodeLoaded(qrCode));
    } catch (e) {
      // Only emit error if we don't have purchase details loaded
      if (currentState is! PurchaseDetailLoaded) {
        emit(PurchaseError(e.toString()));
      }
    }
  }
}
