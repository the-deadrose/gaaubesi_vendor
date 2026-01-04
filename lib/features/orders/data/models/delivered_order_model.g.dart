// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivered_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveredOrderModel _$DeliveredOrderModelFromJson(Map<String, dynamic> json) =>
    DeliveredOrderModel(
      orderId: json['order_id'] as String,
      codCharge: json['cod_charge'] as String,
      destination: json['destination'] as String,
      receiverNumber: json['receiver_number'] as String,
      receiverName: json['receiver_name'] as String,
      deliveryCharge: json['delivery_charge'] as String,
      deliveredDate: json['delivered_date'] as String,
      createdOn: json['created_on'] as String,
    );

Map<String, dynamic> _$DeliveredOrderModelToJson(
  DeliveredOrderModel instance,
) => <String, dynamic>{
  'destination': instance.destination,
  'order_id': instance.orderId,
  'cod_charge': instance.codCharge,
  'receiver_number': instance.receiverNumber,
  'receiver_name': instance.receiverName,
  'delivery_charge': instance.deliveryCharge,
  'delivered_date': instance.deliveredDate,
  'created_on': instance.createdOn,
};
