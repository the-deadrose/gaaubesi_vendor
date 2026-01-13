// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_rtv_order_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedRtvOrderResponseModel _$PaginatedRtvOrderResponseModelFromJson(
  Map<String, dynamic> json,
) => PaginatedRtvOrderResponseModel(
  count: (json['count'] as num?)?.toInt() ?? 0,
  totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results: (json['results'] as List<dynamic>)
      .map((e) => RtvOrderModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PaginatedRtvOrderResponseModelToJson(
  PaginatedRtvOrderResponseModel instance,
) => <String, dynamic>{
  'next': instance.next,
  'previous': instance.previous,
  'count': instance.count,
  'total_pages': instance.totalPages,
  'results': instance.results,
};
