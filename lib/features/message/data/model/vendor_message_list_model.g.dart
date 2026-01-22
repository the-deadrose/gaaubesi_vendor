// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_message_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VendorMessageListModel _$VendorMessageListModelFromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(json, requiredKeys: const ['count', 'results']);
  return VendorMessageListModel(
    count: (json['count'] as num).toInt(),
    next: json['next'] as String?,
    previous: json['previous'] as String?,
    results: (json['results'] as List<dynamic>)
        .map((e) => VendorMessageModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$VendorMessageListModelToJson(
  VendorMessageListModel instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results.map((e) => e.toJson()).toList(),
};

VendorMessageModel _$VendorMessageModelFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'message',
      'created_on',
      'created_on_formatted',
      'created_by_name',
      'is_read',
    ],
  );
  return VendorMessageModel(
    id: (json['id'] as num).toInt(),
    message: json['message'] as String,
    createdOn: DateTime.parse(json['created_on'] as String),
    createdOnFormatted: json['created_on_formatted'] as String,
    createdByName: json['created_by_name'] as String,
    isRead: json['is_read'] as bool,
  );
}

Map<String, dynamic> _$VendorMessageModelToJson(VendorMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'created_on': instance.createdOn.toIso8601String(),
      'created_on_formatted': instance.createdOnFormatted,
      'created_by_name': instance.createdByName,
      'is_read': instance.isRead,
    };
