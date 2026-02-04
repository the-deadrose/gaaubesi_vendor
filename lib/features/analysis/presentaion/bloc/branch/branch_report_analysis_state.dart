// lib/features/analysis/presentation/state/branch_report_analysis_state.dart
import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/branch_report_analysis_entity.dart';

class BranchReportAnalysisState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BranchReportAnalysisInitialState extends BranchReportAnalysisState {}

class BranchReportAnalysisLoadingState extends BranchReportAnalysisState {}

class BranchReportAnalysisLoadedState extends BranchReportAnalysisState {
  final List<BranchReportAnalysisEntity> branchReports;
  final List<BranchReportAnalysisEntity> filteredReports;
  
  BranchReportAnalysisLoadedState({
    required this.branchReports,
    this.filteredReports = const [],
  });

  BranchReportAnalysisLoadedState copyWith({
    List<BranchReportAnalysisEntity>? branchReports,
    List<BranchReportAnalysisEntity>? filteredReports,
  }) {
    return BranchReportAnalysisLoadedState(
      branchReports: branchReports ?? this.branchReports,
      filteredReports: filteredReports ?? this.filteredReports,
    );
  }

  @override
  List<Object?> get props => [branchReports, filteredReports];
}

class BranchReportAnalysisErrorState extends BranchReportAnalysisState {
  final String message;
  BranchReportAnalysisErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class BranchReportAnalysisEmptyState extends BranchReportAnalysisState {}

class BranchReportAnalysisSearchingState extends BranchReportAnalysisState {
  final List<BranchReportAnalysisEntity> allData;
  
  BranchReportAnalysisSearchingState({required this.allData});

  @override
  List<Object?> get props => [allData];
}

class BranchReportAnalysisSearchResultState extends BranchReportAnalysisState {
  final List<BranchReportAnalysisEntity> searchResults;
  
  BranchReportAnalysisSearchResultState({required this.searchResults});

  @override
  List<Object?> get props => [searchResults];
}