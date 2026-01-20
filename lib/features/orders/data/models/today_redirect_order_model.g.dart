// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_redirect_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayRedirectOrderModel _$TodayRedirectOrderModelFromJson(
  Map<String, dynamic> json,
) => TodayRedirectOrderModel(
  parentOrderId: _stringFromJson(json['parent_order_id']),
  childOrderId: (json['child_order_id'] as num).toInt(),
  childOrderStatus: _stringFromJson(json['child_order_status']),
  childCodCharge: _doubleFromJson(json['child_cod_charge']),
  parentDeliveryCharge: _stringFromJson(json['parent_delivery_charge']),
  childDeliveryCharge: _doubleFromJson(json['child_delivery_charge']),
  createdOn: _dateTimeFromJson(json['created_on']),
);

Map<String, dynamic> _$TodayRedirectOrderModelToJson(
  TodayRedirectOrderModel instance,
) => <String, dynamic>{
  'parent_order_id': instance.parentOrderId,
  'child_order_id': instance.childOrderId,
  'child_order_status': instance.childOrderStatus,
  'child_cod_charge': instance.childCodCharge,
  'parent_delivery_charge': instance.parentDeliveryCharge,
  'child_delivery_charge': instance.childDeliveryCharge,
  'created_on': instance.createdOn.toIso8601String(),
};

TodayRedirectOrderListModel _$TodayRedirectOrderListModelFromJson(
  Map<String, dynamic> json,
) => TodayRedirectOrderListModel(
  count: (json['count'] as num?)?.toInt() ?? 0,
  next: _stringFromJson(json['next']),
  previous: _stringFromJson(json['previous']),
  results: _orderListFromJson(json['results']),
);

Map<String, dynamic> _$TodayRedirectOrderListModelToJson(
  TodayRedirectOrderListModel instance,
) => <String, dynamic>{
  'results': instance.results,
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
};
