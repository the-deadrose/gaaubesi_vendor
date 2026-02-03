import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/redirect_station_list_entity.dart';
import 'package:gaaubesi_vendor/features/branch/domain/usecase/get_redirect_station_usecase.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/redirect_stations/redirect_station_list_event.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/redirect_stations/redirect_station_list_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RedirectStationListBloc
    extends Bloc<RedirectStationListEvent, RedirectStationListState> {
  final GetRedirectStationUsecase _getRedirectStationUsecase;

  final List<RedirectStationEntity> _allStations = [];
  String? _currentSearchQuery;
  String? _nextPageUrl;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  RedirectStationListBloc(this._getRedirectStationUsecase)
    : super(RedirectStationListInitial()) {
    on<FetchRedirectStationListEvent>(_onFetchRedirectStationList);
    on<RefreshRedirectStationListEvent>(_onRefreshRedirectStationList);
  }

  Future<void> _onFetchRedirectStationList(
    FetchRedirectStationListEvent event,
    Emitter<RedirectStationListState> emit,
  ) async {
    if (_currentSearchQuery != event.searchQuery) {
      _allStations.clear();
      _nextPageUrl = null;
      _hasMore = true;
      _isLoadingMore = false;
      _currentSearchQuery = event.searchQuery;
    }

    if (_isLoadingMore || !_hasMore) return;

    try {
      if (_allStations.isEmpty) {
        emit(RedirectStationListLoading());
      } else {
        _isLoadingMore = true;
        emit(RedirectStationListPaginating());
      }

      final String page;
      if (_nextPageUrl != null) {
        final uri = Uri.parse(_nextPageUrl!);
        page = uri.queryParameters['page'] ?? '1';
      } else {
        page = event.page;
      }

      final result = await _getRedirectStationUsecase.call(
        GetRedirectstationParams(page: page, searchQuery: event.searchQuery),
      );

      result.fold(
        (failure) {
          if (_allStations.isEmpty) {
            emit(RedirectStationListError(message: 'An error occurred'));
          } else {
            emit(
              RedirectStationListPaginateError(message: 'An error occurred'),
            );
            _isLoadingMore = false;
          }
        },
        (data) {
          _nextPageUrl = data.next;
          _hasMore = data.next != null;
          _isLoadingMore = false;

          _allStations.addAll(data.results);

          final updatedEntity = RedirectStationListEntity(
            count: data.count,
            next: data.next,
            previous: data.previous,
            results: List.from(_allStations),
          );

          if (_allStations.length == data.results.length) {
            if (_allStations.isEmpty) {
              emit(RedirectStationListEmpty());
            } else {
              emit(
                RedirectStationListLoaded(redirectStationList: updatedEntity),
              );
            }
          } else {
            emit(
              RedirectStationListPaginated(redirectStationList: updatedEntity),
            );
          }
        },
      );
    } catch (e) {
      if (_allStations.isEmpty) {
        emit(RedirectStationListError(message: 'An unexpected error occurred'));
      } else {
        emit(
          RedirectStationListPaginateError(
            message: 'An unexpected error occurred',
          ),
        );
        _isLoadingMore = false;
      }
    }
  }

  Future<void> _onRefreshRedirectStationList(
    RefreshRedirectStationListEvent event,
    Emitter<RedirectStationListState> emit,
  ) async {
    _allStations.clear();
    _nextPageUrl = null;
    _hasMore = true;
    _isLoadingMore = false;
    _currentSearchQuery = event.searchQuery;

    add(
      FetchRedirectStationListEvent(
        page: event.page,
        searchQuery: event.searchQuery,
      ),
    );
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  int get loadedCount => _allStations.length;
}
