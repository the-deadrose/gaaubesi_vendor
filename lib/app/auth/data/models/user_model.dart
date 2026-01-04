import 'package:gaaubesi_vendor/app/auth/domain/entities/user_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required String token,
    required super.name,
    required bool warehousePermission,
  }) : super(token: token, warehousePermission: warehousePermission);

  @override
  @JsonKey(name: 'key')
  String get token => super.token;

  @override
  @JsonKey(name: 'warehouse_permission')
  bool get warehousePermission => super.warehousePermission;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
