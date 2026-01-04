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

class CommentsLoaded extends CommentsState {
  final CommentsResponseEntity response;
  final bool hasReachedMax;
  final bool isTodays;

  const CommentsLoaded({
    required this.response,
    this.hasReachedMax = false,
    this.isTodays = false,
  });

  @override
  List<Object?> get props => [response, hasReachedMax, isTodays];
}

class CommentsError extends CommentsState {
  final String message;
  final bool isTodays;

  const CommentsError({required this.message, this.isTodays = false});

  @override
  List<Object?> get props => [message, isTodays];
}

class CommentsRefreshing extends CommentsLoaded {
  const CommentsRefreshing({
    required super.response,
    super.hasReachedMax,
    super.isTodays,
  });

  @override
  List<Object?> get props => [...super.props, 'refreshing'];
}

class CommentsLoadingMore extends CommentsLoaded {
  const CommentsLoadingMore({
    required super.response,
    super.hasReachedMax,
    super.isTodays,
  });

  @override
  List<Object?> get props => [...super.props, 'loadingMore'];
}

// Today's specific states
class TodaysCommentsLoaded extends CommentsLoaded {
  const TodaysCommentsLoaded({
    required super.response,
    super.hasReachedMax,
  }) : super(isTodays: true);

  @override
  List<Object?> get props => [...super.props, 'todays'];
}

class TodaysCommentsError extends CommentsError {
  const TodaysCommentsError({required super.message}) : super(isTodays: true);

  @override
  List<Object?> get props => [...super.props, 'todays'];
}

class TodaysCommentsRefreshing extends CommentsRefreshing {
  const TodaysCommentsRefreshing({
    required super.response,
    super.hasReachedMax,
  }) : super(isTodays: true);

  @override
  List<Object?> get props => [...super.props, 'todays', 'refreshing'];
}

class TodaysCommentsLoadingMore extends CommentsLoadingMore {
  const TodaysCommentsLoadingMore({
    required super.response,
    super.hasReachedMax,
  }) : super(isTodays: true);

  @override
  List<Object?> get props => [...super.props, 'todays'];
}

// All time specific states
class AllCommentsLoaded extends CommentsLoaded {
  const AllCommentsLoaded({
    required super.response,
    super.hasReachedMax,
  }) : super(isTodays: false);

  @override
  List<Object?> get props => [...super.props, 'all'];
}

class AllCommentsError extends CommentsError {
  const AllCommentsError({required super.message}) : super(isTodays: false);

  @override
  List<Object?> get props => [...super.props, 'all'];
}

class AllCommentsRefreshing extends CommentsRefreshing {
  const AllCommentsRefreshing({
    required super.response,
    super.hasReachedMax,
  }) : super(isTodays: false);

  @override
  List<Object?> get props => [...super.props, 'all', 'refreshing'];
}

class AllCommentsLoadingMore extends CommentsLoadingMore {
  const AllCommentsLoadingMore({
    required super.response,
    super.hasReachedMax,
  }) : super(isTodays: false);

  @override
  List<Object?> get props => [...super.props, 'all'];
}