// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_transections_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyTransectionsModel _$DailyTransectionsModelFromJson(
  Map<String, dynamic> json,
) => DailyTransectionsModel(
  date: _stringFromJson(json['date']),
  deliveredOrders: _dailyOrderListFromJson(json['delivered_orders']),
  returnedOrders: _dailyOrderListFromJson(json['returned_orders']),
  codTransferTotal: _stringFromJson(json['cod_transfer_total']),
  deliveredOrdersCount: _intFromJson(json['delivered_orders_count']),
  returnedOrdersCount: _intFromJson(json['returned_orders_count']),
  totalCodChargeDelivered: _stringFromJson(json['total_cod_charge_delivered']),
  totalDeliveryChargeDelivered: _stringFromJson(
    json['total_delivery_charge_delivered'],
  ),
  totalCodChargeReturned: _stringFromJson(json['total_cod_charge_returned']),
  totalDeliveryChargeReturned: _stringFromJson(
    json['total_delivery_charge_returned'],
  ),
);

Map<String, dynamic> _$DailyTransectionsModelToJson(
  DailyTransectionsModel instance,
) => <String, dynamic>{
  'date': instance.date,
  'delivered_orders': instance.deliveredOrders,
  'returned_orders': instance.returnedOrders,
  'cod_transfer_total': instance.codTransferTotal,
  'delivered_orders_count': instance.deliveredOrdersCount,
  'returned_orders_count': instance.returnedOrdersCount,
  'total_cod_charge_delivered': instance.totalCodChargeDelivered,
  'total_delivery_charge_delivered': instance.totalDeliveryChargeDelivered,
  'total_cod_charge_returned': instance.totalCodChargeReturned,
  'total_delivery_charge_returned': instance.totalDeliveryChargeReturned,
};

DailyOrderModel _$DailyOrderModelFromJson(Map<String, dynamic> json) =>
    DailyOrderModel(
      orderId: _intFromJson(json['order_id']),
      codCharge: _stringFromJson(json['cod_charge']),
      deliveryCharge: _stringFromJson(json['delivery_charge']),
      deliveredDate: _dateTimeFromJson(json['delivered_date']),
      deliveredDateFormatted: _stringFromJson(json['delivered_date_formatted']),
    );

Map<String, dynamic> _$DailyOrderModelToJson(DailyOrderModel instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'cod_charge': instance.codCharge,
      'delivery_charge': instance.deliveryCharge,
      'delivered_date': instance.deliveredDate.toIso8601String(),
      'delivered_date_formatted': instance.deliveredDateFormatted,
    };
