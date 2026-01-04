// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  refreshTokenField: json['refresh'] as String,
  accessTokenField: json['access'] as String,
  userIdField: json['user_id'] as String,
  roleField: json['role'] as String,
  fullNameField: json['full_name'] as String,
  departmentField: json['department'] as String,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'refresh': instance.refreshTokenField,
  'access': instance.accessTokenField,
  'user_id': instance.userIdField,
  'role': instance.roleField,
  'full_name': instance.fullNameField,
  'department': instance.departmentField,
};
