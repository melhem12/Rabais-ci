import 'package:equatable/equatable.dart';

abstract class BusinessEvent extends Equatable {
  const BusinessEvent();

  @override
  List<Object?> get props => [];
}

class LoadBusinessPartnersEvent extends BusinessEvent {
  final String? category;
  final String? search;

  const LoadBusinessPartnersEvent({
    this.category,
    this.search,
  });

  @override
  List<Object?> get props => [category, search];
}

class LoadBusinessDetailEvent extends BusinessEvent {
  final String businessId;
  
  const LoadBusinessDetailEvent(this.businessId);
  
  @override
  List<Object?> get props => [businessId];
}

class LoadSponsoredBannersEvent extends BusinessEvent {
  const LoadSponsoredBannersEvent();
}
