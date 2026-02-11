import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/resources/domain/entity/resources_list_entity.dart';

class ResourcesListState extends Equatable {
  const ResourcesListState();

  @override
  List<Object?> get props => [];
}

class ResourcesListInitialState extends ResourcesListState {}

class ResourcesListLoadingState extends ResourcesListState {}

class ResourcesListLoadedState extends ResourcesListState {
  final ResourcesListEntity resourcesListEntity;

  const ResourcesListLoadedState({required this.resourcesListEntity});

  @override
  List<Object?> get props => [resourcesListEntity];
}

class ResourcesListErrorState extends ResourcesListState {
  final String message;

  const ResourcesListErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class ResourcesListPaginatingState extends ResourcesListState {
  final ResourcesListEntity resourcesListEntity;

  const ResourcesListPaginatingState({required this.resourcesListEntity});

  @override
  List<Object?> get props => [resourcesListEntity];
}

class ResourcesListPaginatedState extends ResourcesListState {
  final ResourcesListEntity resourcesListEntity;

  const ResourcesListPaginatedState({required this.resourcesListEntity});

  @override
  List<Object?> get props => [resourcesListEntity];
}

class ResourcesListPaginationErrorState extends ResourcesListState {
  final String message;
  final ResourcesListEntity resourcesListEntity;

  const ResourcesListPaginationErrorState({
    required this.message,
    required this.resourcesListEntity,
  });

  @override
  List<Object?> get props => [message, resourcesListEntity];
}

class ResourcesListEmptyState extends ResourcesListState {}

class ResourcesListRefreshingState extends ResourcesListState {
  final ResourcesListEntity resourcesListEntity;

  const ResourcesListRefreshingState({required this.resourcesListEntity});

  @override
  List<Object?> get props => [resourcesListEntity];
}