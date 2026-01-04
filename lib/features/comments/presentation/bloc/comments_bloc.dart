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
    emit(CommentsLoading(isTodays: event.isTodays));
    
    final result = event.isTodays
        ? await todaysCommentsUsecase(event.page)
        : await allCommentsUsecase(event.page);
    
    result.fold(
      (failure) {
        if (event.isTodays) {
          emit(TodaysCommentsError(message: _mapFailureToMessage(failure)));
        } else {
          emit(AllCommentsError(message: _mapFailureToMessage(failure)));
        }
      },
      (response) {
        if (event.isTodays) {
          emit(TodaysCommentsLoaded(
            response: response,
            hasReachedMax: response.next == null,
          ));
        } else {
          emit(AllCommentsLoaded(
            response: response,
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
    
    if (currentState is TodaysCommentsLoaded && event.isTodays) {
      if (currentState.hasReachedMax) return;
      
      emit(TodaysCommentsLoadingMore(
        response: currentState.response,
        hasReachedMax: currentState.hasReachedMax,
      ));
      
      final nextPage = _extractPageNumber(currentState.response.next ?? '');
      if (nextPage == null) {
        emit(TodaysCommentsError(message: 'Invalid next page URL'));
        return;
      }
      
      final result = await todaysCommentsUsecase(nextPage);
      result.fold(
        (failure) {
          emit(TodaysCommentsError(message: _mapFailureToMessage(failure)));
        },
        (response) {
          final updatedComments = List<CommentEntity>.from(currentState.response.results ?? [])
            ..addAll(response.results ?? []);
          
          emit(TodaysCommentsLoaded(
            response: CommentsResponseEntity(
              count: response.count,
              next: response.next,
              previous: response.previous,
              results: updatedComments,
              metadata: response.metadata,
            ),
            hasReachedMax: response.next == null,
          ));
        },
      );
    } else if (currentState is AllCommentsLoaded && !event.isTodays) {
      if (currentState.hasReachedMax) return;
      
      emit(AllCommentsLoadingMore(
        response: currentState.response,
        hasReachedMax: currentState.hasReachedMax,
      ));
      
      final nextPage = _extractPageNumber(currentState.response.next ?? '');
      if (nextPage == null) {
        emit(AllCommentsError(message: 'Invalid next page URL'));
        return;
      }
      
      final result = await allCommentsUsecase(nextPage);
      result.fold(
        (failure) {
          emit(AllCommentsError(message: _mapFailureToMessage(failure)));
        },
        (response) {
          final updatedComments = List<CommentEntity>.from(currentState.response.results ?? [])
            ..addAll(response.results ?? []);
          
          emit(AllCommentsLoaded(
            response: CommentsResponseEntity(
              count: response.count,
              next: response.next,
              previous: response.previous,
              results: updatedComments,
              metadata: response.metadata,
            ),
            hasReachedMax: response.next == null,
          ));
        },
      );
    }
  }

  Future<void> _onRefreshComments(
    RefreshCommentsEvent event,
    Emitter<CommentsState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is TodaysCommentsLoaded && event.isTodays) {
      emit(TodaysCommentsRefreshing(
        response: currentState.response,
        hasReachedMax: currentState.hasReachedMax,
      ));
      
      final result = await todaysCommentsUsecase('1');
      result.fold(
        (failure) {
          emit(TodaysCommentsError(message: _mapFailureToMessage(failure)));
        },
        (response) {
          emit(TodaysCommentsLoaded(
            response: response,
            hasReachedMax: response.next == null,
          ));
        },
      );
    } else if (currentState is AllCommentsLoaded && !event.isTodays) {
      emit(AllCommentsRefreshing(
        response: currentState.response,
        hasReachedMax: currentState.hasReachedMax,
      ));
      
      final result = await allCommentsUsecase('1');
      result.fold(
        (failure) {
          emit(AllCommentsError(message: _mapFailureToMessage(failure)));
        },
        (response) {
          emit(AllCommentsLoaded(
            response: response,
            hasReachedMax: response.next == null,
          ));
        },
      );
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