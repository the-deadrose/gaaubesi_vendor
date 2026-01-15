import 'package:equatable/equatable.dart';

class WarehouseOrderEvent extends Equatable{
  final String page;

  const WarehouseOrderEvent({required this.page});

  @override
  List<Object?> get props => [page];
}

class FetchWarehouseOrderEvent extends WarehouseOrderEvent {
  const FetchWarehouseOrderEvent({required super.page});

  @override
  List<Object?> get props => [page];
}