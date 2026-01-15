// warehouse_order_state.dart
import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/ware_house_orders_entity.dart';

class WarehouseOrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WarehouseOrderInitialState extends WarehouseOrderState {}

class WarehouseOrderLoadingState extends WarehouseOrderState {}

class WarehouseOrderLoadedState extends WarehouseOrderState {
  final WarehouseOrdersListEntity warehouseOrdersListEntity;

  WarehouseOrderLoadedState({required this.warehouseOrdersListEntity});

  @override
  List<Object?> get props => [warehouseOrdersListEntity];
}

class WarehouseOrderErrorState extends WarehouseOrderState {
  final String message;

  WarehouseOrderErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class WareHousePaginatingState extends WarehouseOrderState {}

class WareHousePaginatingErrorState extends WarehouseOrderState {
  final String message;

  WareHousePaginatingErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class WareHousePaginated extends WarehouseOrderState {
  final WarehouseOrdersListEntity warehouseOrdersListEntity;

  WareHousePaginated({required this.warehouseOrdersListEntity});

  @override
  List<Object?> get props => [warehouseOrdersListEntity];
}