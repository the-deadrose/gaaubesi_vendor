// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivered_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveredOrderModel _$DeliveredOrderModelFromJson(Map<String, dynamic> json) =>
    DeliveredOrderModel(
      orderId: (json['order_id'] as num?)?.toInt() ?? 0,
      referenceId: json['reference_id'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      receiverName: json['receiver_name'] as String? ?? '',
      receiverNumber: json['receiver_number'] as String? ?? '',
      altReceiverNumber: json['alt_receiver_number'] as String? ?? '',
      codCharge: json['cod_charge'] as String? ?? '0.00',
      deliveryCharge: json['delivery_charge'] as String? ?? '0.00',
      deliveredDate: json['delivered_date'] == null
          ? null
          : DateTime.parse(json['delivered_date'] as String),
      deliveredDateFormatted: json['delivered_date_formatted'] as String? ?? '',
    );

Map<String, dynamic> _$DeliveredOrderModelToJson(
  DeliveredOrderModel instance,
) => <String, dynamic>{
  'order_id': instance.orderId,
  'reference_id': instance.referenceId,
  'destination': instance.destination,
  'receiver_name': instance.receiverName,
  'receiver_number': instance.receiverNumber,
  'alt_receiver_number': instance.altReceiverNumber,
  'cod_charge': instance.codCharge,
  'delivery_charge': instance.deliveryCharge,
  'delivered_date': ?instance.deliveredDate?.toIso8601String(),
  'delivered_date_formatted': instance.deliveredDateFormatted,
};
