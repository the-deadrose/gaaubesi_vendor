// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_branches_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubBranchesModel _$SubBranchesModelFromJson(Map<String, dynamic> json) =>
    SubBranchesModel(
      name: json['name'] as String?,
      district: json['district'] as String?,
      phoneNumbers:
          (json['phone_numbers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          {},
      baseCharge: (json['base_charge'] as num?)?.toDouble(),
      areaCovered: json['area_covered'] as String? ?? '',
      arrivalTime: json['arrival_time'] as String? ?? '',
    );

Map<String, dynamic> _$SubBranchesModelToJson(SubBranchesModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'district': instance.district,
      'phone_numbers': instance.phoneNumbers,
      'base_charge': instance.baseCharge,
      'area_covered': instance.areaCovered,
      'arrival_time': instance.arrivalTime,
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
