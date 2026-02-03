import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/redirect_station_list_entity.dart';

class RedirectStationListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RedirectStationListInitial extends RedirectStationListState {}

class RedirectStationListLoading extends RedirectStationListState {}

class RedirectStationListLoaded extends RedirectStationListState {
  final RedirectStationListEntity redirectStationList;

  RedirectStationListLoaded({required this.redirectStationList});

  @override
  List<Object?> get props => [redirectStationList];
}

class RedirectStationListError extends RedirectStationListState {
  final String message;

  RedirectStationListError({required this.message});

  @override
  List<Object?> get props => [message];
}

class RedirectStationListEmpty extends RedirectStationListState {}

class RedirectStationListPaginating extends RedirectStationListState {}

class RedirectStationListPaginated extends RedirectStationListState {
  final RedirectStationListEntity redirectStationList;

  RedirectStationListPaginated({required this.redirectStationList});

  @override
  List<Object?> get props => [redirectStationList];
}

class RedirectStationListPaginateError extends RedirectStationListState {
  final String message;

  RedirectStationListPaginateError({required this.message});

  @override
  List<Object?> get props => [message];
}
