import 'package:equatable/equatable.dart';

abstract class RedirectOrdersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchRedirectedOrdersEvent extends RedirectOrdersEvent {
  final int page;

  FetchRedirectedOrdersEvent({required this.page});

  @override
  List<Object?> get props => [page];
}

class FetchTodaysRedirectedOrdersEvent extends RedirectOrdersEvent {
  final int page;

  FetchTodaysRedirectedOrdersEvent({required this.page});

  @override
  List<Object?> get props => [page];
}
