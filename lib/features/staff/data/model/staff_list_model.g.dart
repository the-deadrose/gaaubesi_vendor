// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffListModel _$StaffListModelFromJson(Map<String, dynamic> json) =>
    StaffListModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => StaffModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StaffListModelToJson(StaffListModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

StaffModel _$StaffModelFromJson(Map<String, dynamic> json) => StaffModel(
  id: (json['id'] as num).toInt(),
  fullName: json['full_name'] as String,
  username: json['username'] as String,
  email: json['email'] as String,
  phoneNumber: json['phone_number'] as String,
  role: json['role'] as String,
);

Map<String, dynamic> _$StaffModelToJson(StaffModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'username': instance.username,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'role': instance.role,
    };

PermissionModel _$PermissionModelFromJson(Map<String, dynamic> json) =>
    PermissionModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$PermissionModelToJson(PermissionModel instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
