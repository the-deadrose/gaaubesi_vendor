import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/usecases/fetch_rtv_orders_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/rtv_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/rtv_order_state.dart';

@injectable
class RtvOrderBloc extends Bloc<RtvOrderEvent, RtvOrderState> {
  final FetchRtvOrdersUseCase fetchRtvOrdersUseCase;

  RtvOrderBloc({required this.fetchRtvOrdersUseCase})
    : super(const RtvOrderInitial()) {
    on<RtvOrderLoadRequested>(_onRtvOrderLoadRequested);
    on<RtvOrderRefreshRequested>(_onRtvOrderRefreshRequested);
    on<RtvOrderLoadMoreRequested>(_onRtvOrderLoadMoreRequested);
    on<RtvOrderFilterChanged>(_onRtvOrderFilterChanged);
  }

  Future<void> _onRtvOrderLoadRequested(
    RtvOrderLoadRequested event,
    Emitter<RtvOrderState> emit,
  ) async {
    emit(const RtvOrderLoading());

    final result = await fetchRtvOrdersUseCase(
      const FetchRtvOrdersParams(page: 1),
    );

    result.fold((failure) => emit(RtvOrderError(message: failure.message)), (
      response,
    ) {
      final hasMore = response.totalPages > 1;
      emit(
        RtvOrderLoaded(
          orders: response.results,
          currentPage: 1,
          hasMore: hasMore,
          totalCount: response.count,
          totalPages: response.totalPages,
        ),
      );
    });
  }

  Future<void> _onRtvOrderRefreshRequested(
    RtvOrderRefreshRequested event,
    Emitter<RtvOrderState> emit,
  ) async {
    emit(const RtvOrderLoading());

    final result = await fetchRtvOrdersUseCase(
      const FetchRtvOrdersParams(page: 1),
    );

    result.fold((failure) => emit(RtvOrderError(message: failure.message)), (
      response,
    ) {
      final hasMore = response.totalPages > 1;
      emit(
        RtvOrderLoaded(
          orders: response.results,
          currentPage: 1,
          hasMore: hasMore,
          totalCount: response.count,
          totalPages: response.totalPages,
        ),
      );
    });
  }

  Future<void> _onRtvOrderLoadMoreRequested(
    RtvOrderLoadMoreRequested event,
    Emitter<RtvOrderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RtvOrderLoaded || !currentState.hasMore) return;

    final nextPage = currentState.currentPage + 1;

    emit(
      RtvOrderLoadingMore(
        orders: currentState.orders,
        currentPage: currentState.currentPage,
        hasMore: currentState.hasMore,
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

    final result = await fetchRtvOrdersUseCase(
      FetchRtvOrdersParams(
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
      (failure) => emit(
        currentState.copyWith(), // Revert to previous state
      ),
      (response) {
        final allOrders = [...currentState.orders, ...response.results];
        final hasMore = nextPage < response.totalPages;

        emit(
          RtvOrderLoaded(
            orders: allOrders,
            currentPage: nextPage,
            hasMore: hasMore,
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

  Future<void> _onRtvOrderFilterChanged(
    RtvOrderFilterChanged event,
    Emitter<RtvOrderState> emit,
  ) async {
    emit(const RtvOrderLoading());

    final result = await fetchRtvOrdersUseCase(
      FetchRtvOrdersParams(
        page: 1,
        destination: event.destination,
        startDate: event.startDate,
        endDate: event.endDate,
        receiverSearch: event.receiverSearch,
        minCharge: event.minCharge,
        maxCharge: event.maxCharge,
      ),
    );

    result.fold((failure) => emit(RtvOrderError(message: failure.message)), (
      response,
    ) {
      final hasMore = response.totalPages > 1;
      emit(
        RtvOrderLoaded(
          orders: response.results,
          currentPage: 1,
          hasMore: hasMore,
          totalCount: response.count,
          totalPages: response.totalPages,
          destination: event.destination,
          startDate: event.startDate,
          endDate: event.endDate,
          receiverSearch: event.receiverSearch,
          minCharge: event.minCharge,
          maxCharge: event.maxCharge,
        ),
      );
    });
  }
}
