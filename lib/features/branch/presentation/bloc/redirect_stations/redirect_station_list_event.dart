import 'package:equatable/equatable.dart';

abstract class RedirectStationListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchRedirectStationListEvent extends RedirectStationListEvent {
  final String page;
  final String? searchQuery;

  FetchRedirectStationListEvent({required this.page, this.searchQuery});

  @override
  List<Object?> get props => [page, searchQuery];
}

class RefreshRedirectStationListEvent extends RedirectStationListEvent {
  final String page;
  final String? searchQuery;

  RefreshRedirectStationListEvent({required this.page, this.searchQuery});

  @override
  List<Object?> get props => [page, searchQuery];
}
