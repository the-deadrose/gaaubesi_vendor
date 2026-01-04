// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'returned_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReturnedOrderModel _$ReturnedOrderModelFromJson(Map<String, dynamic> json) =>
    ReturnedOrderModel(
      orderId: (json['order_id'] as num).toInt(),
      codCharge: json['cod_charge'] as String,
      destination: json['destination'] as String,
      receiver: json['receiver'] as String,
      deliveryCharge: json['delivery_charge'] as String,
      deliveredDate: json['delivered_date'] as String,
      receiverNumber: json['receiver_number'] as String,
    );

Map<String, dynamic> _$ReturnedOrderModelToJson(ReturnedOrderModel instance) =>
    <String, dynamic>{
      'destination': instance.destination,
      'receiver': instance.receiver,
      'order_id': instance.orderId,
      'cod_charge': instance.codCharge,
      'delivery_charge': instance.deliveryCharge,
      'delivered_date': instance.deliveredDate,
      'receiver_number': instance.receiverNumber,
    };
