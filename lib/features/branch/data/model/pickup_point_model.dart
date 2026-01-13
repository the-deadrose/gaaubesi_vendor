import 'package:json_annotation/json_annotation.dart';
import '../../domain/entity/pickup_point_entity.dart';

part 'pickup_point_model.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class PickupPointModel {
  @JsonKey(name: 'name', defaultValue: '')
  final String name;

  const PickupPointModel({required this.name});

  factory PickupPointModel.fromJson(Map<String, dynamic> json) =>
      _$PickupPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$PickupPointModelToJson(this);

  PickupPointEntity toEntity() => PickupPointEntity(value: name, label: name);

  factory PickupPointModel.fromEntity(PickupPointEntity entity) =>
      PickupPointModel(name: entity.value);
}
