// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ware_house_orders_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WarehouseOrdersListModel _$WarehouseOrdersListModelFromJson(
  Map<String, dynamic> json,
) => WarehouseOrdersListModel(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  warehouses: (json['results'] as List<dynamic>)
      .map((e) => WareHouseOrdersModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WarehouseOrdersListModelToJson(
  WarehouseOrdersListModel instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.warehouses,
};

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
