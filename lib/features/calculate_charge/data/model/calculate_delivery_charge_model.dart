// ignore_for_file: invalid_annotation_target

import 'package:gaaubesi_vendor/features/calculate_charge/domain/entity/calculate_deliver_charge_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'calculate_delivery_charge_model.g.dart'; 

@JsonSerializable()
class CalculateDeliveryChargeModel extends CalculateDeliveryCharge {
  const CalculateDeliveryChargeModel({
    super.success,
    super.message,
    @JsonKey(name: 'delivery_charge')
    super.deliveryCharge,
    @JsonKey(name: 'original_charge')
    super.originalCharge,
    @JsonKey(name: 'discounted_charge')
    super.discountedCharge,
    @JsonKey(name: 'has_discount')
    super.hasDiscount,
  });

  factory CalculateDeliveryChargeModel.fromJson(Map<String, dynamic> json) =>
      _$CalculateDeliveryChargeModelFromJson(json);

  Map<String, dynamic> toJson() => _$CalculateDeliveryChargeModelToJson(this);
}
