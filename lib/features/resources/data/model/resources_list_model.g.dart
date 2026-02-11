// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resources_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResourcesListModel _$ResourcesListModelFromJson(Map<String, dynamic> json) =>
    ResourcesListModel(
      count: (json['count'] as num?)?.toInt() ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results:
          (json['results'] as List<dynamic>?)
              ?.map(
                (e) => ResourceItemModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );

Map<String, dynamic> _$ResourcesListModelToJson(ResourcesListModel instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results.map((e) => e.toJson()).toList(),
    };

ResourceItemModel _$ResourceItemModelFromJson(Map<String, dynamic> json) =>
    ResourceItemModel(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      view: json['view'] as String? ?? '',
    );

Map<String, dynamic> _$ResourceItemModelToJson(ResourceItemModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'view': instance.view,
    };
