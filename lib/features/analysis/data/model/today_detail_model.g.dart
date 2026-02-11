// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayDetailModel _$TodayDetailModelFromJson(Map<String, dynamic> json) =>
    TodayDetailModel(
      sNModel: (json['s_n'] as num?)?.toInt(),
      orderIdModel: (json['order_id'] as num?)?.toInt(),
      sourceBranchModel: json['source_branch'] as String?,
      destinationBranchModel: json['destination_branch'] as String?,
      receiverNameModel: json['receiver_name'] as String?,
      receiverAddressModel: json['receiver_address'] as String?,
      deliveryChargeModel: json['delivery_charge'] as String?,
      cod: json['cod'] as String? ?? '0.00',
      createdAtModel: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      lastDeliveryStatusModel: json['last_delivery_status'] as String?,
    );

Map<String, dynamic> _$TodayDetailModelToJson(TodayDetailModel instance) =>
    <String, dynamic>{
      's_n': instance.sNModel,
      'order_id': instance.orderIdModel,
      'source_branch': instance.sourceBranchModel,
      'destination_branch': instance.destinationBranchModel,
      'receiver_name': instance.receiverNameModel,
      'receiver_address': instance.receiverAddressModel,
      'delivery_charge': instance.deliveryChargeModel,
      'cod': instance.cod,
      'created_at': instance.createdAtModel?.toIso8601String(),
      'last_delivery_status': instance.lastDeliveryStatusModel,
    };
