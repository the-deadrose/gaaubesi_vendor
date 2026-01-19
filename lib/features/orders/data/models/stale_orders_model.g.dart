// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stale_orders_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaleOrdersListModel _$StaleOrdersListModelFromJson(
  Map<String, dynamic> json,
) => StaleOrdersListModel(
  order_id: (json['order_id'] as num).toInt(),
  order_id_with_status: json['order_id_with_status'] as String,
  created_on: json['created_on'] as String?,
  created_on_formatted: json['created_on_formatted'] as String?,
  receiver_name: json['receiver_name'] as String?,
  receiver_phone: json['receiver_phone'] as String?,
  receiver_alt_phone: json['receiver_alt_phone'] as String?,
  receiver_address: json['receiver_address'] as String?,
  source_branch: json['source_branch'] as String?,
  destination_branch: json['destination_branch'] as String?,
  cod_charge: json['cod_charge'] as String?,
  last_delivery_status: json['last_delivery_status'] as String?,
  order_description: json['order_description'] as String?,
  hold: json['hold'] as bool?,
  vendor_return: json['vendor_return'] as bool?,
  is_exchange_order: json['is_exchange_order'] as bool?,
  is_refund_order: json['is_refund_order'] as bool?,
);

Map<String, dynamic> _$StaleOrdersListModelToJson(
  StaleOrdersListModel instance,
) => <String, dynamic>{
  'order_id': instance.order_id,
  'order_id_with_status': instance.order_id_with_status,
  'created_on': instance.created_on,
  'created_on_formatted': instance.created_on_formatted,
  'receiver_name': instance.receiver_name,
  'receiver_phone': instance.receiver_phone,
  'receiver_alt_phone': instance.receiver_alt_phone,
  'receiver_address': instance.receiver_address,
  'source_branch': instance.source_branch,
  'destination_branch': instance.destination_branch,
  'cod_charge': instance.cod_charge,
  'last_delivery_status': instance.last_delivery_status,
  'order_description': instance.order_description,
  'hold': instance.hold,
  'vendor_return': instance.vendor_return,
  'is_exchange_order': instance.is_exchange_order,
  'is_refund_order': instance.is_refund_order,
};
