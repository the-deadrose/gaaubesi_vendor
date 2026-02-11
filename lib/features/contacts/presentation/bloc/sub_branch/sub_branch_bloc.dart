import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/sub_branch_entity.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/usecase/fetch_subbraches_usecase.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/sub_branch/sub_branch_event.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/sub_branch/sub_branch_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton

class SubBranchBloc extends Bloc<SubBranchEvent, SubBranchState> {
  final FetchSubbrachesUsecase fetchSubbranchesUsecase;
  
  SubBranchesResponseEntity? _cachedResponse;
  bool _hasReachedEnd = false;
  String _currentSearchQuery = '';
  
  SubBranchBloc({required this.fetchSubbranchesUsecase}) 
      : super(SubBranchInitialState()) {
    on<FetchSubBranchesEvent>(_onFetchSubBranches);
    on<RefreshSubBranchesEvent>(_onRefreshSubBranches);
  }

  Future<void> _onFetchSubBranches(
    FetchSubBranchesEvent event,
    Emitter<SubBranchState> emit,
  ) async {
    if (event.searchQuery != _currentSearchQuery) {
      _resetCache();
      _currentSearchQuery = event.searchQuery ?? '';
    }

    if (_hasReachedEnd && event.page != '1') {
      return;
    }

    if (event.page == '1') {
      if (_cachedResponse != null && _cachedResponse!.results.isNotEmpty) {
        emit(SubBranchLoadedState(
          subBranchesResponseEntity: _cachedResponse!,
        ));
        return;
      }
      emit(SubBranchLoadingState());
    } else {
      emit(SubBranchPaginating());
    }

    final result = await fetchSubbranchesUsecase(
      FetchSubbrachesUsecaseParams(
        page: event.page,
        searchQuery: event.searchQuery,
      ),
    );

    result.fold(
      (failure) {
        if (event.page == '1') {
          emit(SubBranchErrorState(
            message: failure.message,
          ));
        } else {
          emit(SubBranchPaginatingError(
            message: failure.message,
          ));
          if (_cachedResponse != null) {
            emit(SubBranchLoadedState(
              subBranchesResponseEntity: _cachedResponse!,
            ));
          }
        }
      },
      (response) {
        _hasReachedEnd = response.next == null;

        if (event.page == '1') {
          _cachedResponse = response;
          emit(SubBranchLoadedState(
            subBranchesResponseEntity: response,
          ));
        } else {
          if (_cachedResponse != null) {
            final updatedResponse = SubBranchesResponseEntity(
              count: response.count,
              next: response.next,
              previous: response.previous,
              results: [..._cachedResponse!.results, ...response.results],
            );
            _cachedResponse = updatedResponse;
            emit(SubBranchPaginated(
              subBranchesResponseEntity: updatedResponse,
            ));
          } else {
            _cachedResponse = response;
            emit(SubBranchLoadedState(
              subBranchesResponseEntity: response,
            ));
          }
        }
        
        if (response.results.isEmpty && event.page == '1') {
          emit(SubBranchEmptyState());
        }
      },
    );
  }

  Future<void> _onRefreshSubBranches(
    RefreshSubBranchesEvent event,
    Emitter<SubBranchState> emit,
  ) async {
    _resetCache();
    
    add(FetchSubBranchesEvent(
      page: '1',
      searchQuery: event.searchQuery,
    ));
  }

  void _resetCache() {
    _cachedResponse = null;
    _hasReachedEnd = false;
  }

  // Getters for pagination state
  bool get hasMore => !_hasReachedEnd;
  
  bool get isLoadingMore => state is SubBranchPaginating;
  
  int get currentPage {
    if (_cachedResponse == null) return 0;
    final nextUrl = _cachedResponse!.next;
    if (nextUrl == null) return 1;
    
    final regex = RegExp(r'page=(\d+)');
    final match = regex.firstMatch(nextUrl);
    final nextPageNum = int.tryParse(match?.group(1) ?? '1') ?? 1;
    return nextPageNum - 1;
  }

  bool canLoadMore() {
    return !_hasReachedEnd && _cachedResponse?.next != null;
  }

  String? getNextPage() {
    if (_cachedResponse?.next == null) return null;
    
    final nextUrl = _cachedResponse!.next!;
    final regex = RegExp(r'page=(\d+)');
    final match = regex.firstMatch(nextUrl);
    
    return match?.group(1);
  }

  void loadNextPage() {
    if (canLoadMore()) {
      final nextPage = getNextPage();
      if (nextPage != null) {
        add(FetchSubBranchesEvent(
          page: nextPage,
          searchQuery: _currentSearchQuery,
        ));
      }
    }
  }
}