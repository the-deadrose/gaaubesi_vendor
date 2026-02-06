import 'package:equatable/equatable.dart';

abstract class StaffAvailablePermissionEvent extends Equatable {
  const StaffAvailablePermissionEvent();

  @override
  List<Object?> get props => [];
}

class FetchStaffAvailablePermissions extends StaffAvailablePermissionEvent {
  final String userId;
  final String permissionType;

  const FetchStaffAvailablePermissions({
    required this.userId,
    required this.permissionType,
  });

  @override
  List<Object?> get props => [userId, permissionType];
}

class RefreshStaffAvailablePermissions extends StaffAvailablePermissionEvent {
  final String userId;
  final String permissionType;

  const RefreshStaffAvailablePermissions({
    required this.userId,
    required this.permissionType,
  });

  @override
  List<Object?> get props => [userId, permissionType];
}

class UpdateStaffPermissions extends StaffAvailablePermissionEvent {
  final String userId;
  final String permissionType;
  final List<int> permissionIds;

  const UpdateStaffPermissions({
    required this.userId,
    required this.permissionType,
    required this.permissionIds,
  });

  @override
  List<Object?> get props => [userId, permissionType, permissionIds];
}
