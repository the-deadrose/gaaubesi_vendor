import 'package:equatable/equatable.dart';

abstract class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCommentsEvent extends CommentsEvent {
  final String page;
  final bool isTodays;

  const FetchCommentsEvent({
    required this.page,
    this.isTodays = false,
  });

  @override
  List<Object?> get props => [page, isTodays];
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