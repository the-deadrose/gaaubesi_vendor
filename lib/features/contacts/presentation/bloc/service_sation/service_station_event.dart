import 'package:equatable/equatable.dart';

abstract class ServiceSationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchServiceStationEvent extends ServiceSationEvent {
  final String page;
  final String? searchQuery;

  FetchServiceStationEvent({required this.page , this.searchQuery});

  @override
  List<Object?> get props => [page, searchQuery];
}

class RefreshServiceStationEvent extends ServiceSationEvent {
  final String page;
  final String? searchQuery;

  RefreshServiceStationEvent({required this.page , this.searchQuery});

  @override
  List<Object?> get props => [page, searchQuery];
}
