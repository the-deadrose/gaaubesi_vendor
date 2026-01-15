// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_returned_order_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedReturnedOrderResponseModel
_$PaginatedReturnedOrderResponseModelFromJson(Map<String, dynamic> json) =>
    PaginatedReturnedOrderResponseModel(
      count: (json['count'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results:
          (json['results'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ReturnedDeliveryModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );

Map<String, dynamic> _$PaginatedReturnedOrderResponseModelToJson(
  PaginatedReturnedOrderResponseModel instance,
) => <String, dynamic>{
  'next': instance.next,
  'previous': instance.previous,
  'count': instance.count,
  'total_pages': instance.totalPages,
  'results': instance.results.map((e) => e.toJson()).toList(),
};
