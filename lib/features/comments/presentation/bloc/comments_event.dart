import 'package:equatable/equatable.dart';

abstract class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCommentsEvent extends CommentsEvent {
  final String page;
  final bool isTodays;
  final bool isRefresh;

  const FetchCommentsEvent({
    required this.page,
    this.isTodays = false,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, isTodays, isRefresh];
}

class FetchMoreCommentsEvent extends CommentsEvent {
  final bool isTodays;

  const FetchMoreCommentsEvent({this.isTodays = false});

  @override
  List<Object?> get props => [isTodays];
}

class RefreshCommentsEvent extends CommentsEvent {
  final bool isTodays;

  const RefreshCommentsEvent({this.isTodays = false});

  @override
  List<Object?> get props => [isTodays];
}

class FilterCommentsEvent extends CommentsEvent {
  final String page;
  final String? status;
  final String? startDate;
  final String? endDate;
  final String? searchId;

  const FilterCommentsEvent({
    required this.page,
    this.status,
    this.startDate,
    this.endDate,
    this.searchId,
  });

  @override
  List<Object?> get props => [page, status, startDate, endDate, searchId];
}

class ReplyToCommentEvent extends CommentsEvent {
  final String commentId;
  final String comment;

  const ReplyToCommentEvent({required this.commentId, required this.comment});

  @override
  List<Object?> get props => [commentId, comment];
}

class CreateCommentOrderdetailEvent extends CommentsEvent {
  final String commentId;
  final String comment;
  final String commentType;

  const CreateCommentOrderdetailEvent({
    required this.commentId,
    required this.comment,
    required this.commentType,
  });

  @override
  List<Object?> get props => [commentId, comment, commentType];
}

class ReplyCommentOrderDetailEvent extends CommentsEvent {
  final String commentId;
  final String comment;
  final String reply;
  final String commentType;

  const ReplyCommentOrderDetailEvent({
    required this.commentId,
    required this.comment,
    required this.reply,
    required this.commentType,
  });

  @override
  List<Object?> get props => [commentId, comment, reply, commentType];
}
