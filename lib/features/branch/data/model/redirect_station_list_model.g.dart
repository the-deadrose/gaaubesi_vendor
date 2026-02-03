// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redirect_station_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RedirectStationListModel _$RedirectStationListModelFromJson(
  Map<String, dynamic> json,
) => RedirectStationListModel(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results: (json['results'] as List<dynamic>)
      .map((e) => RedirectStationModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RedirectStationListModelToJson(
  RedirectStationListModel instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};

RedirectStationModel _$RedirectStationModelFromJson(
  Map<String, dynamic> json,
) => RedirectStationModel(
  id: (json['id'] as num).toInt(),
  homeBranch: BranchModel.fromJson(json['home_branch'] as Map<String, dynamic>),
  redirectBranches: (json['redirect_branches'] as List<dynamic>)
      .map((e) => BranchModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RedirectStationModelToJson(
  RedirectStationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'home_branch': instance.homeBranch,
  'redirect_branches': instance.redirectBranches,
};

BranchModel _$BranchModelFromJson(Map<String, dynamic> json) => BranchModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String,
  district: json['district'] as String,
  province: json['province'] as String,
);

Map<String, dynamic> _$BranchModelToJson(BranchModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'district': instance.district,
      'province': instance.province,
    };
