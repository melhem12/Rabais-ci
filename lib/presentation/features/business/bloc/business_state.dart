import 'package:equatable/equatable.dart';
import '../../../../domain/entities/voucher.dart';

abstract class BusinessState extends Equatable {
  const BusinessState();

  @override
  List<Object?> get props => [];
}

class BusinessInitial extends BusinessState {}

class BusinessLoading extends BusinessState {}

class BusinessPartnersLoaded extends BusinessState {
  final List<Business> partners;
  
  const BusinessPartnersLoaded(this.partners);
  
  @override
  List<Object?> get props => [partners];
}

class BusinessDetailLoaded extends BusinessState {
  final Business business;
  
  const BusinessDetailLoaded(this.business);
  
  @override
  List<Object?> get props => [business];
}

class SponsoredBannersLoaded extends BusinessState {
  final List<SponsoredBanner> banners;
  
  const SponsoredBannersLoaded(this.banners);
  
  @override
  List<Object?> get props => [banners];
}

class BusinessError extends BusinessState {
  final String message;
  
  const BusinessError(this.message);
  
  @override
  List<Object?> get props => [message];
}
