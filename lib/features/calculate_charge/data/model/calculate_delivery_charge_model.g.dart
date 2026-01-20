// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculate_delivery_charge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalculateDeliveryChargeModel _$CalculateDeliveryChargeModelFromJson(
  Map<String, dynamic> json,
) => CalculateDeliveryChargeModel(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  deliveryCharge: json['delivery_charge'] as String?,
  originalCharge: json['original_charge'] as String?,
  discountedCharge: json['discounted_charge'] as String?,
  hasDiscount: json['has_discount'] as bool?,
);

Map<String, dynamic> _$CalculateDeliveryChargeModelToJson(
  CalculateDeliveryChargeModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'delivery_charge': instance.deliveryCharge,
  'original_charge': instance.originalCharge,
  'discounted_charge': instance.discountedCharge,
  'has_discount': instance.hasDiscount,
};
