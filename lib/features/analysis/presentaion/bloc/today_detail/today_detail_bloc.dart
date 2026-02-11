import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/usecase/fetch_today_detailusecase.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/today_detail/today_detail_event.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/today_detail/today_detail_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton

class TodayDetailBloc extends Bloc<TodayDetailEvent, TodayDetailState> {
  final FetchTodayDetailusecase _fetchTodayDetailUsecase;
  StreamSubscription? _todayDetailSubscription;

  TodayDetailBloc({
    required FetchTodayDetailusecase fetchTodayDetailUsecase,
  })  : _fetchTodayDetailUsecase = fetchTodayDetailUsecase,
        super(TodayDetailInitialState()) {
    on<FetchTodayDetailEvent>(_onFetchTodayDetail);
    on<RefreshTodayDetailEvent>(_onRefreshTodayDetail);
  }

  Future<void> _onFetchTodayDetail(
    FetchTodayDetailEvent event,
    Emitter<TodayDetailState> emit,
  ) async {
    emit(TodayDetailLoadingState());

    final result = await _fetchTodayDetailUsecase.call(
      FetchTodayDetailusecaseParams(status: event.status),
    );

    result.fold(
      (failure) {
        // Treat "No orders found" as empty state instead of error
        if (failure.message.contains('No orders found')) {
          emit(TodayDetailEmptyState());
        } else {
          emit(TodayDetailErrorState(
            message: failure.message,
          ));
        }
      },
      (todayDetail) {
        if (todayDetail.sN == 0 || todayDetail.orderId == 0) {
          emit(TodayDetailEmptyState());
        } else {
          emit(TodayDetailLoadedState(todayDetailList: [todayDetail]));
        }
      },
    );
  }

  Future<void> _onRefreshTodayDetail(
    RefreshTodayDetailEvent event,
    Emitter<TodayDetailState> emit,
  ) async {
    emit(TodayDetailLoadingState());

    final result = await _fetchTodayDetailUsecase.call(
      FetchTodayDetailusecaseParams(status: event.status),
    );

    result.fold(
      (failure) {
        // Treat "No orders found" as empty state instead of error
        if (failure.message.contains('No orders found')) {
          emit(TodayDetailEmptyState());
        } else {
          emit(TodayDetailErrorState(
            message: failure.message,
          ));
        }
      },
      (todayDetail) {
        if (todayDetail.sN == 0 || todayDetail.orderId == 0) {
          emit(TodayDetailEmptyState());
        } else {
          emit(TodayDetailLoadedState(todayDetailList: [todayDetail]));
        }
      },
    );
  }



  @override
  Future<void> close() {
    _todayDetailSubscription?.cancel();
    return super.close();
  }
}