import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';
import 'package:gaaubesi_vendor/features/comments/domain/usecase/todays_comments_usecase.dart';
import 'package:gaaubesi_vendor/features/comments/domain/usecase/all_comments_usecase.dart';
import 'package:gaaubesi_vendor/features/comments/domain/usecase/filtered_comments_usecase.dart';
import 'package:gaaubesi_vendor/features/comments/domain/usecase/comment_reply_usecase.dart';
import 'package:gaaubesi_vendor/features/comments/domain/usecase/create_comment_orderdetail_usecase.dart';
import 'package:gaaubesi_vendor/features/comments/domain/usecase/reply_comment_order_detail_usecase.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_event.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_state.dart';

@injectable
class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final TodaysCommentsUsecase todaysCommentsUsecase;
  final AllCommentsUsecase allCommentsUsecase;
  final FilteredCommentsUsecase filteredCommentsUsecase;
  final CommentReplyUsecase commentReplyUsecase;
  final CreateCommentOrderdetailUsecase createCommentOrderdetailUsecase;
  final ReplyCommentOrderDetailUsecase replyCommentOrderDetailUsecase;
  
  // Track pagination progress
  bool _isTodaysPaginationInProgress = false;
  bool _isAllPaginationInProgress = false;
  bool _isFilterPaginationInProgress = false;

  CommentsBloc({
    required this.todaysCommentsUsecase,
    required this.allCommentsUsecase,
    required this.filteredCommentsUsecase,
    required this.commentReplyUsecase,
    required this.createCommentOrderdetailUsecase,
    required this.replyCommentOrderDetailUsecase,
  }) : super(CommentsInitial()) {
    on<FetchCommentsEvent>(_onFetchComments);
    on<FetchMoreCommentsEvent>(_onFetchMoreComments);
    on<RefreshCommentsEvent>(_onRefreshComments);
    on<FilterCommentsEvent>(_onFilterComments);
    on<ReplyToCommentEvent>(_onReplyToComment);
    on<CreateCommentOrderdetailEvent>(_onCreateCommentOrderdetail);
    on<ReplyCommentOrderDetailEvent>(_onReplyCommentOrderDetail);
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
        final serverFailure = failure as ServerFailure;
        return serverFailure.message.isNotEmpty
            ? serverFailure.message
            : 'Server error occurred';
      case NetworkFailure _:
        return 'No internet connection';
      default:
        return 'An unexpected error occurred';
    }
  }

  Future<void> _onFilterComments(
    FilterCommentsEvent event,
    Emitter<CommentsState> emit,
  ) async {
    // If this is a pagination request (page > 1), handle it differently
    if (int.tryParse(event.page) != null && int.parse(event.page) > 1) {
      await _handleFilterPagination(event, emit);
      return;
    }

    // Initial filter load
    emit(CommentsLoading());

    final result = await filteredCommentsUsecase(
      FilteredCommentsParams(
        page: event.page,
        status: event.status,
        startDate: event.startDate,
        endDate: event.endDate,
        searchId: event.searchId,
      ),
    );

    result.fold(
      (failure) {
        emit(AllCommentsError(
          message: _mapFailureToMessage(failure),
        ));
      },
      (response) {
        emit(FilteredCommentsLoaded(
          response: response,
          hasReachedMax: response.next == null,
          status: event.status,
          startDate: event.startDate,
          endDate: event.endDate,
          searchId: event.searchId,
        ));
      },
    );
  }

  Future<void> _handleFilterPagination(
    FilterCommentsEvent event,
    Emitter<CommentsState> emit,
  ) async {
    final currentState = state;

    if (_isFilterPaginationInProgress) return;
    _isFilterPaginationInProgress = true;

    if (currentState is FilteredCommentsLoaded) {
      emit(currentState.copyWith(isLoadingMore: true));
    }

    final result = await filteredCommentsUsecase(
      FilteredCommentsParams(
        page: event.page,
        status: event.status,
        startDate: event.startDate,
        endDate: event.endDate,
        searchId: event.searchId,
      ),
    );

    _isFilterPaginationInProgress = false;

    result.fold(
      (failure) {
        if (currentState is FilteredCommentsLoaded) {
          emit(currentState.copyWith(isLoadingMore: false));
        }
      },
      (response) {
        if (currentState is FilteredCommentsLoaded) {
          final currentComments = currentState.response.results ?? [];
          final newComments = response.results ?? [];
          final allComments = [...currentComments, ...newComments];

          emit(FilteredCommentsLoaded(
            response: CommentsResponseEntity(
              count: response.count,
              next: response.next,
              previous: response.previous,
              results: allComments,
              metadata: response.metadata,
            ),
            hasReachedMax: response.next == null,
            status: currentState.status,
            startDate: currentState.startDate,
            endDate: currentState.endDate,
            searchId: currentState.searchId,
          ));
        }
      },
    );
  }

  Future<void> _onReplyToComment(
    ReplyToCommentEvent event,
    Emitter<CommentsState> emit,
  ) async {
    emit(CommentReplyLoading(commentId: event.commentId));

    final result = await commentReplyUsecase(
      CommentReplyParams(
        commentId: event.commentId,
        comment: event.comment,
      ),
    );

    result.fold(
      (failure) {
        emit(CommentReplyError(
          message: _mapFailureToMessage(failure),
          commentId: event.commentId,
        ));
      },
      (_) {
        emit(CommentReplySuccess(commentId: event.commentId));
      },
    );
  }

  Future<void> _onCreateCommentOrderdetail(
    CreateCommentOrderdetailEvent event,
    Emitter<CommentsState> emit,
  ) async {
    emit(CreateCommentOrderdetailLoading(commentId: event.commentId));

    final result = await createCommentOrderdetailUsecase(
      CreateCommentOrderdetailParams(
        commentId: event.commentId,
        comment: event.comment,
        commentType: event.commentType,
      ),
    );

    result.fold(
      (failure) {
        emit(CreateCommentOrderdetailError(
          message: _mapFailureToMessage(failure),
          commentId: event.commentId,
        ));
      },
      (_) {
        emit(CreateCommentOrderdetailSuccess(commentId: event.commentId));
      },
    );
  }

  Future<void> _onReplyCommentOrderDetail(
    ReplyCommentOrderDetailEvent event,
    Emitter<CommentsState> emit,
  ) async {
    emit(ReplyCommentOrderDetailLoading(commentId: event.commentId));

    final result = await replyCommentOrderDetailUsecase(
      ReplyCommentOrderdetailParams(
        commentId: event.commentId,
        comment: event.comment,
        reply: event.reply,
        commentType: event.commentType,
      ),
    );

    result.fold(
      (failure) {
        emit(ReplyCommentOrderDetailError(
          message: _mapFailureToMessage(failure),
          commentId: event.commentId,
        ));
      },
      (_) {
        emit(ReplyCommentOrderDetailSuccess(commentId: event.commentId));
      },
    );
  }
}