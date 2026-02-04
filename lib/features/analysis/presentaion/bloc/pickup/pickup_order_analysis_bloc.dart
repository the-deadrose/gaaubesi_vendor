import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/usecase/fetch_pickup_order_analysis_usecase.dart';
import 'package:injectable/injectable.dart';
import 'pickup_order_analysis_event.dart';
import 'pickup_order_analysis_state.dart';

@lazySingleton

class PickupOrderAnalysisBloc
    extends Bloc<PickupOrderAnalysisEvent, PickupOrderAnalysisState> {
  final FetchPickupOrderAnalysisUsecase fetchPickupOrderAnalysisUsecase;

  PickupOrderAnalysisBloc({required this.fetchPickupOrderAnalysisUsecase})
    : super(PickupOrderAnalysisInitial()) {
    on<FetchPickupOrderAnalysisEvent>(_onFetchPickupOrderAnalysis);
    on<ResetPickupOrderAnalysisEvent>(_onResetPickupOrderAnalysis);
  }

  Future<void> _onFetchPickupOrderAnalysis(
    FetchPickupOrderAnalysisEvent event,
    Emitter<PickupOrderAnalysisState> emit,
  ) async {
    if (state is PickupOrderAnalysisLoaded &&
        (state as PickupOrderAnalysisLoaded).analysis.fromDate ==
            event.startDate &&
        (state as PickupOrderAnalysisLoaded).analysis.toDate == event.endDate) {
      emit(PickupOrderAnalysisLoading());
    } else {
      emit(PickupOrderAnalysisIsFiltering());
    }

    final result = await fetchPickupOrderAnalysisUsecase(
      FetchPickupOrderAnalysisUsecaseParams(
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) {
        emit(PickupOrderAnalysisError(message: failure.message));
      },
      (analysisList) {
        if (analysisList.isEmpty) {
          emit(PickupOrderAnalysisEmpty());
        } else {
          final analysis = analysisList.first;

          if (state is PickupOrderAnalysisIsFiltering) {
            emit(PickupOrderAnalysisFiltered(analysis: analysis));
          } else {
            emit(PickupOrderAnalysisLoaded(analysis: analysis));
          }
        }
      },
    );
  }

  void _onResetPickupOrderAnalysis(
    ResetPickupOrderAnalysisEvent event,
    Emitter<PickupOrderAnalysisState> emit,
  ) {
    emit(PickupOrderAnalysisInitial());
  }
}
