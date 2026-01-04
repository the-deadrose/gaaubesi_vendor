// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_order_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedOrderResponseModel _$PaginatedOrderResponseModelFromJson(
  Map<String, dynamic> json,
) => PaginatedOrderResponseModel(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results: (json['results'] as List<dynamic>)
      .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PaginatedOrderResponseModelToJson(
  PaginatedOrderResponseModel instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};
