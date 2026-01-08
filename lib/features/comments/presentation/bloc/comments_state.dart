import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {
  final bool isTodays;

  const CommentsLoading({this.isTodays = false});

  @override
  List<Object?> get props => [isTodays];
}

class TodaysCommentsLoaded extends CommentsState {
  final CommentsResponseEntity response;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final bool isRefreshing;

  const TodaysCommentsLoaded({
    required this.response,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  TodaysCommentsLoaded copyWith({
    CommentsResponseEntity? response,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return TodaysCommentsLoaded(
      response: response ?? this.response,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        response,
        hasReachedMax,
        isLoadingMore,
        isRefreshing,
      ];
}

class AllCommentsLoaded extends CommentsState {
  final CommentsResponseEntity response;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final bool isRefreshing;

  const AllCommentsLoaded({
    required this.response,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  AllCommentsLoaded copyWith({
    CommentsResponseEntity? response,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return AllCommentsLoaded(
      response: response ?? this.response,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        response,
        hasReachedMax,
        isLoadingMore,
        isRefreshing,
      ];
}

class TodaysCommentsError extends CommentsState {
  final String message;
  final CommentsResponseEntity? previousResponse;

  const TodaysCommentsError({
    required this.message,
    this.previousResponse,
  });

  @override
  List<Object?> get props => [message, previousResponse];
}

class AllCommentsError extends CommentsState {
  final String message;
  final CommentsResponseEntity? previousResponse;

  const AllCommentsError({
    required this.message,
    this.previousResponse,
  });

  @override
  List<Object?> get props => [message, previousResponse];
}

class FilteredCommentsLoaded extends CommentsState {
  final CommentsResponseEntity response;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? status;
  final String? startDate;
  final String? endDate;
  final String? searchId;

  const FilteredCommentsLoaded({
    required this.response,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.status,
    this.startDate,
    this.endDate,
    this.searchId,
  });

  FilteredCommentsLoaded copyWith({
    CommentsResponseEntity? response,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? status,
    String? startDate,
    String? endDate,
    String? searchId,
  }) {
    return FilteredCommentsLoaded(
      response: response ?? this.response,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchId: searchId ?? this.searchId,
    );
  }

  @override
  List<Object?> get props => [
        response,
        hasReachedMax,
        isLoadingMore,
        status,
        startDate,
        endDate,
        searchId,
      ];
}

class FilteredCommentsError extends CommentsState {
  final String message;
  final CommentsResponseEntity? previousResponse;

  const FilteredCommentsError({
    required this.message,
    this.previousResponse,
  });

  @override
  List<Object?> get props => [message, previousResponse];
}

class CommentReplySuccess extends CommentsState {
  final String commentId;

  const CommentReplySuccess({required this.commentId});

  @override
  List<Object?> get props => [commentId];
}

class CreateCommentOrderdetailLoading extends CommentsState {
  final String commentId;

  const CreateCommentOrderdetailLoading({required this.commentId});

  @override
  List<Object?> get props => [commentId];
}

class CreateCommentOrderdetailSuccess extends CommentsState {
  final String commentId;

  const CreateCommentOrderdetailSuccess({required this.commentId});

  @override
  List<Object?> get props => [commentId];
}

class CreateCommentOrderdetailError extends CommentsState {
  final String message;
  final String commentId;

  const CreateCommentOrderdetailError({
    required this.message,
    required this.commentId,
  });

  @override
  List<Object?> get props => [message, commentId];
}

class CommentReplyError extends CommentsState {
  final String message;
  final String commentId;

  const CommentReplyError({
    required this.message,
    required this.commentId,
  });

  @override
  List<Object?> get props => [message, commentId];
}

class CommentReplyLoading extends CommentsState {
  final String commentId;

  const CommentReplyLoading({required this.commentId});

  @override
  List<Object?> get props => [commentId];
}

class ReplyCommentOrderDetailLoading extends CommentsState {
  final String commentId;

  const ReplyCommentOrderDetailLoading({required this.commentId});

  @override
  List<Object?> get props => [commentId];
}

class ReplyCommentOrderDetailSuccess extends CommentsState {
  final String commentId;

  const ReplyCommentOrderDetailSuccess({required this.commentId});

  @override
  List<Object?> get props => [commentId];
}

class ReplyCommentOrderDetailError extends CommentsState {
  final String message;
  final String commentId;

  const ReplyCommentOrderDetailError({
    required this.message,
    required this.commentId,
  });

  @override
  List<Object?> get props => [message, commentId];
}

