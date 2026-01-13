import 'package:equatable/equatable.dart';

import '../../../../domain/entities/redemption.dart';

/// Redemption states
abstract class RedemptionState extends Equatable {
  const RedemptionState();

  @override
  List<Object?> get props => [];
}

class RedemptionInitial extends RedemptionState {}

class RedemptionLoading extends RedemptionState {}

class RedemptionSuccess extends RedemptionState {
  final RedemptionResponse response;

  const RedemptionSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class RedemptionsLoaded extends RedemptionState {
  final List<Redemption> redemptions;

  const RedemptionsLoaded(this.redemptions);

  @override
  List<Object?> get props => [redemptions];
}

class RedemptionStatsLoaded extends RedemptionState {
  final Map<String, dynamic> stats;

  const RedemptionStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class RedemptionError extends RedemptionState {
  final String message;

  const RedemptionError(this.message);

  @override
  List<Object?> get props => [message];
}




