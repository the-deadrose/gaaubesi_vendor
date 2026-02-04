import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/sales_report_analysis_entity.dart';

class SalesReportAnalysisState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SalesReportAnalysisInitial extends SalesReportAnalysisState {}

class SalesReportAnalysisLoading extends SalesReportAnalysisState {}

class SalesReportAnalysisLoaded extends SalesReportAnalysisState {
  final SalesReportAnalysis salesReportAnalysis;

  SalesReportAnalysisLoaded({required this.salesReportAnalysis});

  @override
  List<Object?> get props => [salesReportAnalysis];
}

class SalesReportAnalysisError extends SalesReportAnalysisState {
  final String message;

  SalesReportAnalysisError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SalesReportAnalysisEmpty extends SalesReportAnalysisState {}

class SalesReportAnalysisFiltering extends SalesReportAnalysisState {}

class SalesReportAnalysisFiltered extends SalesReportAnalysisState {
  final SalesReportAnalysis salesReportAnalysis;

  SalesReportAnalysisFiltered({required this.salesReportAnalysis});

  @override
  List<Object?> get props => [salesReportAnalysis];
}

class SalesReportAnalysisFilterError extends SalesReportAnalysisState {
  final String message;

  SalesReportAnalysisFilterError({required this.message});

  @override
  List<Object?> get props => [message];
}
