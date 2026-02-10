import 'package:equatable/equatable.dart';

abstract class SidebarEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchSidebarDataEvent extends SidebarEvent {
  @override
  List<Object> get props => [];
}

class LoadCachedSidebarDataEvent extends SidebarEvent {
  @override
  List<Object> get props => [];
}

class ClearSidebarCacheEvent extends SidebarEvent {
  @override
  List<Object> get props => [];
}
