// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchListModel _$BranchListModelFromJson(Map<String, dynamic> json) =>
    BranchListModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );

Map<String, dynamic> _$BranchListModelToJson(BranchListModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
    };
