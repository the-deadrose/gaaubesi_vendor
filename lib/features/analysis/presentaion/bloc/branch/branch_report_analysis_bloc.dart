import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/branch_report_analysis_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/usecase/fetch_branch_report_analysis_usecase.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/branch/branch_report_analysis_event.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/branch/branch_report_analysis_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton


class BranchReportAnalysisBloc
    extends Bloc<BranchReportAnalysisEvent, BranchReportAnalysisState> {
  final FetchBranchReportAnalysisUsecase _fetchBranchReportAnalysisUsecase;
  List<BranchReportAnalysisEntity> _allReports = [];

  BranchReportAnalysisBloc({
    required FetchBranchReportAnalysisUsecase fetchBranchReportAnalysisUsecase,
  })  : _fetchBranchReportAnalysisUsecase = fetchBranchReportAnalysisUsecase,
        super(BranchReportAnalysisInitialState()) {
    on<FetchBranchReportAnalysisEvent>(_onFetchBranchReportAnalysis);
    on<ResetBranchReportAnalysisEvent>(_onResetBranchReportAnalysis);
    on<SearchBranchAnalysisEvent>(_onSearchBranchAnalysis);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onFetchBranchReportAnalysis(
    FetchBranchReportAnalysisEvent event,
    Emitter<BranchReportAnalysisState> emit,
  ) async {
    debugPrint('\n📱 ========== BranchReportAnalysisBloc Event ==========');
    debugPrint('🎯 Event: FetchBranchReportAnalysisEvent');
    debugPrint('📅 Start Date: ${event.startDate}');
    debugPrint('📅 End Date: ${event.endDate}');
    debugPrint('🏢 Branch: ${event.branchName ?? 'All'}');
    debugPrint('====================================================\n');
    
    emit(BranchReportAnalysisLoadingState());
    debugPrint('📤 Emitted: BranchReportAnalysisLoadingState');

    final result = await _fetchBranchReportAnalysisUsecase.call(
      FetchBranchReportAnalysisUsecaseParams(
        startDate: event.startDate,
        endDate: event.endDate,
        branch: event.branchName,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('\n❌ ========== BLOC ERROR ==========');
        debugPrint('💥 Failure: ${failure.message}');
        debugPrint('==================================\n');
        
        emit(BranchReportAnalysisErrorState(
          message: failure.message,
        ));
        debugPrint('📤 Emitted: BranchReportAnalysisErrorState');
      },
      (reports) {
        debugPrint('\n✅ ========== BLOC SUCCESS ==========');
        debugPrint('📊 Received ${reports.length} reports');
        if (reports.isNotEmpty) {
          debugPrint('📌 Reports:');
          for (var i = 0; i < (reports.length > 3 ? 3 : reports.length); i++) {
            debugPrint('   ${i + 1}. ${reports[i].name} (ID: ${reports[i].destinationBranch})');
          }
          if (reports.length > 3) {
            debugPrint('   ... and ${reports.length - 3} more');
          }
        }
        debugPrint('===================================\n');
        
        _allReports = reports;
        if (reports.isEmpty) {
          emit(BranchReportAnalysisEmptyState());
          debugPrint('📤 Emitted: BranchReportAnalysisEmptyState');
        } else {
          emit(BranchReportAnalysisLoadedState(
            branchReports: reports,
            filteredReports: reports,
          ));
          debugPrint('📤 Emitted: BranchReportAnalysisLoadedState (${reports.length} items)');
        }
      },
    );
  }

  void _onSearchBranchAnalysis(
    SearchBranchAnalysisEvent event,
    Emitter<BranchReportAnalysisState> emit,
  ) {
    final searchQuery = event.searchQuery.toLowerCase().trim();
    
    if (searchQuery.isEmpty) {
      emit(BranchReportAnalysisLoadedState(
        branchReports: _allReports,
        filteredReports: _allReports,
      ));
      return;
    }

    final filteredResults = event.allData.where((report) {
      return report.name.toLowerCase().contains(searchQuery) ||
             report.destinationBranch.toString().contains(searchQuery);
    }).toList();

    if (filteredResults.isEmpty) {
      emit(BranchReportAnalysisSearchResultState(
        searchResults: [],
      ));
    } else {
      emit(BranchReportAnalysisSearchResultState(
        searchResults: filteredResults,
      ));
    }
  }

  void _onClearSearch(
    ClearSearchEvent event,
    Emitter<BranchReportAnalysisState> emit,
  ) {
    if (_allReports.isNotEmpty) {
      emit(BranchReportAnalysisLoadedState(
        branchReports: _allReports,
        filteredReports: _allReports,
      ));
    } else {
      emit(BranchReportAnalysisInitialState());
    }
  }

  void _onResetBranchReportAnalysis(
    ResetBranchReportAnalysisEvent event,
    Emitter<BranchReportAnalysisState> emit,
  ) {
    _allReports = [];
    emit(BranchReportAnalysisInitialState());
  }

  
}