import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';

abstract class AllCommentsState extends Equatable {
  const AllCommentsState();

  @override
  List<Object?> get props => [];
}

class AllCommentsInitial extends AllCommentsState {}

class AllCommentsLoading extends AllCommentsState {}

class AllCommentsLoaded extends AllCommentsState {
  final CommentsResponseEntity response;
  final bool hasReachedMax;

  const AllCommentsLoaded({
    required this.response,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [response, hasReachedMax];
}

class AllCommentsError extends AllCommentsState {
  final String message;

  const AllCommentsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AllCommentsRefreshing extends AllCommentsLoaded {
  const AllCommentsRefreshing({
    required super.response,
    super.hasReachedMax,
  });
}

class AllCommentsLoadingMore extends AllCommentsLoaded {
  const AllCommentsLoadingMore({
    required super.response,
    super.hasReachedMax,
  });
}