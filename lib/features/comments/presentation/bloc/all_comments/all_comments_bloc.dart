import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';
import 'package:gaaubesi_vendor/features/comments/domain/usecase/all_comments_usecase.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/all_comments/all_comments_event.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/all_comments/all_comments_state.dart';

@injectable
class AllCommentsBloc extends Bloc<AllCommentsEvent, AllCommentsState> {
  final AllCommentsUsecase _allCommentsUsecase;
  final List<CommentEntity> _allComments = [];
  bool _hasReachedMax = false;
  String? _nextPage;

  AllCommentsBloc({required AllCommentsUsecase allCommentsUsecase})
    : _allCommentsUsecase = allCommentsUsecase,
      super(AllCommentsInitial()) {
    on<FetchAllCommentsEvent>(_onFetchAllComments);
    on<FetchMoreAllCommentsEvent>(_onFetchMoreComments);
    on<RefreshAllCommentsEvent>(_onRefreshComments);
  }

  Future<void> _onFetchAllComments(
    FetchAllCommentsEvent event,
    Emitter<AllCommentsState> emit,
  ) async {
    if (event.page == '1') {
      _allComments.clear();
      _hasReachedMax = false;
      _nextPage = null;
      emit(AllCommentsLoading());
    }

    final result = await _allCommentsUsecase(event.page);
    result.fold(
      (failure) {
        emit(AllCommentsError(message: _mapFailureToMessage(failure)));
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
          AllCommentsLoaded(
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
    FetchMoreAllCommentsEvent event,
    Emitter<AllCommentsState> emit,
  ) async {
    if (_hasReachedMax || _nextPage == null) return;

    final currentState = state;
    if (currentState is AllCommentsLoaded) {
      emit(
        AllCommentsLoadingMore(
          response: currentState.response,
          hasReachedMax: currentState.hasReachedMax,
        ),
      );

      final nextPage = _extractPageNumber(_nextPage!);
      if (nextPage == null) {
        emit(AllCommentsError(message: 'Invalid next page URL'));
        return;
      }

      final result = await _allCommentsUsecase(nextPage);
      result.fold(
        (failure) {
          emit(AllCommentsError(message: _mapFailureToMessage(failure)));
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
            AllCommentsLoaded(
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
    RefreshAllCommentsEvent event,
    Emitter<AllCommentsState> emit,
  ) async {
    final currentState = state;
    if (currentState is AllCommentsLoaded) {
      emit(
        AllCommentsRefreshing(
          response: currentState.response,
          hasReachedMax: currentState.hasReachedMax,
        ),
      );

      add(const FetchAllCommentsEvent(page: '1'));
    } else {
      add(const FetchAllCommentsEvent(page: '1'));
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