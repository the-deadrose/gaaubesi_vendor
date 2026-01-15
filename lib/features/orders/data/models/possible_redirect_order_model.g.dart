// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'possible_redirect_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PossibleRedirectOrderModel _$PossibleRedirectOrderModelFromJson(
  Map<String, dynamic> json,
) => PossibleRedirectOrderModel(
  orderId: json['order_id'] == null
      ? ''
      : PossibleRedirectOrderModel._stringFromJson(json['order_id']),
  codCharge: json['cod_charge'] == null
      ? ''
      : PossibleRedirectOrderModel._stringFromJson(json['cod_charge']),
  destination: json['destination'] == null
      ? ''
      : PossibleRedirectOrderModel._stringFromJson(json['destination']),
  createdOn: json['create_date_formatted'] == null
      ? ''
      : PossibleRedirectOrderModel._stringFromJson(
          json['create_date_formatted'],
        ),
  receiver: json['receiver_name'] == null
      ? ''
      : PossibleRedirectOrderModel._stringFromJson(json['receiver_name']),
  deliveryCharge: json['delivery_charge'] == null
      ? ''
      : PossibleRedirectOrderModel._stringFromJson(json['delivery_charge']),
);

Map<String, dynamic> _$PossibleRedirectOrderModelToJson(
  PossibleRedirectOrderModel instance,
) => <String, dynamic>{
  'order_id': instance.orderId,
  'cod_charge': instance.codCharge,
  'destination': instance.destination,
  'create_date_formatted': instance.createdOn,
  'receiver_name': instance.receiver,
  'delivery_charge': instance.deliveryCharge,
};
