import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'branch_list_model.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OrderStatusModel {
  final String value;
  final String label;

  const OrderStatusModel({
    required this.value,
    required this.label,
  });

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStatusModelToJson(this);

  OrderStatusEntity toEntity() => OrderStatusEntity(
        value: value,
        label: label,
      );

  factory OrderStatusModel.fromEntity(OrderStatusEntity entity) =>
      OrderStatusModel(
        value: entity.value,
        label: entity.label,
      );
}
