import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/domain/usecases/fetch_redirected_usecsae.dart';
import 'package:gaaubesi_vendor/features/orders/domain/usecases/fetch_todays_redirect_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_order_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/redirected_order/redirect_orders_event.dart';
import 'package:injectable/injectable.dart';

@injectable
class RedirectedOrdersBloc
    extends Bloc<RedirectOrdersEvent, RedirectOrderState> {
  final FetchRedirectedUsecsae fetchRedirectedUsecsae;
  final FetchTodaysRedirectUsecase fetchTodaysRedirectUsecase;

  bool _hasMore = true;
  bool _isFetching = false;

  RedirectedOrdersBloc(
    this.fetchRedirectedUsecsae,
    this.fetchTodaysRedirectUsecase,
  ) : super(RedirectOrdersInitial()) {
    on<FetchRedirectedOrdersEvent>(_onFetchRedirectedOrders);
    on<FetchTodaysRedirectedOrdersEvent>(_onFetchTodaysRedirectedOrders);
  }

 
  Future<void> _onFetchRedirectedOrders(
    FetchRedirectedOrdersEvent event,
    Emitter<RedirectOrderState> emit,
  ) async {
    if (_isFetching) return;
    _isFetching = true;

    final isInitialLoad = event.page == 1;

    if (isInitialLoad) {
      _hasMore = true;
      emit(RedirectOrdersLoading());
    } else {
      if (!_hasMore) {
        _isFetching = false;
        return;
      }
      emit(RedirectOrdersPaginating());
    }

    final result = await fetchRedirectedUsecsae(
      FetchRedirectedParams(page: event.page),
    );

    result.fold(
      (failure) {
        if (isInitialLoad) {
          emit(RedirectOrdersError(message: failure.message));
        } else {
          emit(RedirectOrdersPaginatingError(message: failure.message));
        }
      },
      (data) {
        if (data.results.isEmpty && isInitialLoad) {
          emit(RedirectOrdersEmpty());
        } else if (isInitialLoad) {
          emit(RedirectOrdersLoaded(redirectedOrders: data));
        } else {
          emit(RedirectOrdersPaginated(redirectedOrders: data));
        }

        _hasMore = data.results.isNotEmpty;
      },
    );

    _isFetching = false;
  }

  
  Future<void> _onFetchTodaysRedirectedOrders(
    FetchTodaysRedirectedOrdersEvent event,
    Emitter<RedirectOrderState> emit,
  ) async {
    if (_isFetching) return;
    _isFetching = true;

    final isInitialLoad = event.page == 1;

    if (isInitialLoad) {
      _hasMore = true;
      emit(TodaysRedirectedOrderLoading());
    } else {
      if (!_hasMore) {
        _isFetching = false;
        return;
      }
      emit(TodaysRedirectedOrderPaginating());
    }

    final result = await fetchTodaysRedirectUsecase(
      FetchTodaysRedirectedParams(page: event.page),
    );

    result.fold(
      (failure) {
        if (isInitialLoad) {
          emit(TodaysRedirectedOrderError(message: failure.message));
        } else {
          emit(
            TodaysRedirectedOrderPaginatingError(
              message: failure.message,
            ),
          );
        }
      },
      (data) {
        if (data.results.isEmpty && isInitialLoad) {
          emit(TodaysRedirectedOrderEmpty());
        } else if (isInitialLoad) {
          emit(
            TodaysRedirectedOrderLoaded(redirectedOrders: data),
          );
        } else {
          emit(
            TodaysRedirectedOrderPaginated(redirectedOrders: data),
          );
        }

        _hasMore = data.results.isNotEmpty;
      },
    );

    _isFetching = false;
  }
}
