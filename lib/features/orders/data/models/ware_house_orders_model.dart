import 'package:gaaubesi_vendor/features/orders/domain/entities/ware_house_orders_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ware_house_orders_model.g.dart';

@JsonSerializable()
class WareHouseOrdersModel extends WareHouseOrdersEntity {
  @JsonKey(name: 'id', defaultValue: 0)
  final int id;

  @JsonKey(name: 'code', defaultValue: '')
  final String code;

  @JsonKey(name: 'name', defaultValue: '')
  final String name;

  @JsonKey(name: 'orders_count', defaultValue: 0)
  final int ordersCount;

  const WareHouseOrdersModel({
    required this.id,
    required this.code,
    required this.name,
    required this.ordersCount,
  }) : super(
          id: id,
          code: code,
          name: name,
          ordersCount: ordersCount,
        );

  factory WareHouseOrdersModel.fromJson(Map<String, dynamic> json) =>
      _$WareHouseOrdersModelFromJson(json);

  Map<String, dynamic> toJson() => _$WareHouseOrdersModelToJson(this);
}
