import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/core/services/secure_storage_service.dart';
import 'package:gaaubesi_vendor/app/home/domain/usecases/get_vendor_stats_usecase.dart';
import 'package:gaaubesi_vendor/app/home/presentation/bloc/home_event.dart';
import 'package:gaaubesi_vendor/app/home/presentation/bloc/home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetVendorStatsUseCase _getVendorStatsUseCase;
  final SecureStorageService _secureStorageService;
  static const String _showAmountsKey = 'show_amounts';

  HomeBloc(this._getVendorStatsUseCase, this._secureStorageService) : super(const HomeInitial()) {
    on<HomeLoadStats>(_onLoadStats);
    on<HomeRefreshStats>(_onRefreshStats);
    on<HomeToggleAmountVisibility>(_onToggleAmountVisibility);
  }

  Future<void> _onLoadStats(
    HomeLoadStats event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    final result = await _getVendorStatsUseCase(NoParams());
    
    // Load the visibility preference from secure storage
    final showAmountsString = await _secureStorageService.read(key: _showAmountsKey);
    final showAmounts = showAmountsString != null ? showAmountsString == 'true' : true;
    
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (stats) => emit(HomeLoaded(stats, showAmounts: showAmounts)),
    );
  }

  Future<void> _onRefreshStats(
    HomeRefreshStats event,
    Emitter<HomeState> emit,
  ) async {
    final result = await _getVendorStatsUseCase(NoParams());
    
    // Get current state to preserve showAmounts value
    final currentState = state;
    final showAmounts = currentState is HomeLoaded ? currentState.showAmounts : true;
    
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (stats) => emit(HomeLoaded(stats, showAmounts: showAmounts)),
    );
  }

  Future<void> _onToggleAmountVisibility(
    HomeToggleAmountVisibility event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final newShowAmounts = !currentState.showAmounts;
      
      // Save the preference to secure storage
      await _secureStorageService.write(
        key: _showAmountsKey,
        value: newShowAmounts.toString(),
      );
      
      // Emit new state with toggled visibility
      emit(HomeLoaded(currentState.stats, showAmounts: newShowAmounts));
    }
  }
}