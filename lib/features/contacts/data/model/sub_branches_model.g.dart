// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_branches_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubBranchesModel _$SubBranchesModelFromJson(Map<String, dynamic> json) =>
    SubBranchesModel(
      name: json['name'] as String?,
      district: json['district'] as String?,
      phoneNumbers: (json['phoneNumbers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      baseCharge: (json['baseCharge'] as num?)?.toDouble(),
      areaCovered: json['areaCovered'] as String?,
      arrivalTime: json['arrivalTime'] as String?,
    );

Map<String, dynamic> _$SubBranchesModelToJson(SubBranchesModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'district': instance.district,
      'phoneNumbers': instance.phoneNumbers,
      'baseCharge': instance.baseCharge,
      'areaCovered': instance.areaCovered,
      'arrivalTime': instance.arrivalTime,
    };

SubBranchesResponseModel _$SubBranchesResponseModelFromJson(
  Map<String, dynamic> json,
) => SubBranchesResponseModel(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results: (json['results'] as List<dynamic>?)
      ?.map((e) => SubBranchesModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SubBranchesResponseModelToJson(
  SubBranchesResponseModel instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};
