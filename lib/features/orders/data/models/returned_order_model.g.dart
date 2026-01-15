// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'returned_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReturnedOrderModel _$ReturnedOrderModelFromJson(Map<String, dynamic> json) =>
    ReturnedOrderModel(
      orderId: json['order_id'] as String? ?? '',
      detailUrl: json['detail_url'] as String? ?? '',
      source: json['source'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      receiverAddress: json['receiver_address'] as String? ?? '',
      codCharge: json['cod_charge'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      customerNumber: json['customer_number'] as String? ?? '',
    );

Map<String, dynamic> _$ReturnedOrderModelToJson(ReturnedOrderModel instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'detail_url': instance.detailUrl,
      'source': instance.source,
      'destination': instance.destination,
      'receiver_address': instance.receiverAddress,
      'cod_charge': instance.codCharge,
      'customer_name': instance.customerName,
      'customer_number': instance.customerNumber,
    };
