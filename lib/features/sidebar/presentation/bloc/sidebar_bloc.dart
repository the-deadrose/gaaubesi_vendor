import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/sidebar/domain/usecase/sidebar_usecase.dart';
import 'package:gaaubesi_vendor/features/sidebar/presentation/bloc/sidebar_event.dart';
import 'package:gaaubesi_vendor/features/sidebar/presentation/bloc/sidebar_state.dart';
import 'package:injectable/injectable.dart';


@lazySingleton
class SidebarBloc extends Bloc<SidebarEvent, SidebarState> {
  final SidebarUsecase _sidebarUsecase;
  final GetCachedSidebarUsecase _getCachedSidebarUsecase;
  final ClearSidebarCacheUsecase _clearSidebarCacheUsecase;

  SidebarBloc(
    this._sidebarUsecase,
    this._getCachedSidebarUsecase,
    this._clearSidebarCacheUsecase,
  ) : super(SidebarInitialState()) {
    on<FetchSidebarDataEvent>(_onFetchSidebarData);
    on<LoadCachedSidebarDataEvent>(_onLoadCachedSidebarData);
    on<ClearSidebarCacheEvent>(_onClearSidebarCache);
  }

  Future<void> _onFetchSidebarData(
    FetchSidebarDataEvent event,
    Emitter<SidebarState> emit,
  ) async {
    emit(SidebarLoadingState());
    final result = await _sidebarUsecase(NoParams());
    result.fold(
      (failure) => emit(SidebarErrorState(failure.toString())),
      (items) => emit(SidebarLoadedState(items)),
    );
  }

  Future<void> _onLoadCachedSidebarData(
    LoadCachedSidebarDataEvent event,
    Emitter<SidebarState> emit,
  ) async {
    final result = await _getCachedSidebarUsecase(NoParams());
    result.fold(
      (failure) {
        // If no cache available, emit initial state instead of error
        emit(SidebarInitialState());
      },
      (items) => emit(SidebarLoadedState(items)),
    );
  }

  Future<void> _onClearSidebarCache(
    ClearSidebarCacheEvent event,
    Emitter<SidebarState> emit,
  ) async {
    final result = await _clearSidebarCacheUsecase(NoParams());
    result.fold(
      (failure) => emit(SidebarErrorState(failure.toString())),
      (_) => emit(SidebarInitialState()),
    );
  }
}
