// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rtv_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RtvOrderModel _$RtvOrderModelFromJson(Map<String, dynamic> json) =>
    RtvOrderModel(
      orderId: json['order_id'] as String,
      destinationBranch: json['destination_branch'] as String,
      receiver: json['receiver'] as String,
      receiverNumber: json['receiver_number'] as String,
      rtvDate: json['rtv_date'] as String,
    );

Map<String, dynamic> _$RtvOrderModelToJson(RtvOrderModel instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'destination_branch': instance.destinationBranch,
      'receiver': instance.receiver,
      'receiver_number': instance.receiverNumber,
      'rtv_date': instance.rtvDate,
    };
