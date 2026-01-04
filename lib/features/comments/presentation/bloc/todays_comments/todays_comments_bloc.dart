import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';
import 'package:gaaubesi_vendor/features/comments/domain/usecase/todays_comments_usecase.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/todays_comments/todays_comments_event.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/todays_comments/todays_comments_state.dart';

@injectable
class TodaysCommentsBloc extends Bloc<TodaysCommentsEvent, TodaysCommentsState> {
  final TodaysCommentsUsecase _todaysCommentsUsecase;
  final List<CommentEntity> _allComments = [];
  bool _hasReachedMax = false;
  String? _nextPage;

  TodaysCommentsBloc({required TodaysCommentsUsecase todaysCommentsUsecase})
    : _todaysCommentsUsecase = todaysCommentsUsecase,
      super(TodaysCommentsInitial()) {
    on<FetchTodaysCommentsEvent>(_onFetchTodaysComments);
    on<FetchMoreTodaysCommentsEvent>(_onFetchMoreComments);
    on<RefreshTodaysCommentsEvent>(_onRefreshComments);
  }

  Future<void> _onFetchTodaysComments(
    FetchTodaysCommentsEvent event,
    Emitter<TodaysCommentsState> emit,
  ) async {
    if (event.page == '1') {
      _allComments.clear();
      _hasReachedMax = false;
      _nextPage = null;
      emit(TodaysCommentsLoading());
    }

    final result = await _todaysCommentsUsecase(event.page);
    result.fold(
      (failure) {
        emit(TodaysCommentsError(message: _mapFailureToMessage(failure)));
      },
      (response) {
        _nextPage = response.next;
        if (response.results != null) {
          _allComments.addAll(response.results!);
        }

        if (response.next == null) {
          _hasReachedMax = true;
        }

        emit(
          TodaysCommentsLoaded(
            response: CommentsResponseEntity(
              count: response.count,
              next: response.next,
              previous: response.previous,
              results: List.from(_allComments),
              metadata: response.metadata,
            ),
            hasReachedMax: _hasReachedMax,
          ),
        );
      },
    );
  }

  Future<void> _onFetchMoreComments(
    FetchMoreTodaysCommentsEvent event,
    Emitter<TodaysCommentsState> emit,
  ) async {
    if (_hasReachedMax || _nextPage == null) return;

    final currentState = state;
    if (currentState is TodaysCommentsLoaded) {
      emit(
        TodaysCommentsLoadingMore(
          response: currentState.response,
          hasReachedMax: currentState.hasReachedMax,
        ),
      );

      final nextPage = _extractPageNumber(_nextPage!);
      if (nextPage == null) {
        emit(TodaysCommentsError(message: 'Invalid next page URL'));
        return;
      }

      final result = await _todaysCommentsUsecase(nextPage);
      result.fold(
        (failure) {
          emit(TodaysCommentsError(message: _mapFailureToMessage(failure)));
        },
        (response) {
          _nextPage = response.next;
          if (response.results != null) {
            _allComments.addAll(response.results!);
          }

          if (response.next == null) {
            _hasReachedMax = true;
          }

          emit(
            TodaysCommentsLoaded(
              response: CommentsResponseEntity(
                count: response.count,
                next: response.next,
                previous: response.previous,
                results: List.from(_allComments),
                metadata: response.metadata,
              ),
              hasReachedMax: _hasReachedMax,
            ),
          );
        },
      );
    }
  }

  Future<void> _onRefreshComments(
    RefreshTodaysCommentsEvent event,
    Emitter<TodaysCommentsState> emit,
  ) async {
    final currentState = state;
    if (currentState is TodaysCommentsLoaded) {
      emit(
        TodaysCommentsRefreshing(
          response: currentState.response,
          hasReachedMax: currentState.hasReachedMax,
        ),
      );

      add(const FetchTodaysCommentsEvent(page: '1'));
    } else {
      add(const FetchTodaysCommentsEvent(page: '1'));
    }
  }

  String? _extractPageNumber(String url) {
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