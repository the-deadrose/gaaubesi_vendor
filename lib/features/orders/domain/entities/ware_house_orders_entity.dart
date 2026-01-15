import 'package:equatable/equatable.dart';

class WareHouseOrdersEntity extends Equatable {
  final int id;
  final String code;
  final String name;
  final int ordersCount;

  const WareHouseOrdersEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.ordersCount,
  });

  @override
  List<Object?> get props => [id, code, name, ordersCount];
}
