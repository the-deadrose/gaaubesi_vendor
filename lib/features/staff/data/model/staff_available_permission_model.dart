import 'package:json_annotation/json_annotation.dart';
import '../../domain/entity/staff_available_permission_entity.dart';

part 'staff_available_permission_model.g.dart';

@JsonSerializable(explicitToJson: true)
class StaffAvailablePermissionModel extends StaffAvailablePermissionEntity {
  @override
  final List<StaffPermissionModel> permissions;

  const StaffAvailablePermissionModel({
    required bool success,
    required String message,
    @JsonKey(name: 'permission_type') required String permissionType,
    required this.permissions,
    @JsonKey(name: 'assigned_count') required int assignedCount,
    @JsonKey(name: 'total_count') required int totalCount,
  }) : super(
         success: success,
         message: message,
         permissionType: permissionType,
         permissions: permissions,
         assignedCount: assignedCount,
         totalCount: totalCount,
       );

  factory StaffAvailablePermissionModel.fromJson(Map<String, dynamic> json) =>
      _$StaffAvailablePermissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$StaffAvailablePermissionModelToJson(this);
}

@JsonSerializable()
class StaffPermissionModel extends StaffPermissionEntity {
  const StaffPermissionModel({
    required int id,
    required String name,
    required String codename,
    @JsonKey(name: 'is_assigned') required bool isAssigned,
  }) : super(id: id, name: name, codename: codename, isAssigned: isAssigned);

  factory StaffPermissionModel.fromJson(Map<String, dynamic> json) =>
      _$StaffPermissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$StaffPermissionModelToJson(this);
}
