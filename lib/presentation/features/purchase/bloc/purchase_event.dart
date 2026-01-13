import 'package:equatable/equatable.dart';

abstract class PurchaseEvent extends Equatable {
  const PurchaseEvent();

  @override
  List<Object?> get props => [];
}

class LoadPurchasesEvent extends PurchaseEvent {
  const LoadPurchasesEvent();
}

class LoadPurchaseDetailEvent extends PurchaseEvent {
  final String purchaseId;
  
  const LoadPurchaseDetailEvent(this.purchaseId);
  
  @override
  List<Object?> get props => [purchaseId];
}

class LoadPurchaseQrCodeEvent extends PurchaseEvent {
  final String purchaseId;
  
  const LoadPurchaseQrCodeEvent(this.purchaseId);
  
  @override
  List<Object?> get props => [purchaseId];
}
