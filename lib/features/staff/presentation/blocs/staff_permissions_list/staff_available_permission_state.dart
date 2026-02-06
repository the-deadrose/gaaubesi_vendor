import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/staff/domain/entity/staff_available_permission_entity.dart';

class StaffAvailablePermissionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StaffAvailablePermissionInitial extends StaffAvailablePermissionState {}

class StaffAvailablePermissionLoading extends StaffAvailablePermissionState {}

class StaffAvailablePermissionLoaded extends StaffAvailablePermissionState {
  final StaffAvailablePermissionEntity permissions;
  final String permissionType;

  StaffAvailablePermissionLoaded({
    required this.permissions,
    required this.permissionType,
  });

  @override
  List<Object?> get props => [permissions, permissionType];
}

class StaffAvailablePermissionError extends StaffAvailablePermissionState {
  final String message;

  StaffAvailablePermissionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class StaffAvailablePermissionEmpty extends StaffAvailablePermissionState {}

class StaffPermissionUpdating extends StaffAvailablePermissionState {}

class StaffPermissionUpdateSuccess extends StaffAvailablePermissionState {
  final String message;

  StaffPermissionUpdateSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class StaffPermissionUpdateError extends StaffAvailablePermissionState {
  final String message;

  StaffPermissionUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}
