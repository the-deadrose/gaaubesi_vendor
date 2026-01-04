import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/app/comments/domain/entities/todays_comments_entity.dart';
import 'package:gaaubesi_vendor/app/comments/domain/usecase/todays_comments_usecase.dart';
import 'package:gaaubesi_vendor/app/comments/presentation/bloc/todays_comments_event.dart';
import 'package:gaaubesi_vendor/app/comments/presentation/bloc/todays_comments_state.dart';

@injectable
class TodaysCommentsBloc extends Bloc<TodaysCommentsEvent, TodaysCommentsState> {
  final TodaysCommentsUseCase _todaysCommentsUseCase;

  TodaysCommentsBloc(this._todaysCommentsUseCase) : super(const TodaysCommentsInitial()) {
    on<LoadTodaysComments>(_onLoadTodaysComments);
    on<RefreshTodaysComments>(_onRefreshTodaysComments);
    on<LoadMoreComments>(_onLoadMoreComments);
  }

  Future<void> _onLoadTodaysComments(
    LoadTodaysComments event,
    Emitter<TodaysCommentsState> emit,
  ) async {
    emit(const TodaysCommentsLoading());
    final result = await _todaysCommentsUseCase(
      TodaysCommentsParams(page: event.page),
    );
    
    result.fold(
      (failure) => emit(TodaysCommentsError(failure.message)),
      (comments) => emit(TodaysCommentsLoaded(
        comments: comments,
        hasReachedMax: comments.next == null,
      )),
    );
  }

  Future<void> _onRefreshTodaysComments(
    RefreshTodaysComments event,
    Emitter<TodaysCommentsState> emit,
  ) async {
    final result = await _todaysCommentsUseCase(
      TodaysCommentsParams(page: event.page),
    );
    
    result.fold(
      (failure) => emit(TodaysCommentsError(failure.message)),
      (comments) => emit(TodaysCommentsLoaded(
        comments: comments,
        hasReachedMax: comments.next == null,
      )),
    );
  }

  Future<void> _onLoadMoreComments(
    LoadMoreComments event,
    Emitter<TodaysCommentsState> emit,
  ) async {
    if (state is TodaysCommentsLoaded) {
      final currentState = state as TodaysCommentsLoaded;
      
      // Check if we've already reached the max
      if (currentState.hasReachedMax) return;
      
      emit(TodaysCommentsLoadingMore(currentState.comments));
      
      final result = await _todaysCommentsUseCase(
        TodaysCommentsParams(page: event.page),
      );
      
      result.fold(
        (failure) => emit(TodaysCommentsError(failure.message)),
        (newComments) {
          // Combine existing comments with new ones
          final combinedComments = TodaysCommentsEntity(
            count: newComments.count,
            next: newComments.next,
            previous: newComments.previous,
            results: [...currentState.comments.results, ...newComments.results],
            metadata: newComments.metadata,
          );
          
          emit(TodaysCommentsLoaded(
            comments: combinedComments,
            hasReachedMax: newComments.next == null,
          ));
        },
      );
    }
  }
}