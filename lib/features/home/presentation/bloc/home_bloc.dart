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
    final result = await _getVendorStatsUseCase(NoParams());
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (stats) => emit(HomeLoaded(stats)),
    );
  }

  Future<void> _onRefreshStats(
    HomeRefreshStats event,
    Emitter<HomeState> emit,
  ) async {
    // Optionally keep showing the current stats while refreshing
    final result = await _getVendorStatsUseCase(NoParams());
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (stats) => emit(HomeLoaded(stats)),
    );
  }
}
