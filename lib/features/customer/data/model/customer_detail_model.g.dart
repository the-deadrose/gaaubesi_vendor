// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerDetailModel _$CustomerDetailModelFromJson(Map<String, dynamic> json) =>
    CustomerDetailModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      orders:
          (json['orders'] as List<dynamic>?)
              ?.map(
                (e) => CustomerOrderModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );

Map<String, dynamic> _$CustomerDetailModelToJson(
  CustomerDetailModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'phone_number': instance.phoneNumber,
  'email': instance.email,
  'address': instance.address,
  'orders': instance.orders.map((e) => e.toJson()).toList(),
};

CustomerOrderModel _$CustomerOrderModelFromJson(Map<String, dynamic> json) =>
    CustomerOrderModel(
      orderId: (json['order_id'] as num?)?.toInt() ?? 0,
      lastDeliveryStatus: json['last_delivery_status'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      createdOn: json['created_on'] as String? ?? '',
    );

Map<String, dynamic> _$CustomerOrderModelToJson(CustomerOrderModel instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'last_delivery_status': instance.lastDeliveryStatus,
      'branch': instance.branch,
      'destination': instance.destination,
      'created_on': instance.createdOn,
    };
