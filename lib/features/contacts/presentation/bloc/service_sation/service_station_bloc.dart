import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/service_station_entity.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/usecase/fetch_service_station_usecase.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/service_sation/service_station_event.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/service_sation/service_station_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ServiceStationBloc extends Bloc<ServiceSationEvent, ServiceStationState> {
  final FetchServiceStationUsecase fetchServiceStationUsecase;

  ServiceStationListEntity? _currentServiceStations;
  ServiceStationListEntity? _searchResults;
  bool _hasReachedMax = false;
  bool _searchHasReachedMax = false;
  String _nextPage = '1';
  String _searchNextPage = '1';
  bool _isFetching = false;
  bool _isSearching = false;
  String? _currentSearchQuery;

  ServiceStationListEntity? get currentServiceStations => _currentServiceStations;

  ServiceStationBloc({required this.fetchServiceStationUsecase})
    : super(ServiceStationInitial()) {
    on<FetchServiceStationEvent>(_onFetchServiceStations);
    on<RefreshServiceStationEvent>(_onRefreshServiceStations);
  }

  Future<void> _onFetchServiceStations(
    FetchServiceStationEvent event,
    Emitter<ServiceStationState> emit,
  ) async {
    if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
      await _handleSearch(event, emit);
      return;
    }

    if (_currentSearchQuery != null) {
      _clearSearchState();
    }

    await _handleNormalPagination(event, emit);
  }

  Future<void> _handleSearch(
    FetchServiceStationEvent event,
    Emitter<ServiceStationState> emit,
  ) async {
    final searchQuery = event.searchQuery!.trim();
    
    if (_currentSearchQuery != searchQuery) {
      _resetSearchState();
      _currentSearchQuery = searchQuery;
      
      if (event.page == '1') {
        emit(ServiceStationSearching());
      }
    }

    if (_isSearching || _searchHasReachedMax) return;

    if (event.page != '1') {
      emit(ServiceStationPaginating());
    }

    _isSearching = true;

    final result = await fetchServiceStationUsecase(
      FetchServiceStationParams(page: event.page, searchQuery: searchQuery),
    );

    result.fold(
      (failure) {
        _isSearching = false;
        if (event.page == '1') {
          emit(
            ServiceStationSearchError(message: 'Search failed: ${failure.message}'),
          );
        } else {
          emit(
            ServiceStationPaginateError(
              message: 'Failed to load more search results',
            ),
          );
          if (_searchResults != null) {
            emit(
              ServiceStationSearchLoaded(
                serviceStationList: _searchResults!,
              ),
            );
          }
        }
      },
      (newServiceStations) {
        _isSearching = false;

        if (newServiceStations.results.isEmpty) {
          _searchHasReachedMax = true;

          if (event.page == '1') {
            emit(ServiceStationSearchEmpty());
          } else if (_searchResults != null) {
            emit(
              ServiceStationSearchLoaded(
                serviceStationList: _searchResults!,
              ),
            );
          }
          return;
        }

        _searchNextPage = event.page == '1'
            ? '2'
            : (int.tryParse(event.page) ?? 1 + 1).toString();

        _searchHasReachedMax = newServiceStations.next == null;

        if (event.page == '1') {
          _searchResults = newServiceStations;
          emit(ServiceStationSearchLoaded(serviceStationList: newServiceStations));
        } else {
          final currentResults = _searchResults?.results ?? [];
          final updatedResults = [
            ...currentResults,
            ...newServiceStations.results,
          ];

          _searchResults = ServiceStationListEntity(
            count: newServiceStations.count,
            next: newServiceStations.next,
            previous: newServiceStations.previous,
            results: updatedResults,
          );

          emit(
            ServiceStationSearchLoaded(
              serviceStationList: _searchResults!,
            ),
          );
        }
      },
    );
  }

  Future<void> _handleNormalPagination(
    FetchServiceStationEvent event,
    Emitter<ServiceStationState> emit,
  ) async {
    if (_isFetching || _hasReachedMax) return;

    if (event.page == '1' && state is! ServiceStationLoaded) {
      emit(ServiceStationLoading());
    } else if (event.page != '1') {
      emit(ServiceStationPaginating());
    }

    _isFetching = true;

    final result = await fetchServiceStationUsecase(
      FetchServiceStationParams(page: event.page),
    );

    result.fold(
      (failure) {
        _isFetching = false;
        if (event.page == '1') {
          emit(
            ServiceStationError(message: 'Failed to fetch service stations'),
          );
        } else {
          emit(
            ServiceStationPaginateError(
              message: 'Failed to fetch more service stations',
            ),
          );
          if (_currentServiceStations != null) {
            emit(
              ServiceStationLoaded(
                serviceStationList: _currentServiceStations!,
              ),
            );
          }
        }
      },
      (newServiceStations) {
        _isFetching = false;

        if (newServiceStations.results.isEmpty) {
          _hasReachedMax = true;

          if (event.page == '1') {
            emit(ServiceStationEmpty());
          } else if (_currentServiceStations != null) {
            emit(
              ServiceStationLoaded(
                serviceStationList: _currentServiceStations!,
              ),
            );
          }
          return;
        }

        _nextPage = event.page == '1'
            ? '2'
            : (int.tryParse(event.page) ?? 1 + 1).toString();

        _hasReachedMax = newServiceStations.next == null;

        if (event.page == '1') {
          _currentServiceStations = newServiceStations;
          emit(ServiceStationLoaded(serviceStationList: newServiceStations));
        } else {
          final currentResults = _currentServiceStations?.results ?? [];
          final updatedResults = [
            ...currentResults,
            ...newServiceStations.results,
          ];

          _currentServiceStations = ServiceStationListEntity(
            count: newServiceStations.count,
            next: newServiceStations.next,
            previous: newServiceStations.previous,
            results: updatedResults,
          );

          emit(
            ServiceStationPaginated(
              serviceStationList: _currentServiceStations!,
            ),
          );
        }
      },
    );
  }

  Future<void> _onRefreshServiceStations(
    RefreshServiceStationEvent event,
    Emitter<ServiceStationState> emit,
  ) async {
    if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
      _resetSearchState();
      _currentSearchQuery = event.searchQuery;
      add(FetchServiceStationEvent(page: '1', searchQuery: event.searchQuery));
    } else {
      _clearSearchState();
      _resetNormalPaginationState();
      add(FetchServiceStationEvent(page: '1'));
    }
  }

  void loadNextPage() {
    if (_currentSearchQuery != null && _currentSearchQuery!.isNotEmpty) {
      if (!_isSearching && !_searchHasReachedMax && _searchNextPage.isNotEmpty) {
        add(FetchServiceStationEvent(page: _searchNextPage, searchQuery: _currentSearchQuery));
      }
    } else {
      if (!_isFetching && !_hasReachedMax && _nextPage.isNotEmpty) {
        add(FetchServiceStationEvent(page: _nextPage));
      }
    }
  }

  bool shouldLoadMore(int index, int itemCount) {
    if (_currentSearchQuery != null && _currentSearchQuery!.isNotEmpty) {
      return index >= itemCount - 5 && !_isSearching && !_searchHasReachedMax;
    }
    return index >= itemCount - 5 && !_isFetching && !_hasReachedMax;
  }

  void clearSearch() {
    _clearSearchState();
    if (_currentServiceStations != null) {
      // ignore: invalid_use_of_visible_for_testing_member
      emit(ServiceStationLoaded(serviceStationList: _currentServiceStations!));
    } else {
      add(FetchServiceStationEvent(page: '1'));
    }
  }

  void _resetSearchState() {
    _searchResults = null;
    _searchHasReachedMax = false;
    _searchNextPage = '1';
    _isSearching = false;
  }

  void _resetNormalPaginationState() {
    _currentServiceStations = null;
    _hasReachedMax = false;
    _nextPage = '1';
    _isFetching = false;
  }

  void _clearSearchState() {
    _currentSearchQuery = null;
    _resetSearchState();
  }
}