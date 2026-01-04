import 'package:equatable/equatable.dart';

abstract class TodaysCommentsEvent extends Equatable {
  const TodaysCommentsEvent();

  @override
  List<Object?> get props => [];
}

class FetchTodaysCommentsEvent extends TodaysCommentsEvent {
  final String page;

  const FetchTodaysCommentsEvent({required this.page});

  @override
  List<Object?> get props => [page];
}

class FetchMoreTodaysCommentsEvent extends TodaysCommentsEvent {
  const FetchMoreTodaysCommentsEvent();
}

class RefreshTodaysCommentsEvent extends TodaysCommentsEvent {
  const RefreshTodaysCommentsEvent();
}