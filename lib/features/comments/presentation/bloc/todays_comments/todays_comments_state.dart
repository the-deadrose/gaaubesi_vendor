import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';

abstract class TodaysCommentsState extends Equatable {
  const TodaysCommentsState();

  @override
  List<Object?> get props => [];
}

class TodaysCommentsInitial extends TodaysCommentsState {}

class TodaysCommentsLoading extends TodaysCommentsState {}

class TodaysCommentsLoaded extends TodaysCommentsState {
  final CommentsResponseEntity response;
  final bool hasReachedMax;

  const TodaysCommentsLoaded({
    required this.response,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [response, hasReachedMax];
}

class TodaysCommentsError extends TodaysCommentsState {
  final String message;

  const TodaysCommentsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TodaysCommentsRefreshing extends TodaysCommentsLoaded {
  const TodaysCommentsRefreshing({
    required super.response,
    super.hasReachedMax,
  });
}

class TodaysCommentsLoadingMore extends TodaysCommentsLoaded {
  const TodaysCommentsLoadingMore({
    required super.response,
    super.hasReachedMax,
  });
}