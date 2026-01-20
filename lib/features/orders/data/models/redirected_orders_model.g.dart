// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redirected_orders_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RedirectedOrdersModel _$RedirectedOrdersModelFromJson(
  Map<String, dynamic> json,
) => RedirectedOrdersModel(
  count: json['count'] == null ? 0 : _intFromJson(json['count']),
  next: json['next'] == null ? '' : _stringFromJson(json['next']),
  previous: json['previous'] == null ? '' : _stringFromJson(json['previous']),
  results: json['results'] == null
      ? []
      : _redirectedOrderListFromJson(json['results']),
);

Map<String, dynamic> _$RedirectedOrdersModelToJson(
  RedirectedOrdersModel instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};

RedirectedOrderItemModel _$RedirectedOrderItemModelFromJson(
  Map<String, dynamic> json,
) => RedirectedOrderItemModel(
  parentOrderId: json['parent_order_id'] == null
      ? ''
      : _stringFromJson(json['parent_order_id']),
  childOrderId: json['child_order_id'] == null
      ? 0
      : _intFromJson(json['child_order_id']),
  childOrderStatus: json['child_order_status'] == null
      ? ''
      : _stringFromJson(json['child_order_status']),
  vendorName: json['vendor_name'] == null
      ? ''
      : _stringFromJson(json['vendor_name']),
  createdOn: _dateTimeFromJson(json['created_on']),
);

Map<String, dynamic> _$RedirectedOrderItemModelToJson(
  RedirectedOrderItemModel instance,
) => <String, dynamic>{
  'parent_order_id': instance.parentOrderId,
  'child_order_id': instance.childOrderId,
  'child_order_status': instance.childOrderStatus,
  'vendor_name': instance.vendorName,
  'created_on': instance.createdOn.toIso8601String(),
};
