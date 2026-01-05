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