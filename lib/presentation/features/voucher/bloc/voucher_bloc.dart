import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../data/datasources/voucher_remote_datasource.dart';
import 'voucher_event.dart';
import 'voucher_state.dart';

/// Voucher BLoC
@injectable
class VoucherBloc extends Bloc<VoucherEvent, VoucherState> {
  final VoucherRemoteDataSource _voucherDataSource;

  VoucherBloc(this._voucherDataSource) : super(VoucherInitial()) {
    on<LoadVouchersEvent>(_onLoadVouchers);
    on<LoadBusinessVouchersEvent>(_onLoadBusinessVouchers);
    on<LoadVoucherDetailsEvent>(_onLoadVoucherDetails);
    on<PurchaseVoucherEvent>(_onPurchaseVoucher);
    on<ClaimVoucherEvent>(_onClaimVoucher);
    on<GetVoucherByBarcodeEvent>(_onGetVoucherByBarcode);
    on<PurchaseVoucherByBarcodeEvent>(_onPurchaseVoucherByBarcode);
    on<LoadPurchasesEvent>(_onLoadPurchases);
    on<LoadPurchaseDetailsEvent>(_onLoadPurchaseDetails);
  }

  Future<void> _onLoadVouchers(
    LoadVouchersEvent event,
    Emitter<VoucherState> emit,
  ) async {
    emit(VoucherLoading());

    try {
      final vouchers = await _voucherDataSource.getVouchers(
        page: event.page,
        limit: event.limit,
        category: event.category,
        search: event.search,
        businessTypeId: event.businessTypeId,
        businessId: event.businessId,
        status: event.status,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        expiresBefore: event.expiresBefore,
      );
      emit(VouchersLoaded(vouchers));
    } on ServerFailure catch (e) {
      emit(VoucherError(e.message));
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      }
      emit(VoucherError(errorMessage));
    }
  }

  Future<void> _onLoadBusinessVouchers(
    LoadBusinessVouchersEvent event,
    Emitter<VoucherState> emit,
  ) async {
    emit(VoucherLoading());

    try {
      final vouchers = await _voucherDataSource.getBusinessVouchers(
        event.businessId,
        status: event.status,
      );
      emit(VouchersLoaded(vouchers));
    } on ServerFailure catch (e) {
      emit(VoucherError(e.message));
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      }
      emit(VoucherError(errorMessage));
    }
  }

  Future<void> _onLoadVoucherDetails(
    LoadVoucherDetailsEvent event,
    Emitter<VoucherState> emit,
  ) async {
    emit(VoucherLoading());

    try {
      final voucher = await _voucherDataSource.getVoucher(event.voucherId);
      emit(VoucherDetailsLoaded(voucher));
    } on ServerFailure catch (e) {
      emit(VoucherError(e.message));
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      }
      emit(VoucherError(errorMessage));
    }
  }

  Future<void> _onPurchaseVoucher(
    PurchaseVoucherEvent event,
    Emitter<VoucherState> emit,
  ) async {
    emit(VoucherLoading());

    try {
      final purchase = await _voucherDataSource.purchaseVoucher(
        event.voucherId,
        paymentMethod: event.paymentMethod,
      );
      // Emit success state
      emit(PurchaseSuccess(purchase));
    } on ServerFailure catch (e) {
      emit(VoucherError(e.message));
    } catch (e) {
      // Extract error message from exception
      String errorMessage = e.toString();

      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      // Handle specific error cases
      if (errorMessage.contains('Network error') ||
          errorMessage.contains('connection') ||
          errorMessage.contains('timeout')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      } else if (errorMessage.contains('insufficient') ||
          errorMessage.contains('balance') ||
          errorMessage.contains('Solde')) {
        errorMessage =
            'Solde insuffisant. Veuillez recharger votre portefeuille.';
      } else if (errorMessage.isEmpty || errorMessage == 'Exception') {
        errorMessage = 'Une erreur est survenue lors de l\'achat.';
      }

      // Emit error state
      emit(VoucherError(errorMessage));
    }
  }

  Future<void> _onClaimVoucher(
    ClaimVoucherEvent event,
    Emitter<VoucherState> emit,
  ) async {
    emit(VoucherLoading());

    try {
      final purchase = await _voucherDataSource.claimVoucher(event.voucherId);
      emit(PurchaseSuccess(purchase));
    } on ServerFailure catch (e) {
      emit(VoucherError(e.message));
    } catch (e) {
      // Extract error message from exception
      String errorMessage = e.toString();

      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      // Handle specific error cases
      if (errorMessage.contains('Network error') ||
          errorMessage.contains('connection') ||
          errorMessage.contains('timeout')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      } else if (errorMessage.contains('insufficient') ||
          errorMessage.contains('balance') ||
          errorMessage.contains('Solde')) {
        errorMessage =
            'Solde insuffisant. Veuillez recharger votre portefeuille.';
      } else if (errorMessage.isEmpty || errorMessage == 'Exception') {
        errorMessage = 'Une erreur est survenue lors de la réclamation du bon.';
      }

      // Emit error state
      emit(VoucherError(errorMessage));
    }
  }

  Future<void> _onGetVoucherByBarcode(
    GetVoucherByBarcodeEvent event,
    Emitter<VoucherState> emit,
  ) async {
    emit(VoucherLoading());

    try {
      final voucher = await _voucherDataSource.getVoucherByBarcode(
        event.barcode,
      );
      emit(VoucherDetailsLoaded(voucher));
    } on ServerFailure catch (e) {
      emit(VoucherError(e.message));
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      }
      emit(VoucherError(errorMessage));
    }
  }

  Future<void> _onPurchaseVoucherByBarcode(
    PurchaseVoucherByBarcodeEvent event,
    Emitter<VoucherState> emit,
  ) async {
    emit(VoucherLoading());

    try {
      final purchase = await _voucherDataSource.purchaseVoucherByBarcode(
        event.barcode,
        paymentMethod: event.paymentMethod,
      );
      emit(PurchaseSuccess(purchase));
    } on ServerFailure catch (e) {
      emit(VoucherError(e.message));
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      }
      emit(VoucherError(errorMessage));
    }
  }

  Future<void> _onLoadPurchases(
    LoadPurchasesEvent event,
    Emitter<VoucherState> emit,
  ) async {
    emit(VoucherLoading());

    try {
      final purchases = await _voucherDataSource.getPurchases(
        page: event.page,
        limit: event.limit,
        status: event.status,
      );
      emit(PurchasesLoaded(purchases));
    } on ServerFailure catch (e) {
      emit(VoucherError(e.message));
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      }
      emit(VoucherError(errorMessage));
    }
  }

  Future<void> _onLoadPurchaseDetails(
    LoadPurchaseDetailsEvent event,
    Emitter<VoucherState> emit,
  ) async {
    emit(VoucherLoading());

    try {
      final purchase = await _voucherDataSource.getPurchase(event.purchaseId);
      emit(PurchaseDetailsLoaded(purchase));
    } on ServerFailure catch (e) {
      emit(VoucherError(e.message));
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      }
      emit(VoucherError(errorMessage));
    }
  }
}
