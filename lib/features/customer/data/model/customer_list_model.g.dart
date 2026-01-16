// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerListModel _$CustomerListModelFromJson(Map<String, dynamic> json) =>
    CustomerListModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      alternativePhoneNumber: json['alternative_phone_number'] as String?,
      email: json['email'] as String?,
      packageDeliveredCount: (json['package_delivered_count'] as num?)?.toInt(),
      createdOn: json['created_on'] == null
          ? null
          : DateTime.parse(json['created_on'] as String),
    );

Map<String, dynamic> _$CustomerListModelToJson(CustomerListModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone_number': instance.phoneNumber,
      'alternative_phone_number': instance.alternativePhoneNumber,
      'email': instance.email,
      'package_delivered_count': instance.packageDeliveredCount,
      'created_on': instance.createdOn?.toIso8601String(),
    };

CustomerListResponseModel _$CustomerListResponseModelFromJson(
  Map<String, dynamic> json,
) => CustomerListResponseModel(
  customers:
      (json['results'] as List<dynamic>?)
          ?.map((e) => CustomerListModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  totalCount: (json['count'] as num?)?.toInt() ?? 0,
  next: json['next'] as String?,
  previous: json['previous'] as String?,
);

Map<String, dynamic> _$CustomerListResponseModelToJson(
  CustomerListResponseModel instance,
) => <String, dynamic>{
  'results': instance.customers.map((e) => e.toJson()).toList(),
  'count': instance.totalCount,
  'next': instance.next,
  'previous': instance.previous,
};
