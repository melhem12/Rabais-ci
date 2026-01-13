import 'package:equatable/equatable.dart';
import '../../../../domain/entities/voucher.dart';

abstract class PurchaseState extends Equatable {
  const PurchaseState();

  @override
  List<Object?> get props => [];
}

class PurchaseInitial extends PurchaseState {}

class PurchaseLoading extends PurchaseState {}

class PurchasesLoaded extends PurchaseState {
  final List<Purchase> purchases;
  
  const PurchasesLoaded(this.purchases);
  
  @override
  List<Object?> get props => [purchases];
}

class PurchaseDetailLoaded extends PurchaseState {
  final Purchase purchase;
  
  const PurchaseDetailLoaded(this.purchase);
  
  @override
  List<Object?> get props => [purchase];
}

class PurchaseQrCodeLoaded extends PurchaseState {
  final String qrCode;
  
  const PurchaseQrCodeLoaded(this.qrCode);
  
  @override
  List<Object?> get props => [qrCode];
}

class PurchaseError extends PurchaseState {
  final String message;
  
  const PurchaseError(this.message);
  
  @override
  List<Object?> get props => [message];
}
