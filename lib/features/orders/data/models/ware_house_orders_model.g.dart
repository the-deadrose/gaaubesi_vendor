// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ware_house_orders_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WareHouseOrdersModel _$WareHouseOrdersModelFromJson(
  Map<String, dynamic> json,
) => WareHouseOrdersModel(
  id: (json['id'] as num?)?.toInt() ?? 0,
  code: json['code'] as String? ?? '',
  name: json['name'] as String? ?? '',
  ordersCount: (json['orders_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$WareHouseOrdersModelToJson(
  WareHouseOrdersModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'orders_count': instance.ordersCount,
};
