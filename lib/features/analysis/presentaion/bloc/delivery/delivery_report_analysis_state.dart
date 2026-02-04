import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/delivery_report_analysis_entity.dart';

class DeliveryReportAnalysisState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeliveryReportAnalysisInitialState extends DeliveryReportAnalysisState {}

class DeliveryReportAnalysisLoadingState extends DeliveryReportAnalysisState {}

class DeliveryReportAnalysisLoadedState extends DeliveryReportAnalysisState {
  final DeliveryReportAnalysisEntity deliveryReportAnalysis;
  DeliveryReportAnalysisLoadedState({required this.deliveryReportAnalysis});
  @override
  List<Object?> get props => [deliveryReportAnalysis];
}

class DeliveryReportAnalysisErrorState extends DeliveryReportAnalysisState {
  final String message;
  DeliveryReportAnalysisErrorState({required this.message});
  @override
  List<Object?> get props => [message];
}

class DeliveryReportAnalysisEmptyState extends DeliveryReportAnalysisState {}

class DeliveryReportAnalysisFiltering extends DeliveryReportAnalysisState {}

class DeliveryReportAnalysisFilteredState extends DeliveryReportAnalysisState {
  final DeliveryReportAnalysisEntity filteredReport;
  DeliveryReportAnalysisFilteredState({required this.filteredReport});
  @override
  List<Object?> get props => [filteredReport];
}

class DeliveryReportAnalysisFilterErrorState
    extends DeliveryReportAnalysisState {
  final String message;
  DeliveryReportAnalysisFilterErrorState({required this.message});
  @override
  List<Object?> get props => [message];
}
