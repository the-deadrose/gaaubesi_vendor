// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  orderId: (json['order_id'] as num).toInt(),
  orderIdWithStatus: json['order_id_w_status'] as String,
  deliveredDate: json['delivered_date'] as String?,
  receiverName: json['receiver_name'] as String,
  receiverNumber: json['receiver_number'] as String,
  altReceiverNumber: json['alt_receiver_number'] as String?,
  receiverAddress: json['receiver_address'] as String,
  deliveryCharge: json['delivery_charge'] as String,
  codCharge: json['cod_charge'] as String,
  lastDeliveryStatus: json['last_delivery_status'] as String,
  source: json['source'] as String,
  destination: json['destination'] as String,
  description: json['desc'] as String,
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'source': instance.source,
      'destination': instance.destination,
      'order_id': instance.orderId,
      'order_id_w_status': instance.orderIdWithStatus,
      'delivered_date': instance.deliveredDate,
      'receiver_name': instance.receiverName,
      'receiver_number': instance.receiverNumber,
      'alt_receiver_number': instance.altReceiverNumber,
      'receiver_address': instance.receiverAddress,
      'delivery_charge': instance.deliveryCharge,
      'cod_charge': instance.codCharge,
      'last_delivery_status': instance.lastDeliveryStatus,
      'desc': instance.description,
    };
