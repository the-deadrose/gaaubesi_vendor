import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/pickup_order_analysis_entity.dart';

class PickupOrderAnalysisState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PickupOrderAnalysisInitial extends PickupOrderAnalysisState {}

class PickupOrderAnalysisLoading extends PickupOrderAnalysisState {}

class PickupOrderAnalysisLoaded extends PickupOrderAnalysisState {
  final PickupOrderAnalysisEntity analysis;

  PickupOrderAnalysisLoaded({required this.analysis});

  @override
  List<Object?> get props => [analysis];
}

class PickupOrderAnalysisError extends PickupOrderAnalysisState {
  final String message;

  PickupOrderAnalysisError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PickupOrderAnalysisEmpty extends PickupOrderAnalysisState {}

class PickupOrderAnalysisIsFiltering extends PickupOrderAnalysisState {}

class PickupOrderAnalysisFiltered extends PickupOrderAnalysisState {
  final PickupOrderAnalysisEntity analysis;

  PickupOrderAnalysisFiltered({required this.analysis});

  @override
  List<Object?> get props => [analysis];
}
