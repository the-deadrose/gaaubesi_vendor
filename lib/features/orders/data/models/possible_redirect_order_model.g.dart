// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'possible_redirect_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PossibleRedirectOrderModel _$PossibleRedirectOrderModelFromJson(
  Map<String, dynamic> json,
) => PossibleRedirectOrderModel(
  orderId: json['order_id'] as String,
  codCharge: json['cod_charge'] as String,
  destination: json['destination'] as String,
  createdOn: json['created_on'] as String,
  receiver: json['receiver'] as String,
  deliveryCharge: json['delivery_charge'] as String,
);

Map<String, dynamic> _$PossibleRedirectOrderModelToJson(
  PossibleRedirectOrderModel instance,
) => <String, dynamic>{
  'destination': instance.destination,
  'receiver': instance.receiver,
  'order_id': instance.orderId,
  'cod_charge': instance.codCharge,
  'created_on': instance.createdOn,
  'delivery_charge': instance.deliveryCharge,
};
