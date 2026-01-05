import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';
import 'package:gaaubesi_vendor/features/comments/domain/usecase/todays_comments_usecase.dart';
import 'package:gaaubesi_vendor/features/comments/domain/usecase/all_comments_usecase.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_event.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_state.dart';

@injectable
class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final TodaysCommentsUsecase todaysCommentsUsecase;
  final AllCommentsUsecase allCommentsUsecase;
  
  // Track pagination progress
  bool _isTodaysPaginationInProgress = false;
  bool _isAllPaginationInProgress = false;

  CommentsBloc({
    required this.todaysCommentsUsecase,
    required this.allCommentsUsecase,
  }) : super(CommentsInitial()) {
    on<FetchCommentsEvent>(_onFetchComments);
    on<FetchMoreCommentsEvent>(_onFetchMoreComments);
    on<RefreshCommentsEvent>(_onRefreshComments);
  }

  Future<void> _onFetchComments(
    FetchCommentsEvent event,
    Emitter<CommentsState> emit,
  ) async {
    // If this is a pagination request (page > 1), handle it differently
    if (int.tryParse(event.page) != null && int.parse(event.page) > 1) {
      await _handlePagination(event, emit);
      return;
    }

    // Initial load or refresh
    emit(CommentsLoading(isTodays: event.isTodays));

    final result = event.isTodays
        ? await todaysCommentsUsecase(event.page)
        : await allCommentsUsecase(event.page);

    result.fold(
      (failure) {
        if (event.isTodays) {
          emit(TodaysCommentsError(
            message: _mapFailureToMessage(failure),
          ));
        } else {
          emit(AllCommentsError(
            message: _mapFailureToMessage(failure),
          ));
        }
      },
      (response) {
        if (event.isTodays) {
          emit(TodaysCommentsLoaded(
            response: response,
            hasReachedMax: response.next == null,
            isRefreshing: event.isRefresh,
          ));
        } else {
          emit(AllCommentsLoaded(
            response: response,
            hasReachedMax: response.next == null,
            isRefreshing: event.isRefresh,
          ));
        }
      },
    );
  }

  Future<void> _handlePagination(
    FetchCommentsEvent event,
    Emitter<CommentsState> emit,
  ) async {
    final currentState = state;
    
    if (event.isTodays) {
      if (_isTodaysPaginationInProgress) return;
      _isTodaysPaginationInProgress = true;
      
      if (currentState is TodaysCommentsLoaded) {
        emit(currentState.copyWith(isLoadingMore: true));
      }
    } else {
      if (_isAllPaginationInProgress) return;
      _isAllPaginationInProgress = true;
      
      if (currentState is AllCommentsLoaded) {
        emit(currentState.copyWith(isLoadingMore: true));
      }
    }

    final result = event.isTodays
        ? await todaysCommentsUsecase(event.page)
        : await allCommentsUsecase(event.page);

    if (event.isTodays) {
      _isTodaysPaginationInProgress = false;
    } else {
      _isAllPaginationInProgress = false;
    }

    result.fold(
      (failure) {
        if (event.isTodays && currentState is TodaysCommentsLoaded) {
          emit(currentState.copyWith(isLoadingMore: false));
        } else if (!event.isTodays && currentState is AllCommentsLoaded) {
          emit(currentState.copyWith(isLoadingMore: false));
        }
      },
      (response) {
        if (event.isTodays && currentState is TodaysCommentsLoaded) {
          final currentComments = currentState.response.results ?? [];
          final newComments = response.results ?? [];
          final allComments = [...currentComments, ...newComments];
          
          emit(TodaysCommentsLoaded(
            response: CommentsResponseEntity(
              count: response.count,
              next: response.next,
              previous: response.previous,
              results: allComments,
              metadata: response.metadata,
            ),
            hasReachedMax: response.next == null,
          ));
        } else if (!event.isTodays && currentState is AllCommentsLoaded) {
          final currentComments = currentState.response.results ?? [];
          final newComments = response.results ?? [];
          final allComments = [...currentComments, ...newComments];
          
          emit(AllCommentsLoaded(
            response: CommentsResponseEntity(
              count: response.count,
              next: response.next,
              previous: response.previous,
              results: allComments,
              metadata: response.metadata,
            ),
            hasReachedMax: response.next == null,
          ));
        }
      },
    );
  }

  Future<void> _onFetchMoreComments(
    FetchMoreCommentsEvent event,
    Emitter<CommentsState> emit,
  ) async {
    final currentState = state;

    if (event.isTodays && currentState is TodaysCommentsLoaded) {
      if (currentState.hasReachedMax || currentState.isLoadingMore) {
        return;
      }

      final nextPage = _extractPageNumber(currentState.response.next ?? '');
      if (nextPage != null) {
        add(FetchCommentsEvent(
          page: nextPage,
          isTodays: true,
        ));
      }
    } else if (!event.isTodays && currentState is AllCommentsLoaded) {
      if (currentState.hasReachedMax || currentState.isLoadingMore) {
        return;
      }

      final nextPage = _extractPageNumber(currentState.response.next ?? '');
      if (nextPage != null) {
        add(FetchCommentsEvent(
          page: nextPage,
          isTodays: false,
        ));
      }
    }
  }

  Future<void> _onRefreshComments(
    RefreshCommentsEvent event,
    Emitter<CommentsState> emit,
  ) async {
    // Cancel any ongoing pagination
    _isTodaysPaginationInProgress = false;
    _isAllPaginationInProgress = false;
    
    add(FetchCommentsEvent(
      page: '1',
      isTodays: event.isTodays,
      isRefresh: true,
    ));
  }

  String? _extractPageNumber(String url) {
    if (url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      final page = uri.queryParameters['page'];
      return page ?? '1';
    } catch (e) {
      return null;
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server error occurred';
      case NetworkFailure _:
        return 'No internet connection';
      default:
        return 'An unexpected error occurred';
    }
  }
}