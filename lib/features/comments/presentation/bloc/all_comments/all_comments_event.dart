import 'package:equatable/equatable.dart';

abstract class AllCommentsEvent extends Equatable {
  const AllCommentsEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllCommentsEvent extends AllCommentsEvent {
  final String page;

  const FetchAllCommentsEvent({required this.page});

  @override
  List<Object?> get props => [page];
}

class FetchMoreAllCommentsEvent extends AllCommentsEvent {
  const FetchMoreAllCommentsEvent();
}

class RefreshAllCommentsEvent extends AllCommentsEvent {
  const RefreshAllCommentsEvent();
}