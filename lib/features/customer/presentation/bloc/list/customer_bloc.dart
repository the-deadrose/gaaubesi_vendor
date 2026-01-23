import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/customer/domain/usecase/customer_list_usecase.dart';
import 'package:gaaubesi_vendor/features/customer/presentation/bloc/list/customer_event.dart';
import 'package:gaaubesi_vendor/features/customer/presentation/bloc/list/customer_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class CustomerListBloc extends Bloc<CustomerListEvent, CustomerListState> {
  final CustomerListUseCase _customerListUseCase;

  Timer? _searchDebounceTimer;
  String _currentSearchQuery = '';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isSearching = false;

  CustomerListBloc(this._customerListUseCase)
    : super(CustomerListInitial()) {
    on<FetchCustomerList>(_onFetchCustomerList);
    on<LoadMoreCustomerList>(_onLoadMoreCustomerList);
    on<RefreshCustomerList>(_onRefreshCustomerList);
    on<SearchCustomerList>(_onSearchCustomerList);
    on<CustomerListScreenPagination>(_onCustomerListScreenPagination);
    on<ResetCustomerListState>(_onResetCustomerListState);
  }

  Future<void> _onFetchCustomerList(
    FetchCustomerList event,
    Emitter<CustomerListState> emit,
  ) async {
    try {
      if (event.isRefresh) {
        _currentPage = 1;
        _isSearching = false;
        _currentSearchQuery = '';
      }

      if (event.page == 1 || event.isRefresh) {
        emit(CustomerListLoading());
      }

      final result = await _customerListUseCase.call(
        CustomerUsecaseParams(
          page: event.page.toString(),
          searchQuery: _isSearching ? _currentSearchQuery : null,
        ),
      );

      result.fold(
        (failure) {
          emit(CustomerListError(failure.toString()));
        },
        (customerListResponse) {
          final customers = customerListResponse.customers;
          _totalPages = customerListResponse.totalPages;
          _currentPage = customerListResponse.currentPage;

          final hasReachedMax = _currentPage >= _totalPages;

          emit(
            CustomerListLoaded(
              customers: customers,
              currentPage: _currentPage,
              totalPages: _totalPages,
              hasReachedMax: hasReachedMax,
              isSearchResult: _isSearching,
            ),
          );
        },
      );
    } catch (e) {
      emit(CustomerListError('Failed to fetch customers: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMoreCustomerList(
    LoadMoreCustomerList event,
    Emitter<CustomerListState> emit,
  ) async {
    final currentState = state;

    if (currentState is CustomerListLoaded) {
      if (currentState.hasReachedMax) return;

      try {
        final nextPage = currentState.currentPage + 1;

        final result = await _customerListUseCase.call(
          CustomerUsecaseParams(
            page: nextPage.toString(),
            searchQuery: _isSearching ? _currentSearchQuery : null,
          ),
        );

        result.fold(
          (failure) {
            emit(CustomerListError(failure.toString()));
          },
          (customerListResponse) {
            final newCustomers = customerListResponse.customers;
            _totalPages = customerListResponse.totalPages;
            _currentPage = customerListResponse.currentPage;

            if (newCustomers.isEmpty) {
              emit(currentState.copyWith(hasReachedMax: true));
              return;
            }

            final allCustomers = [...currentState.customers, ...newCustomers];
            final hasReachedMax = _currentPage >= _totalPages;

            emit(
              currentState.copyWith(
                customers: allCustomers,
                currentPage: _currentPage,
                totalPages: _totalPages,
                hasReachedMax: hasReachedMax,
              ),
            );
          },
        );
      } catch (e) {
        emit(
          CustomerListError('Failed to load more customers: ${e.toString()}'),
        );
      }
    }
  }

  Future<void> _onRefreshCustomerList(
    RefreshCustomerList event,
    Emitter<CustomerListState> emit,
  ) async {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = null;
    _isSearching = false;
    _currentSearchQuery = '';

    add(const FetchCustomerList(page: 1, isRefresh: true));
  }

  void _onSearchCustomerList(
    SearchCustomerList event,
    Emitter<CustomerListState> emit,
  ) {
    _searchDebounceTimer?.cancel();

    if (event.query.trim().isEmpty) {
      _isSearching = false;
      _currentSearchQuery = '';
      _currentPage = 1;
      add(const FetchCustomerList(page: 1, isRefresh: true));
      return;
    }

    _isSearching = true;
    _currentSearchQuery = event.query.trim();
    _currentPage = 1;

    emit(CustomerListSearching());

    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      add(const FetchCustomerList(page: 1, isRefresh: true));
    });
  }

  Future<void> _onCustomerListScreenPagination(
    CustomerListScreenPagination event,
    Emitter<CustomerListState> emit,
  ) async {
    final currentState = state;

    if (currentState is CustomerListLoaded &&
        event.page != currentState.currentPage) {
      try {
        emit(CustomerListPaginating());

        final result = await _customerListUseCase.call(
          CustomerUsecaseParams(
            page: event.page.toString(),
            searchQuery: _isSearching ? _currentSearchQuery : null,
          ),
        );

        result.fold(
          (failure) {
            emit(CustomerListPaginationError(failure.toString()));
          },
          (customerListResponse) {
            final customers = customerListResponse.customers;
            _totalPages = customerListResponse.totalPages;
            _currentPage = customerListResponse.currentPage;

            final hasReachedMax = _currentPage >= _totalPages;

            emit(
              CustomerListLoaded(
                customers: customers,
                currentPage: _currentPage,
                totalPages: _totalPages,
                hasReachedMax: hasReachedMax,
                isSearchResult: _isSearching,
              ),
            );
          },
        );
      } catch (e) {
        emit(
          CustomerListPaginationError('Failed to paginate: ${e.toString()}'),
        );
      }
    }
  }

  void _onResetCustomerListState(
    ResetCustomerListState event,
    Emitter<CustomerListState> emit,
  ) {
    emit(CustomerListInitial());
  }

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    return super.close();
  }
}