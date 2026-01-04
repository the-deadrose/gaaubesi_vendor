import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/app/orders/domain/entities/order_entity.dart';
import 'package:gaaubesi_vendor/app/orders/domain/usecases/fetch_orders_usecase.dart';
import 'package:gaaubesi_vendor/app/orders/presentation/bloc/order_event.dart';
import 'package:gaaubesi_vendor/app/orders/presentation/bloc/order_state.dart';

@injectable
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final FetchOrdersUseCase fetchOrdersUseCase;

  OrderBloc({required this.fetchOrdersUseCase}) : super(const OrderInitial()) {
    on<OrderLoadRequested>(_onOrderLoadRequested);
    on<OrderRefreshRequested>(_onOrderRefreshRequested);
    on<OrderLoadMoreRequested>(_onOrderLoadMoreRequested);
    on<OrderStatusFilterChanged>(_onOrderStatusFilterChanged);
    on<OrderSearchQueryChanged>(_onOrderSearchQueryChanged);
    on<OrderFilterChanged>(_onOrderFilterChanged);
    on<OrderAdvancedFilterChanged>(_onOrderAdvancedFilterChanged);
    on<OrderStatsRequested>(_onOrderStatsRequested);
  }

  Future<void> _onOrderLoadRequested(
    OrderLoadRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoading());

    final result = await fetchOrdersUseCase(
      FetchOrdersParams(page: 1, status: event.status),
    );

    result.fold((failure) => emit(OrderError(message: failure.message)), (
      response,
    ) {
      emit(
        OrderLoaded(
          orders: response.results,
          currentPage: 1,
          hasMore: response.hasMore,
          currentStatus: event.status,
          // Initialize stats with total count from response if status is null (All Orders)
          stats: event.status == null
              ? OrderStats(total: response.count)
              : const OrderStats(),
        ),
      );
      // Fetch full stats if we just loaded
      add(const OrderStatsRequested());
    });
  }

  Future<void> _onOrderRefreshRequested(
    OrderRefreshRequested event,
    Emitter<OrderState> emit,
  ) async {
    final currentState = state;
    // Preserve existing state values if possible
    String searchQuery = '';
    Set<String> activeFilters = {};
    OrderStats stats = const OrderStats();
    String? sourceBranch;
    String? destinationBranch;
    String? startDate;
    String? endDate;

    if (currentState is OrderLoaded) {
      searchQuery = currentState.searchQuery;
      activeFilters = currentState.activeFilters;
      stats = currentState.stats;
      sourceBranch = currentState.sourceBranch;
      destinationBranch = currentState.destinationBranch;
      startDate = currentState.startDate;
      endDate = currentState.endDate;
    }

    final result = await fetchOrdersUseCase(
      FetchOrdersParams(
        page: 1,
        status: event.status,
        sourceBranch: sourceBranch,
        destinationBranch: destinationBranch,
        startDate: startDate,
        endDate: endDate,
      ),
    );

    result.fold(
      (failure) => emit(OrderError(message: failure.message)),
      (response) => emit(
        OrderLoaded(
          orders: response.results,
          currentPage: 1,
          hasMore: response.hasMore,
          currentStatus: event.status,
          searchQuery: searchQuery,
          activeFilters: activeFilters,
          stats: stats,
          sourceBranch: sourceBranch,
          destinationBranch: destinationBranch,
          startDate: startDate,
          endDate: endDate,
        ),
      ),
    );
  }

  Future<void> _onOrderLoadMoreRequested(
    OrderLoadMoreRequested event,
    Emitter<OrderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OrderLoaded || !currentState.hasMore) return;

    emit(
      OrderLoadingMore(
        orders: currentState.orders,
        currentPage: currentState.currentPage,
        currentStatus: currentState.currentStatus,
        searchQuery: currentState.searchQuery,
        activeFilters: currentState.activeFilters,
        stats: currentState.stats,
        sourceBranch: currentState.sourceBranch,
        destinationBranch: currentState.destinationBranch,
        startDate: currentState.startDate,
        endDate: currentState.endDate,
      ),
    );

    final nextPage = currentState.currentPage + 1;
    final result = await fetchOrdersUseCase(
      FetchOrdersParams(
        page: nextPage,
        status: currentState.currentStatus,
        sourceBranch: currentState.sourceBranch,
        destinationBranch: currentState.destinationBranch,
        startDate: currentState.startDate,
        endDate: currentState.endDate,
      ),
    );

    result.fold((failure) => emit(OrderError(message: failure.message)), (
      response,
    ) {
      final updatedOrders = List<OrderEntity>.from(currentState.orders)
        ..addAll(response.results);

      emit(
        OrderLoaded(
          orders: updatedOrders,
          currentPage: nextPage,
          hasMore: response.hasMore,
          currentStatus: currentState.currentStatus,
          searchQuery: currentState.searchQuery,
          activeFilters: currentState.activeFilters,
          stats: currentState.stats,
          sourceBranch: currentState.sourceBranch,
          destinationBranch: currentState.destinationBranch,
          startDate: currentState.startDate,
          endDate: currentState.endDate,
        ),
      );
    });
  }

  Future<void> _onOrderStatusFilterChanged(
    OrderStatusFilterChanged event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoading());

    final result = await fetchOrdersUseCase(
      FetchOrdersParams(page: 1, status: event.status),
    );

    result.fold(
      (failure) => emit(OrderError(message: failure.message)),
      (response) => emit(
        OrderLoaded(
          orders: response.results,
          currentPage: 1,
          hasMore: response.hasMore,
          currentStatus: event.status,
        ),
      ),
    );
  }

  void _onOrderSearchQueryChanged(
    OrderSearchQueryChanged event,
    Emitter<OrderState> emit,
  ) {
    final currentState = state;
    if (currentState is OrderLoaded) {
      emit(currentState.copyWith(searchQuery: event.query));
    }
  }

  void _onOrderFilterChanged(
    OrderFilterChanged event,
    Emitter<OrderState> emit,
  ) {
    final currentState = state;
    if (currentState is OrderLoaded) {
      final newFilters = Set<String>.from(currentState.activeFilters);
      if (newFilters.contains(event.filterId)) {
        newFilters.remove(event.filterId);
      } else {
        newFilters.add(event.filterId);
      }
      emit(currentState.copyWith(activeFilters: newFilters));
    }
  }

  Future<void> _onOrderAdvancedFilterChanged(
    OrderAdvancedFilterChanged event,
    Emitter<OrderState> emit,
  ) async {
    final currentState = state;
    // If we are not in a loaded state, we can't apply filters properly or we should reset
    // For now assuming we are in loaded state or can transition to loading

    emit(const OrderLoading());

    final result = await fetchOrdersUseCase(
      FetchOrdersParams(
        page: 1,
        status: event.status,
        sourceBranch: event.sourceBranch,
        destinationBranch: event.destinationBranch,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(OrderError(message: failure.message)),
      (response) => emit(
        OrderLoaded(
          orders: response.results,
          currentPage: 1,
          hasMore: response.hasMore,
          currentStatus: event.status,
          sourceBranch: event.sourceBranch,
          destinationBranch: event.destinationBranch,
          startDate: event.startDate,
          endDate: event.endDate,
          // Preserve stats if possible, or re-fetch
          stats: currentState is OrderLoaded
              ? currentState.stats
              : const OrderStats(),
        ),
      ),
    );
  }

  Future<void> _onOrderStatsRequested(
    OrderStatsRequested event,
    Emitter<OrderState> emit,
  ) async {
    // In a real app, we would call a usecase to get stats
    // For now, we'll just try to fetch counts for each status
    // This is not efficient but works for demo

    // We don't want to block UI, so we don't emit loading

    final totalResult = await fetchOrdersUseCase(
      const FetchOrdersParams(page: 1),
    );
    final transitResult = await fetchOrdersUseCase(
      const FetchOrdersParams(page: 1, status: 'transit'),
    );
    final deliveredResult = await fetchOrdersUseCase(
      const FetchOrdersParams(page: 1, status: 'delivered'),
    );

    int total = 0;
    int inTransit = 0;
    int delivered = 0;

    totalResult.fold((_) {}, (r) => total = r.count);
    transitResult.fold((_) {}, (r) => inTransit = r.count);
    deliveredResult.fold((_) {}, (r) => delivered = r.count);

    final currentState = state;
    if (currentState is OrderLoaded) {
      emit(
        currentState.copyWith(
          stats: OrderStats(
            total: total,
            inTransit: inTransit,
            delivered: delivered,
          ),
        ),
      );
    }
  }
}
