import 'package:gaaubesi_vendor/features/auth/domain/entities/user_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  @JsonKey(name: 'refresh')
  final String refreshTokenField;

  @JsonKey(name: 'access')
  final String accessTokenField;

  @JsonKey(name: 'user_id')
  final String userIdField;

  @JsonKey(name: 'role')
  final String roleField;

  @JsonKey(name: 'full_name')
  final String fullNameField;

  @JsonKey(name: 'department')
  final String departmentField;

  const UserModel({
    required this.refreshTokenField,
    required this.accessTokenField,
    required this.userIdField,
    required this.roleField,
    required this.fullNameField,
    required this.departmentField,
  }) : super(
          refreshToken: refreshTokenField,
          accessToken: accessTokenField,
          userId: userIdField,
          role: roleField,
          fullName: fullNameField,
          department: departmentField,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  UserModel copyWith({
    String? refreshToken,
    String? accessToken,
    String? userId,
    String? role,
    String? fullName,
    String? department,
  }) {
    return UserModel(
      refreshTokenField: refreshToken ?? refreshTokenField,
      accessTokenField: accessToken ?? accessTokenField,
      userIdField: userId ?? userIdField,
      roleField: role ?? roleField,
      fullNameField: fullName ?? fullNameField,
      departmentField: department ?? departmentField,
    );
  }
}