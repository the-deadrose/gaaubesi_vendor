import 'package:gaaubesi_vendor/features/orders/domain/entities/ware_house_orders_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ware_house_orders_model.g.dart';

@JsonSerializable()
class WarehouseOrdersListModel extends WarehouseOrdersListEntity {
  @JsonKey(name: 'count')
  final int count;

  @JsonKey(name: 'next')
  final String? next;

  @JsonKey(name: 'previous')
  final String? previous;

  @JsonKey(name: 'results')
  final List<WareHouseOrdersModel> warehouses;

  const WarehouseOrdersListModel({
    required this.count,
    this.next,
    this.previous,
    required this.warehouses,
  }) : super(
          count: count,
          next: next,
          previous: previous,
          warehouses: warehouses,
        );

  factory WarehouseOrdersListModel.fromJson(Map<String, dynamic> json) =>
      _$WarehouseOrdersListModelFromJson(json);

  Map<String, dynamic> toJson() => _$WarehouseOrdersListModelToJson(this);
}

@JsonSerializable()
class WareHouseOrdersModel extends WareHouseOrdersEntity {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'code')
  final String code;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'orders_count')
  final int ordersCount;

  @JsonKey(name: 'order_ids')
  final List<int> orderIds;

  const WareHouseOrdersModel({
    required this.id,
    required this.code,
    required this.name,
    required this.ordersCount,
    required this.orderIds,
  }) : super(
          id: id,
          code: code,
          name: name,
          ordersCount: ordersCount,
          orderIds: orderIds,
        );

  factory WareHouseOrdersModel.fromJson(Map<String, dynamic> json) =>
      _$WareHouseOrdersModelFromJson(json);

  Map<String, dynamic> toJson() => _$WareHouseOrdersModelToJson(this);
}