import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/delivered_order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/usecases/fetch_delivered_orders_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/delivered_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/delivered_order_state.dart';

@injectable
class DeliveredOrderBloc
    extends Bloc<DeliveredOrderEvent, DeliveredOrderState> {
  final FetchDeliveredOrdersUseCase fetchDeliveredOrdersUseCase;

  DeliveredOrderBloc({required this.fetchDeliveredOrdersUseCase})
    : super(const DeliveredOrderInitial()) {
    on<DeliveredOrderLoadRequested>(_onDeliveredOrderLoadRequested);
    on<DeliveredOrderRefreshRequested>(_onDeliveredOrderRefreshRequested);
    on<DeliveredOrderLoadMoreRequested>(_onDeliveredOrderLoadMoreRequested);
    on<DeliveredOrderFilterChanged>(_onDeliveredOrderFilterChanged);
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
        destination: currentState.destination,
        startDate: currentState.startDate,
        endDate: currentState.endDate,
        receiverSearch: currentState.receiverSearch,
        minCharge: currentState.minCharge,
        maxCharge: currentState.maxCharge,
      ),
    );

    final nextPage = currentState.currentPage + 1;
    final result = await fetchDeliveredOrdersUseCase(
      FetchDeliveredOrdersParams(
        page: nextPage,
        destination: currentState.destination,
        startDate: currentState.startDate,
        endDate: currentState.endDate,
        receiverSearch: currentState.receiverSearch,
        minCharge: currentState.minCharge,
        maxCharge: currentState.maxCharge,
      ),
    );

    result.fold(
      (failure) => emit(DeliveredOrderError(message: failure.message)),
      (response) {
        final updatedOrders = List<DeliveredOrderEntity>.from(
          currentState.orders,
        )..addAll(response.results);

        emit(
          DeliveredOrderLoaded(
            orders: updatedOrders,
            currentPage: nextPage,
            hasMore: response.hasMore,
            totalCount: response.count,
            totalPages: response.totalPages,
            destination: currentState.destination,
            startDate: currentState.startDate,
            endDate: currentState.endDate,
            receiverSearch: currentState.receiverSearch,
            minCharge: currentState.minCharge,
            maxCharge: currentState.maxCharge,
          ),
        );
      },
    );
  }

  Future<void> _onDeliveredOrderFilterChanged(
    DeliveredOrderFilterChanged event,
    Emitter<DeliveredOrderState> emit,
  ) async {
    emit(const DeliveredOrderLoading());

    final result = await fetchDeliveredOrdersUseCase(
      FetchDeliveredOrdersParams(
        page: 1,
        destination: event.destination,
        startDate: event.startDate,
        endDate: event.endDate,
        receiverSearch: event.receiverSearch,
        minCharge: event.minCharge,
        maxCharge: event.maxCharge,
      ),
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
          destination: event.destination,
          startDate: event.startDate,
          endDate: event.endDate,
          receiverSearch: event.receiverSearch,
          minCharge: event.minCharge,
          maxCharge: event.maxCharge,
        ),
      ),
    );
  }
}
