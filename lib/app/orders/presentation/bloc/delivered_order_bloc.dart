import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/app/orders/domain/entities/delivered_order_entity.dart';
import 'package:gaaubesi_vendor/app/orders/domain/usecases/fetch_delivered_orders_usecase.dart';
import 'package:gaaubesi_vendor/app/orders/presentation/bloc/delivered_order_event.dart';
import 'package:gaaubesi_vendor/app/orders/presentation/bloc/delivered_order_state.dart';

@injectable
class DeliveredOrderBloc
    extends Bloc<DeliveredOrderEvent, DeliveredOrderState> {
  final FetchDeliveredOrdersUseCase fetchDeliveredOrdersUseCase;

  DeliveredOrderBloc({required this.fetchDeliveredOrdersUseCase})
      : super(const DeliveredOrderInitial()) {
    on<DeliveredOrderLoadRequested>(_onDeliveredOrderLoadRequested);
    on<DeliveredOrderRefreshRequested>(_onDeliveredOrderRefreshRequested);
    on<DeliveredOrderLoadMoreRequested>(_onDeliveredOrderLoadMoreRequested);
  }

  Future<void> _onDeliveredOrderLoadRequested(
    DeliveredOrderLoadRequested event,
    Emitter<DeliveredOrderState> emit,
  ) async {
    emit(const DeliveredOrderLoading());

    final result = await fetchDeliveredOrdersUseCase(
      const FetchDeliveredOrdersParams(page: 1),
    );

    result.fold(
      (failure) => emit(DeliveredOrderError(message: failure.message)),
      (response) => emit(
        DeliveredOrderLoaded(
          orders: response.results,
          currentPage: 1,
          hasMore: response.hasMore,
          totalCount: response.count,
          totalPages: response.totalPages,
        ),
      ),
    );
  }

  Future<void> _onDeliveredOrderRefreshRequested(
    DeliveredOrderRefreshRequested event,
    Emitter<DeliveredOrderState> emit,
  ) async {
    final currentState = state;

    // Keep showing current data while refreshing
    if (currentState is DeliveredOrderLoaded) {
      emit(const DeliveredOrderLoading());
    }

    final result = await fetchDeliveredOrdersUseCase(
      const FetchDeliveredOrdersParams(page: 1),
    );

    result.fold(
      (failure) => emit(DeliveredOrderError(message: failure.message)),
      (response) => emit(
        DeliveredOrderLoaded(
          orders: response.results,
          currentPage: 1,
          hasMore: response.hasMore,
          totalCount: response.count,
          totalPages: response.totalPages,
        ),
      ),
    );
  }

  Future<void> _onDeliveredOrderLoadMoreRequested(
    DeliveredOrderLoadMoreRequested event,
    Emitter<DeliveredOrderState> emit,
  ) async {
    final currentState = state;

    if (currentState is! DeliveredOrderLoaded || !currentState.hasMore) {
      return;
    }

    emit(
      DeliveredOrderLoadingMore(
        orders: currentState.orders,
        currentPage: currentState.currentPage,
        totalCount: currentState.totalCount,
        totalPages: currentState.totalPages,
      ),
    );

    final nextPage = currentState.currentPage + 1;
    final result = await fetchDeliveredOrdersUseCase(
      FetchDeliveredOrdersParams(page: nextPage),
    );

    result.fold(
      (failure) => emit(DeliveredOrderError(message: failure.message)),
      (response) {
        final updatedOrders = List<DeliveredOrderEntity>.from(currentState.orders)
          ..addAll(response.results);

        emit(
          DeliveredOrderLoaded(
            orders: updatedOrders,
            currentPage: nextPage,
            hasMore: response.hasMore,
            totalCount: response.count,
            totalPages: response.totalPages,
          ),
        );
      },
    );
  }
}
