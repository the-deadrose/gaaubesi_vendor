import 'package:json_annotation/json_annotation.dart';
import '../../domain/entity/staff_list_entity.dart';

part 'staff_list_model.g.dart';

@JsonSerializable(explicitToJson: true)
class StaffListModel extends StaffListEntity {
  @override
  final List<StaffModel> data;

  const StaffListModel({
    required super.success,
    required super.message,
    required this.data,
  }) : super(
    data: data,
  );

  factory StaffListModel.fromJson(Map<String, dynamic> json) =>
      _$StaffListModelFromJson(json);

  Map<String, dynamic> toJson() => _$StaffListModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StaffModel extends StaffEntity {
  const StaffModel({
    @JsonKey(name: 'id')
    required super.id,
    @JsonKey(name: 'full_name')
    required super.fullName,
    @JsonKey(name: 'username')
    required super.username,
    @JsonKey(name: 'email')
    required super.email,
    @JsonKey(name: 'phone_number')
    required super.phoneNumber,
    @JsonKey(name: 'role')
    required super.role,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) =>
      _$StaffModelFromJson(json);

  Map<String, dynamic> toJson() => _$StaffModelToJson(this);
}

@JsonSerializable()
class PermissionModel extends PermissionEntity {
  const PermissionModel({
    required super.id,
    required super.name,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) =>
      _$PermissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PermissionModelToJson(this);
}
