// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_delivered_order_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedDeliveredOrderResponseModel
_$PaginatedDeliveredOrderResponseModelFromJson(Map<String, dynamic> json) =>
    PaginatedDeliveredOrderResponseModel(
      count: (json['count'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((e) => DeliveredOrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PaginatedDeliveredOrderResponseModelToJson(
  PaginatedDeliveredOrderResponseModel instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'total_pages': instance.totalPages,
  'results': instance.results,
};
