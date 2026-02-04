import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/branch_report_analysis_entity.dart';

abstract class BranchReportAnalysisEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchBranchReportAnalysisEvent extends BranchReportAnalysisEvent {
  final String startDate;
  final String endDate;
  final String? branchName;

  FetchBranchReportAnalysisEvent({
    required this.startDate,
    required this.endDate,
    this.branchName,
  });

  @override
  List<Object?> get props => [startDate, endDate, branchName];
}

class ResetBranchReportAnalysisEvent extends BranchReportAnalysisEvent {}

class SearchBranchAnalysisEvent extends BranchReportAnalysisEvent {
  final String searchQuery;
  final List<BranchReportAnalysisEntity> allData;

  SearchBranchAnalysisEvent({
    required this.searchQuery,
    required this.allData,
  });

  @override
  List<Object?> get props => [searchQuery, allData];
}

class ClearSearchEvent extends BranchReportAnalysisEvent {}