// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_available_permission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffAvailablePermissionModel _$StaffAvailablePermissionModelFromJson(
  Map<String, dynamic> json,
) => StaffAvailablePermissionModel(
  success: json['success'] as bool,
  message: json['message'] as String,
  permissionType: json['permission_type'] as String,
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => StaffPermissionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  assignedCount: (json['assigned_count'] as num).toInt(),
  totalCount: (json['total_count'] as num).toInt(),
);

Map<String, dynamic> _$StaffAvailablePermissionModelToJson(
  StaffAvailablePermissionModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'permission_type': instance.permissionType,
  'assigned_count': instance.assignedCount,
  'total_count': instance.totalCount,
  'permissions': instance.permissions.map((e) => e.toJson()).toList(),
};

StaffPermissionModel _$StaffPermissionModelFromJson(
  Map<String, dynamic> json,
) => StaffPermissionModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  codename: json['codename'] as String,
  isAssigned: json['is_assigned'] as bool,
);

Map<String, dynamic> _$StaffPermissionModelToJson(
  StaffPermissionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'codename': instance.codename,
  'is_assigned': instance.isAssigned,
};
