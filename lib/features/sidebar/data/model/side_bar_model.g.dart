// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'side_bar_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SideBarModel _$SideBarModelFromJson(Map<String, dynamic> json) => SideBarModel(
  name: json['name'] as String,
  permission: json['permission'] as String?,
  hasAccess: json['has_access'] as bool,
  subItems: (json['sub_items'] as List<dynamic>?)
      ?.map((e) => SideBarModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SideBarModelToJson(SideBarModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'permission': instance.permission,
      'has_access': instance.hasAccess,
      'sub_items': instance.subItems?.map((e) => e.toJson()).toList(),
    };
