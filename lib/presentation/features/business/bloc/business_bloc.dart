import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../data/datasources/business_remote_datasource.dart';
import 'business_event.dart';
import 'business_state.dart';

/// Business BLoC for managing partners and sponsored banners
@injectable
class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  final BusinessRemoteDataSource _businessDataSource;

  BusinessBloc(this._businessDataSource) : super(BusinessInitial()) {
    on<LoadBusinessPartnersEvent>(_onLoadBusinessPartners);
    on<LoadBusinessDetailEvent>(_onLoadBusinessDetail);
    on<LoadSponsoredBannersEvent>(_onLoadSponsoredBanners);
  }

  Future<void> _onLoadBusinessPartners(
    LoadBusinessPartnersEvent event,
    Emitter<BusinessState> emit,
  ) async {
    emit(BusinessLoading());
    
    try {
      final partners = await _businessDataSource.getBusinessPartners(
        category: event.category,
        search: event.search,
      );
      emit(BusinessPartnersLoaded(partners));
    } on ServerFailure catch (e) {
      emit(BusinessError(e.message));
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      }
      emit(BusinessError(errorMessage));
    }
  }

  Future<void> _onLoadBusinessDetail(
    LoadBusinessDetailEvent event,
    Emitter<BusinessState> emit,
  ) async {
    emit(BusinessLoading());
    
    try {
      final business = await _businessDataSource.getBusinessDetail(event.businessId);
      emit(BusinessDetailLoaded(business));
    } on ServerFailure catch (e) {
      emit(BusinessError(e.message));
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      }
      emit(BusinessError(errorMessage));
    }
  }

  Future<void> _onLoadSponsoredBanners(
    LoadSponsoredBannersEvent event,
    Emitter<BusinessState> emit,
  ) async {
    emit(BusinessLoading());
    
    try {
      final banners = await _businessDataSource.getSponsoredBanners();
      // Sort by priority (ascending - lower number = higher priority)
      // API already returns them sorted, but we ensure consistency
      banners.sort((a, b) => a.priority.compareTo(b.priority));
      emit(SponsoredBannersLoaded(banners));
    } on ServerFailure catch (e) {
      emit(BusinessError(e.message));
    } catch (e) {
      String errorMessage = e.toString();
      String displayMessage = 'Une erreur est survenue';
      if (errorMessage.contains('Network error')) {
        displayMessage = 'Erreur de connexion. Vérifiez votre internet.';
      }
      emit(BusinessError(displayMessage));
    }
  }
}

