// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  token: json['key'] as String,
  name: json['name'] as String,
  warehousePermission: json['warehouse_permission'] as bool,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'name': instance.name,
  'key': instance.token,
  'warehouse_permission': instance.warehousePermission,
};
