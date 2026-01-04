import 'package:equatable/equatable.dart';

abstract class TodaysCommentsEvent extends Equatable {
  const TodaysCommentsEvent();

  @override
  List<Object> get props => [];
}

class LoadTodaysComments extends TodaysCommentsEvent {
  final String page;

  const LoadTodaysComments({required this.page});

  @override
  List<Object> get props => [page];
}

class RefreshTodaysComments extends TodaysCommentsEvent {
  final String page;

  const RefreshTodaysComments({required this.page});

  @override
  List<Object> get props => [page];
}

class LoadMoreComments extends TodaysCommentsEvent {
  final String page;

  const LoadMoreComments({required this.page});

  @override
  List<Object> get props => [page];
}