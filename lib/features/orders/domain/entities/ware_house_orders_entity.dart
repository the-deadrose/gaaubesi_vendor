import 'package:equatable/equatable.dart';

class WarehouseOrdersListEntity extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<WareHouseOrdersEntity> warehouses;

  const WarehouseOrdersListEntity({
    required this.count,
    this.next,
    this.previous,
    required this.warehouses,
  });

  @override
  List<Object?> get props => [count, next, previous, warehouses];
}

class WareHouseOrdersEntity extends Equatable {
  final int id;
  final String code;
  final String name;
  final int ordersCount;
  final List<int> orderIds;

  const WareHouseOrdersEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.ordersCount,
    required this.orderIds,
  });

  @override
  List<Object?> get props => [id, code, name, ordersCount, orderIds];
}