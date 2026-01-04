// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_possible_redirect_order_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedPossibleRedirectOrderResponseModel
_$PaginatedPossibleRedirectOrderResponseModelFromJson(
  Map<String, dynamic> json,
) => PaginatedPossibleRedirectOrderResponseModel(
  totalPages: (json['total_pages'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results: (json['results'] as List<dynamic>)
      .map(
        (e) => PossibleRedirectOrderModel.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$PaginatedPossibleRedirectOrderResponseModelToJson(
  PaginatedPossibleRedirectOrderResponseModel instance,
) => <String, dynamic>{
  'next': instance.next,
  'previous': instance.previous,
  'total_pages': instance.totalPages,
  'results': instance.results,
};
