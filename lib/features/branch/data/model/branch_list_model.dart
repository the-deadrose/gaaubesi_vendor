import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'branch_list_model.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class OrderStatusModel {
  @JsonKey(name: 'id', defaultValue: 0)
  final int id;
  
  @JsonKey(name: 'code', defaultValue: '')
  final String code;
  
  @JsonKey(name: 'name', defaultValue: '')
  final String name;

  const OrderStatusModel({
    required this.id,
    required this.code,
    required this.name,
  });

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStatusModelToJson(this);

  OrderStatusEntity toEntity() => OrderStatusEntity(
        value: id.toString(), // Use ID as value for backend
        label: '$code - $name', // Show code and name in dropdown
        code: code, // Branch code for matching
      );

  factory OrderStatusModel.fromEntity(OrderStatusEntity entity) =>
      OrderStatusModel(
        id: int.tryParse(entity.value) ?? 0,
        code: entity.code,
        name: entity.label,
      );
}
