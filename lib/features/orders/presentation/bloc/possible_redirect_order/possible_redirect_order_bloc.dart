import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/possible_redirect_order/possible_redirect_order_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/possible_redirect_order/possible_redirect_order_state.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/usecases/fetch_possible_redirect_orders_usecase.dart';

@injectable
class PossibleRedirectOrderBloc
    extends Bloc<PossibleRedirectOrderEvent, PossibleRedirectOrderState> {
  final FetchPossibleRedirectOrdersUseCase fetchPossibleRedirectOrdersUseCase;

  PossibleRedirectOrderBloc({required this.fetchPossibleRedirectOrdersUseCase})
    : super(const PossibleRedirectOrderInitial()) {
    on<PossibleRedirectOrderLoadRequested>(
      _onPossibleRedirectOrderLoadRequested,
    );
    on<PossibleRedirectOrderRefreshRequested>(
      _onPossibleRedirectOrderRefreshRequested,
    );
    on<PossibleRedirectOrderLoadMoreRequested>(
      _onPossibleRedirectOrderLoadMoreRequested,
    );
    on<PossibleRedirectOrderFilterChanged>(
      _onPossibleRedirectOrderFilterChanged,
    );
  }

  Future<void> _onPossibleRedirectOrderLoadRequested(
    PossibleRedirectOrderLoadRequested event,
    Emitter<PossibleRedirectOrderState> emit,
  ) async {
    emit(const PossibleRedirectOrderLoading());

    final result = await fetchPossibleRedirectOrdersUseCase(
      const FetchPossibleRedirectOrdersParams(page: 1),
    );

    result.fold(
      (failure) => emit(PossibleRedirectOrderError(failure.message)),
      (response) => emit(
        PossibleRedirectOrderLoaded(
          orders: response.results,
          currentPage: 1,
          hasMore: response.hasMore,
          totalPages: response.totalPages,
        ),
      ),
    );
  }

  Future<void> _onPossibleRedirectOrderRefreshRequested(
    PossibleRedirectOrderRefreshRequested event,
    Emitter<PossibleRedirectOrderState> emit,
  ) async {
    final currentState = state;

    // Keep showing current data while refreshing
    if (currentState is PossibleRedirectOrderLoaded) {
      emit(const PossibleRedirectOrderLoading());
    }

    final result = await fetchPossibleRedirectOrdersUseCase(
      const FetchPossibleRedirectOrdersParams(page: 1),
    );

    result.fold(
      (failure) => emit(PossibleRedirectOrderError(failure.message)),
      (response) => emit(
        PossibleRedirectOrderLoaded(
          orders: response.results,
          currentPage: 1,
          hasMore: response.hasMore,
          totalPages: response.totalPages,
        ),
      ),
    );
  }

  Future<void> _onPossibleRedirectOrderLoadMoreRequested(
    PossibleRedirectOrderLoadMoreRequested event,
    Emitter<PossibleRedirectOrderState> emit,
  ) async {
    final currentState = state;

    if (currentState is! PossibleRedirectOrderLoaded || !currentState.hasMore) {
      return;
    }

    final nextPage = currentState.currentPage + 1;

    emit(
      PossibleRedirectOrderLoadingMore(
        orders: currentState.orders,
        currentPage: currentState.currentPage,
        hasMore: currentState.hasMore,
        totalPages: currentState.totalPages,
        destination: currentState.destination,
        startDate: currentState.startDate,
        endDate: currentState.endDate,
        receiverSearch: currentState.receiverSearch,
        minCharge: currentState.minCharge,
        maxCharge: currentState.maxCharge,
      ),
    );

    final result = await fetchPossibleRedirectOrdersUseCase(
      FetchPossibleRedirectOrdersParams(
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
        PossibleRedirectOrderLoaded(
          orders: [...currentState.orders, ...response.results],
          currentPage: nextPage,
          hasMore: response.hasMore,
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

  Future<void> _onPossibleRedirectOrderFilterChanged(
    PossibleRedirectOrderFilterChanged event,
    Emitter<PossibleRedirectOrderState> emit,
  ) async {
    emit(const PossibleRedirectOrderLoading());

    final result = await fetchPossibleRedirectOrdersUseCase(
      FetchPossibleRedirectOrdersParams(
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
      (failure) => emit(PossibleRedirectOrderError(failure.message)),
      (response) => emit(
        PossibleRedirectOrderLoaded(
          orders: response.results,
          currentPage: 1,
          hasMore: response.hasMore,
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
