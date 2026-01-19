// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_stale_orders_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedStaleOrdersResponseModel _$PaginatedStaleOrdersResponseModelFromJson(
  Map<String, dynamic> json,
) => PaginatedStaleOrdersResponseModel(
  results: (json['results'] as List<dynamic>)
      .map((e) => StaleOrdersListModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  count: (json['count'] as num).toInt(),
  has_more: json['has_more'] as bool? ?? false,
);

Map<String, dynamic> _$PaginatedStaleOrdersResponseModelToJson(
  PaginatedStaleOrdersResponseModel instance,
) => <String, dynamic>{
  'results': instance.results,
  'count': instance.count,
  'has_more': instance.has_more,
};
