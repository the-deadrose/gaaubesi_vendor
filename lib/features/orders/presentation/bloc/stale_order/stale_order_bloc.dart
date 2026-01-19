import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/stale_order/stale_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/stale_order/stale_order_state.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/usecases/fetch_stale_orders_usecase.dart';

@injectable
class StaleOrderBloc extends Bloc<StaleOrderEvent, StaleOrderState> {
  final FetchStaleOrdersUseCase fetchStaleOrdersUseCase;

  StaleOrderBloc({
    required this.fetchStaleOrdersUseCase,
  }) : super(const StaleOrderInitial()) {
    on<StaleOrderLoadRequested>(_onStaleOrderLoadRequested);
    on<StaleOrderRefreshRequested>(_onStaleOrderRefreshRequested);
    on<StaleOrderLoadMoreRequested>(_onStaleOrderLoadMoreRequested);
  }

  Future<void> _onStaleOrderLoadRequested(
    StaleOrderLoadRequested event,
    Emitter<StaleOrderState> emit,
  ) async {
    emit(const StaleOrderLoading());

    final result = await fetchStaleOrdersUseCase(
      const FetchStaleOrdersParams(page: 1),
    );

    result.fold(
      (failure) => emit(StaleOrderError(message: failure.message)),
      (response) => emit(
        StaleOrderLoaded(
          orders: response.results,
          currentPage: 1,
          hasMore: response.hasMore,
        ),
      ),
    );
  }

  Future<void> _onStaleOrderRefreshRequested(
    StaleOrderRefreshRequested event,
    Emitter<StaleOrderState> emit,
  ) async {
    final currentState = state;

    if (currentState is StaleOrderLoaded) {
    }

    final result = await fetchStaleOrdersUseCase(
      const FetchStaleOrdersParams(page: 1),
    );

    result.fold(
      (failure) => emit(StaleOrderError(message: failure.message)),
      (response) => emit(
        StaleOrderLoaded(
          orders: response.results,
          currentPage: 1,
          hasMore: response.hasMore,
        ),
      ),
    );
  }

  Future<void> _onStaleOrderLoadMoreRequested(
    StaleOrderLoadMoreRequested event,
    Emitter<StaleOrderState> emit,
  ) async {
    final currentState = state;

    if (currentState is! StaleOrderLoaded) return;
    if (!currentState.hasMore) return;

    emit(StaleOrderLoadingMore(
      orders: currentState.orders,
      currentPage: currentState.currentPage,
    ));

    final result = await fetchStaleOrdersUseCase(
      FetchStaleOrdersParams(page: currentState.currentPage + 1),
    );

    result.fold(
      (failure) => emit(StaleOrderError(message: failure.message)),
      (response) => emit(
        StaleOrderLoaded(
          orders: [...currentState.orders, ...response.results],
          currentPage: currentState.currentPage + 1,
          hasMore: response.hasMore,
        ),
      ),
    );
  }
}
