import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/usecase/fetch_delivery_report_usecase.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/delivery/delivery_report_analysis_event.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/delivery/delivery_report_analysis_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton

class DeliveryReportAnalysisBloc
    extends Bloc<DeliveryReportAnalysisEvent, DeliveryReportAnalysisState> {
  final FetchDeliveryReportUsecase _fetchDeliveryReportUsecase;

  DeliveryReportAnalysisBloc({
    required FetchDeliveryReportUsecase fetchDeliveryReportUsecase,
  }) : _fetchDeliveryReportUsecase = fetchDeliveryReportUsecase,
       super(DeliveryReportAnalysisInitialState()) {
    on<FetchDeliveryReportAnalysisEvent>(_onFetchDeliveryReport);
    on<ResetDeliveryReportAnalysisEvent>(_onResetDeliveryReport);
  }

  Future<void> _onFetchDeliveryReport(
    FetchDeliveryReportAnalysisEvent event,
    Emitter<DeliveryReportAnalysisState> emit,
  ) async {
    emit(DeliveryReportAnalysisLoadingState());

    final result = await _fetchDeliveryReportUsecase.call(
      FetchDeliveryReportUsecaseParams(
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) {
        emit(DeliveryReportAnalysisErrorState(message: 'An error occurred'));
      },
      (deliveryReport) {
        if (deliveryReport.dailyReports.isEmpty) {
          emit(DeliveryReportAnalysisEmptyState());
        } else {
          emit(
            DeliveryReportAnalysisLoadedState(
              deliveryReportAnalysis: deliveryReport,
            ),
          );
        }
      },
    );
  }

  Future<void> _onResetDeliveryReport(
    ResetDeliveryReportAnalysisEvent event,
    Emitter<DeliveryReportAnalysisState> emit,
  ) async {
    emit(DeliveryReportAnalysisInitialState());
  }
}
