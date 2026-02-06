import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/staff/domain/entity/staff_available_permission_entity.dart';

class StaffOrderPermissionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StaffOrderPermissionInitial extends StaffOrderPermissionState {}

class StaffOrderPermissionLoading extends StaffOrderPermissionState {}

class StaffOrderPermissionLoaded extends StaffOrderPermissionState {
  final StaffAvailablePermissionEntity permissions;

  StaffOrderPermissionLoaded({required this.permissions});

  @override
  List<Object?> get props => [permissions];
}

class StaffOrderPermissionError extends StaffOrderPermissionState {
  final String message;

  StaffOrderPermissionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class StaffOrderPermissionEmpty extends StaffOrderPermissionState {}

class StaffOrderPermissionUpdating extends StaffOrderPermissionState {}

class StaffOrderPermissionUpdateSuccess extends StaffOrderPermissionState {
  final String message;

  StaffOrderPermissionUpdateSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class StaffOrderPermissionUpdateError extends StaffOrderPermissionState {
  final String message;

  StaffOrderPermissionUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}
