import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/resources/domain/entity/resources_list_entity.dart';
import 'package:gaaubesi_vendor/features/resources/domain/usecase/fetch_resources_usecase.dart';
import 'package:gaaubesi_vendor/features/resources/presentation/bloc/resources_list_event.dart';
import 'package:gaaubesi_vendor/features/resources/presentation/bloc/resources_list_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ResourcesListBloc extends Bloc<ResourcesListEvent, ResourcesListState> {
  final FetchResourcesUsecase _fetchResourcesUsecase;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _currentSearchQuery;
  List<ResourceItemEntity> _allItems = [];
  bool _isRefreshing = false;

  ResourcesListBloc({required FetchResourcesUsecase fetchResourcesUsecase})
    : _fetchResourcesUsecase = fetchResourcesUsecase,
      super(ResourcesListInitialState()) {
    on<FetchResourcesListEvent>(_onFetchResourcesList);
    on<RefreshResourcesListEvent>(_onRefreshResourcesList);
    on<LoadMoreResourcesEvent>(_onLoadMoreResources);
  }

  Future<void> _onFetchResourcesList(
    FetchResourcesListEvent event,
    Emitter<ResourcesListState> emit,
  ) async {
    try {
      _currentPage = 1;
      _hasMore = true;
      _currentSearchQuery = event.searchQuery;
      _allItems.clear();

      emit(ResourcesListLoadingState());

      final result = await _fetchResourcesUsecase(
        FetchResourcesParams(searchQuery: event.searchQuery, page: event.page),
      );

      _handleFetchResult(result, emit);
    } catch (e) {
      emit(ResourcesListErrorState(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onRefreshResourcesList(
    RefreshResourcesListEvent event,
    Emitter<ResourcesListState> emit,
  ) async {
    try {
      if (_isRefreshing) return;
      _isRefreshing = true;
      if (_allItems.isNotEmpty) {
        final currentList = ResourcesListEntity(
          count: _allItems.length,
          next: null,
          previous: null,
          results: _allItems,
        );
        emit(ResourcesListRefreshingState(resourcesListEntity: currentList));
      }

      _currentPage = 1;
      _hasMore = true;
      _currentSearchQuery = event.searchQuery;

      final result = await _fetchResourcesUsecase(
        FetchResourcesParams(searchQuery: event.searchQuery, page: '1'),
      );

      _allItems.clear();
      _handleFetchResult(result, emit);
    } catch (e) {
      if (_allItems.isNotEmpty) {
        emit(
          ResourcesListLoadedState(
            resourcesListEntity: ResourcesListEntity(
              count: _allItems.length,
              next: null,
              previous: null,
              results: _allItems,
            ),
          ),
        );
      } else {
        emit(ResourcesListErrorState(message: 'Failed to refresh'));
      }
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _onLoadMoreResources(
    LoadMoreResourcesEvent event,
    Emitter<ResourcesListState> emit,
  ) async {
    try {
      if (_isLoadingMore || !_hasMore || _allItems.isEmpty) return;

      _isLoadingMore = true;

      final currentList = ResourcesListEntity(
        count: _allItems.length,
        next: null,
        previous: null,
        results: _allItems,
      );
      emit(ResourcesListPaginatingState(resourcesListEntity: currentList));

      final nextPage = _currentPage + 1;
      final result = await _fetchResourcesUsecase(
        FetchResourcesParams(
          searchQuery: _currentSearchQuery,
          page: nextPage.toString(),
        ),
      );

      result.fold(
        (failure) {
          emit(
            ResourcesListPaginationErrorState(
              message: failure.message,
              resourcesListEntity: currentList,
            ),
          );
        },
        (resourcesList) {
          _hasMore = resourcesList.next != null;
          _currentPage = nextPage;
          _allItems.addAll(resourcesList.results);

          emit(
            ResourcesListPaginatedState(
              resourcesListEntity: ResourcesListEntity(
                count: resourcesList.count,
                next: resourcesList.next,
                previous: resourcesList.previous,
                results: _allItems,
              ),
            ),
          );
        },
      );
    } catch (e) {
      final currentList = ResourcesListEntity(
        count: _allItems.length,
        next: null,
        previous: null,
        results: _allItems,
      );
      emit(
        ResourcesListPaginationErrorState(
          message: 'Failed to load more',
          resourcesListEntity: currentList,
        ),
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  void _handleFetchResult(
    Either<Failure, ResourcesListEntity> result,
    Emitter<ResourcesListState> emit,
  ) {
    result.fold(
      (failure) {
        emit(ResourcesListErrorState(message: failure.message));
      },
      (resourcesList) {
        _allItems = List.from(resourcesList.results);
        _hasMore = resourcesList.next != null;

        if (_allItems.isEmpty) {
          emit(ResourcesListEmptyState());
        } else {
          emit(
            ResourcesListLoadedState(
              resourcesListEntity: ResourcesListEntity(
                count: resourcesList.count,
                next: resourcesList.next,
                previous: resourcesList.previous,
                results: _allItems,
              ),
            ),
          );
        }
      },
    );
  }

  bool get hasMore => _hasMore && !_isLoadingMore;
  bool get isLoadingMore => _isLoadingMore;
  bool get isRefreshing => _isRefreshing;
  List<ResourceItemEntity> get allItems => _allItems;

  void fetchFirstPage({String? searchQuery}) {
    add(FetchResourcesListEvent(page: '1', searchQuery: searchQuery));
  }

  void loadMore() {
    if (hasMore) {
      add(
        LoadMoreResourcesEvent(
          page: (_currentPage + 1).toString(),
          searchQuery: _currentSearchQuery,
        ),
      );
    }
  }

  void refreshList() {
    add(RefreshResourcesListEvent(page: '1', searchQuery: _currentSearchQuery));
  }

  void search(String query) {
    _currentSearchQuery = query.isNotEmpty ? query : null;
    fetchFirstPage(searchQuery: _currentSearchQuery);
  }
}
