import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/usecase/fetch_sales_report_analysis_usecase.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/sales/sales_report_analysis_event.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/sales/sales_report_analysis_state.dart';
import 'package:injectable/injectable.dart';


@lazySingleton

class SalesReportAnalysisBloc
    extends Bloc<SalesReportAnalysisEvent, SalesReportAnalysisState> {
  final FetchSalesReportAnalysisUsecase _fetchSalesReportAnalysisUsecase;

  SalesReportAnalysisBloc(this._fetchSalesReportAnalysisUsecase)
    : super(SalesReportAnalysisInitial()) {
    on<FetchSalesReportAnalysisEvent>(_onFetchSalesReportAnalysis);
    on<ResetSalesReportAnalysisEvent>(_onResetSalesReportAnalysis);
  }

  Future<void> _onFetchSalesReportAnalysis(
    FetchSalesReportAnalysisEvent event,
    Emitter<SalesReportAnalysisState> emit,
  ) async {
    emit(SalesReportAnalysisLoading());

    final result = await _fetchSalesReportAnalysisUsecase.call(
      FetchSalesReportAnalysisUsecaseParams(
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(SalesReportAnalysisError(message: failure.message)),
      (salesReport) {
        if (salesReport.dailyReports.isEmpty) {
          emit(SalesReportAnalysisEmpty());
        } else {
          emit(SalesReportAnalysisLoaded(salesReportAnalysis: salesReport));
        }
      },
    );
  }

  Future<void> _onResetSalesReportAnalysis(
    ResetSalesReportAnalysisEvent event,
    Emitter<SalesReportAnalysisState> emit,
  ) async {
    emit(SalesReportAnalysisInitial());
  }
}
