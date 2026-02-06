import 'package:equatable/equatable.dart';

class StaffAvailablePermissionEntity extends Equatable {
  final bool success;
  final String message;
  final String permissionType;
  final List<StaffPermissionEntity> permissions;
  final int assignedCount;
  final int totalCount;

  const StaffAvailablePermissionEntity({
    required this.success,
    required this.message,
    required this.permissionType,
    required this.permissions,
    required this.assignedCount,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [
        success,
        message,
        permissionType,
        permissions,
        assignedCount,
        totalCount,
      ];
}

class StaffPermissionEntity extends Equatable {
  final int id;
  final String name;
  final String codename;
  final bool isAssigned;

  const StaffPermissionEntity({
    required this.id,
    required this.name,
    required this.codename,
    required this.isAssigned,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        codename,
        isAssigned,
      ];
}
