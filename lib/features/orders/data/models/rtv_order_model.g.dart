// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rtv_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RtvOrderModel _$RtvOrderModelFromJson(Map<String, dynamic> json) =>
    RtvOrderModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderId: json['order_id'] == null
          ? ''
          : RtvOrderModel._stringFromJson(json['order_id']),
      destinationBranch: json['destination'] == null
          ? ''
          : RtvOrderModel._stringFromJson(json['destination']),
      receiver: json['receiver_name'] == null
          ? ''
          : RtvOrderModel._stringFromJson(json['receiver_name']),
      receiverNumber: json['receiver_number'] == null
          ? ''
          : RtvOrderModel._stringFromJson(json['receiver_number']),
      rtvDate: json['created_date'] == null
          ? ''
          : RtvOrderModel._stringFromJson(json['created_date']),
    );

Map<String, dynamic> _$RtvOrderModelToJson(RtvOrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'destination': instance.destinationBranch,
      'receiver_name': instance.receiver,
      'receiver_number': instance.receiverNumber,
      'created_date': instance.rtvDate,
    };
