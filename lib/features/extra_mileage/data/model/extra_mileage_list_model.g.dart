// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extra_mileage_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExtraMileageResponseListModel _$ExtraMileageResponseListModelFromJson(
  Map<String, dynamic> json,
) => ExtraMileageResponseListModel(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results: (json['results'] as List<dynamic>)
      .map((e) => ExtraMileageResponseModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ExtraMileageResponseListModelToJson(
  ExtraMileageResponseListModel instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};

ExtraMileageResponseModel _$ExtraMileageResponseModelFromJson(
  Map<String, dynamic> json,
) => ExtraMileageResponseModel(
  pk: (json['pk'] as num).toInt(),
  order: json['order'] as String,
  destination: json['destination'] as String,
  location: json['location'] as String,
  extraKm: (json['extra_km'] as num).toInt(),
);

Map<String, dynamic> _$ExtraMileageResponseModelToJson(
  ExtraMileageResponseModel instance,
) => <String, dynamic>{
  'pk': instance.pk,
  'order': instance.order,
  'destination': instance.destination,
  'location': instance.location,
  'extra_km': instance.extraKm,
};
