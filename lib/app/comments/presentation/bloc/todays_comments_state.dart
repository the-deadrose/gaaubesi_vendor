import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/app/comments/domain/entities/todays_comments_entity.dart';

abstract class TodaysCommentsState extends Equatable {
  const TodaysCommentsState();

  @override
  List<Object> get props => [];
}

class TodaysCommentsInitial extends TodaysCommentsState {
  const TodaysCommentsInitial();
}

class TodaysCommentsLoading extends TodaysCommentsState {
  const TodaysCommentsLoading();
}

class TodaysCommentsLoaded extends TodaysCommentsState {
  final TodaysCommentsEntity comments;
  final bool hasReachedMax;

  const TodaysCommentsLoaded({
    required this.comments,
    this.hasReachedMax = false,
  });

  TodaysCommentsLoaded copyWith({
    TodaysCommentsEntity? comments,
    bool? hasReachedMax,
  }) {
    return TodaysCommentsLoaded(
      comments: comments ?? this.comments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [comments, hasReachedMax];
}

class TodaysCommentsError extends TodaysCommentsState {
  final String message;

  const TodaysCommentsError(this.message);

  @override
  List<Object> get props => [message];
}

class TodaysCommentsLoadingMore extends TodaysCommentsState {
  final TodaysCommentsEntity comments;

  const TodaysCommentsLoadingMore(this.comments);

  @override
  List<Object> get props => [comments];
}