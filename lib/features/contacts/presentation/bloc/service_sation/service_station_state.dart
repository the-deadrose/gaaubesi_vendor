import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/service_station_entity.dart';

class ServiceStationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ServiceStationInitial extends ServiceStationState {}

class ServiceStationLoading extends ServiceStationState {}

class ServiceStationLoaded extends ServiceStationState {
  final ServiceStationListEntity serviceStationList;
  ServiceStationLoaded({required this.serviceStationList});
  @override
  List<Object?> get props => [serviceStationList];
}

class ServiceStationError extends ServiceStationState {
  final String message;
  ServiceStationError({required this.message});
  @override
  List<Object?> get props => [message];
}

class ServiceStationEmpty extends ServiceStationState {}

class ServiceStationPaginating extends ServiceStationState {}

class ServiceStationPaginated extends ServiceStationState {
  final ServiceStationListEntity serviceStationList;
  ServiceStationPaginated({required this.serviceStationList});
  @override
  List<Object?> get props => [serviceStationList];
}

class ServiceStationPaginateError extends ServiceStationState {
  final String message;
  ServiceStationPaginateError({required this.message});
  @override
  List<Object?> get props => [message];
}

class ServiceStationSearching extends ServiceStationState {}

class ServiceStationSearchEmpty extends ServiceStationState {}

class ServiceStationSearchError extends ServiceStationState {
  final String message;
  ServiceStationSearchError({required this.message});
  @override
  List<Object?> get props => [message];
}

class ServiceStationSearchLoaded extends ServiceStationState {
  final ServiceStationListEntity serviceStationList;
  ServiceStationSearchLoaded({required this.serviceStationList});
  @override
  List<Object?> get props => [serviceStationList];
}
