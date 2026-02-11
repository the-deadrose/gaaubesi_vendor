import 'package:equatable/equatable.dart';

abstract class ResourcesListEvent extends Equatable {
  const ResourcesListEvent();

  @override
  List<Object?> get props => [];
}

class FetchResourcesListEvent extends ResourcesListEvent {
  final String page;
  final String? searchQuery;

  const FetchResourcesListEvent({required this.page, this.searchQuery});

  @override
  List<Object?> get props => [page, searchQuery];
}

class RefreshResourcesListEvent extends ResourcesListEvent {
  final String page;
  final String? searchQuery;

  const RefreshResourcesListEvent({required this.page, this.searchQuery});

  @override
  List<Object?> get props => [page, searchQuery];
}


class LoadMoreResourcesEvent extends ResourcesListEvent {
  final String page;
  final String? searchQuery;

  const LoadMoreResourcesEvent({required this.page, this.searchQuery});

  @override
  List<Object?> get props => [page, searchQuery];
}