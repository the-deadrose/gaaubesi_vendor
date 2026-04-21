import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/home/domain/usecases/get_vendor_stats_usecase.dart';
import 'package:gaaubesi_vendor/features/home/presentation/bloc/home_event.dart';
import 'package:gaaubesi_vendor/features/home/presentation/bloc/home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetVendorStatsUseCase _getVendorStatsUseCase;

  HomeBloc(this._getVendorStatsUseCase) : super(const HomeInitial()) {
    on<HomeLoadStats>(_onLoadStats);
    on<HomeRefreshStats>(_onRefreshStats);
  }

  Future<void> _onLoadStats(
    HomeLoadStats event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    final result = await _getVendorStatsUseCase.call(NoParams());
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (stats) => emit(HomeLoaded(stats)),
    );
  }

  Future<void> _onRefreshStats(
    HomeRefreshStats event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final current = state;
      if (current is HomeLoaded) {
        emit(HomeRefreshing(current.stats));
      } else if (current is HomeRefreshing) {
        // already refreshing — no-op
      } else {
        emit(const HomeLoading());
      }
      final result = await _getVendorStatsUseCase.call(NoParams());
      result.fold((failure) => emit(HomeError(failure.message)), (stats) {
        debugPrint(
          '[HomeBloc] emitting HomeLoaded — todayOrderCreated=${stats.todayOrderCreated}, instance=${identityHashCode(this)}',
        );
        emit(HomeLoaded(stats));
      });
    } finally {
      event.completer?.complete();
    }
  }

  @override
  void onChange(Change<HomeState> change) {
    super.onChange(change);
    final next = change.nextState;
    final nextCreated = next is HomeLoaded
        ? next.stats.todayOrderCreated
        : next is HomeRefreshing
        ? next.stats.todayOrderCreated
        : null;
    debugPrint(
      '[HomeBloc] onChange: ${change.currentState.runtimeType} -> ${next.runtimeType}  todayOrderCreated=$nextCreated',
    );
  }
}
