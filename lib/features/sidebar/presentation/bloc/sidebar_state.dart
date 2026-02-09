import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/sidebar/domain/entity/sidebar_entity.dart';

class SidebarState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SidebarInitialState extends SidebarState {}

class SidebarLoadingState extends SidebarState {}

class SidebarLoadedState extends SidebarState {
  final List<SideBarEntity> items;

  SidebarLoadedState(this.items);

  @override
  List<Object?> get props => [items];
}

class SidebarErrorState extends SidebarState {
  final String message;

  SidebarErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class SidebarEmptyState extends SidebarState {}
