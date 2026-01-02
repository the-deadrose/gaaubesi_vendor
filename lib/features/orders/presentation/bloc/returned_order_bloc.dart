import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/usecases/fetch_returned_orders_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/returned_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/returned_order_state.dart';

@injectable
class ReturnedOrderBloc extends Bloc<ReturnedOrderEvent, ReturnedOrderState> {
  final FetchReturnedOrdersUseCase fetchReturnedOrdersUseCase;

  ReturnedOrderBloc({required this.fetchReturnedOrdersUseCase})
    : super(const ReturnedOrderInitial()) {
    on<ReturnedOrderLoadRequested>(_onReturnedOrderLoadRequested);
    on<ReturnedOrderRefreshRequested>(_onReturnedOrderRefreshRequested);
    on<ReturnedOrderLoadMoreRequested>(_onReturnedOrderLoadMoreRequested);
    on<ReturnedOrderFilterChanged>(_onReturnedOrderFilterChanged);
  }

  Future<void> _onReturnedOrderLoadRequested(
    ReturnedOrderLoadRequested event,
    Emitter<ReturnedOrderState> emit,
  ) async {
    emit(const ReturnedOrderLoading());

    final result = await fetchReturnedOrdersUseCase(
      const FetchReturnedOrdersParams(page: 1),
    );

    result.fold(
      (failure) => emit(ReturnedOrderError(message: failure.message)),
      (response) => emit(
        ReturnedOrderLoaded(
          orders: response.results,
          currentPage: 1,
          hasMore: response.hasMore,
          totalCount: response.count,
          totalPages: response.totalPages,
        ),
      ),
    );
  }

  Future<void> _onReturnedOrderRefreshRequested(
    ReturnedOrderRefreshRequested event,
    Emitter<ReturnedOrderState> emit,
  ) async {
    final currentState = state;

    // Keep showing current data while refreshing
    if (currentState is ReturnedOrderLoaded) {
      emit(const ReturnedOrderLoading());
    }

    final result = await fetchReturnedOrdersUseCase(
      const FetchReturnedOrdersParams(page: 1),
    );

    result.fold(
      (failure) => emit(ReturnedOrderError(message: failure.message)),
      (response) => emit(
        ReturnedOrderLoaded(
          orders: response.results,
          currentPage: 1,
          hasMore: response.hasMore,
          totalCount: response.count,
          totalPages: response.totalPages,
        ),
      ),
    );
  }

  Future<void> _onReturnedOrderLoadMoreRequested(
    ReturnedOrderLoadMoreRequested event,
    Emitter<ReturnedOrderState> emit,
  ) async {
    final currentState = state;

    if (currentState is! ReturnedOrderLoaded || !currentState.hasMore) {
      return;
    }

    final nextPage = currentState.currentPage + 1;

    emit(
      ReturnedOrderLoadingMore(
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

    final result = await fetchReturnedOrdersUseCase(
      FetchReturnedOrdersParams(
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
      (failure) => emit(currentState.copyWith()),
      (response) => emit(
        ReturnedOrderLoaded(
          orders: [...currentState.orders, ...response.results],
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
      ),
    );
  }

  Future<void> _onReturnedOrderFilterChanged(
    ReturnedOrderFilterChanged event,
    Emitter<ReturnedOrderState> emit,
  ) async {
    emit(const ReturnedOrderLoading());

    final result = await fetchReturnedOrdersUseCase(
      FetchReturnedOrdersParams(
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
      (failure) => emit(ReturnedOrderError(message: failure.message)),
      (response) => emit(
        ReturnedOrderLoaded(
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
