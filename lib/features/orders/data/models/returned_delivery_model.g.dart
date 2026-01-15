// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'returned_delivery_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReturnedDeliveryModel _$ReturnedDeliveryModelFromJson(
  Map<String, dynamic> json,
) => ReturnedDeliveryModel(
  deliveryId: json['delivery_id'] as String? ?? '',
  dateSent: json['date_sent'] as String? ?? '',
  dateSentFormatted: json['date_sent_formatted'] as String? ?? '',
  ordersList:
      (json['orders_list'] as List<dynamic>?)
          ?.map((e) => ReturnedOrderModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  ordersCount: (json['orders_count'] as num?)?.toInt() ?? 0,
  printUrl: json['print_url'] as String? ?? '',
);

Map<String, dynamic> _$ReturnedDeliveryModelToJson(
  ReturnedDeliveryModel instance,
) => <String, dynamic>{
  'delivery_id': instance.deliveryId,
  'date_sent': instance.dateSent,
  'date_sent_formatted': instance.dateSentFormatted,
  'orders_list': instance.ordersList.map((e) => e.toJson()).toList(),
  'orders_count': instance.ordersCount,
  'print_url': instance.printUrl,
};
