// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateOrderRequestModel _$CreateOrderRequestModelFromJson(
  Map<String, dynamic> json,
) => CreateOrderRequestModel(
  branch: json['branch'] as String,
  destinationBranch: json['destination_branch'] as String,
  receiverName: json['receiver_name'] as String,
  receiverPhoneNumber: json['receiver_phone_number'] as String,
  altReceiverPhoneNumber: json['alt_receiver_phone_number'] as String?,
  receiverFullAddress: json['receiver_full_address'] as String,
  weight: (json['weight'] as num).toDouble(),
  deliveryCharge: (json['delivery_charge'] as num).toDouble(),
  codCharge: (json['cod_charge'] as num).toDouble(),
  packageAccess: json['package_access'] as String,
  referenceId: json['reference_id'] as String?,
  pickupPoint: json['pickup_point'] as String?,
  pickupType: json['pickup_type'] as String,
  packageType: json['package_type'] as String,
  remarks: json['remarks'] as String?,
);

Map<String, dynamic> _$CreateOrderRequestModelToJson(
  CreateOrderRequestModel instance,
) => <String, dynamic>{
  'branch': instance.branch,
  'destination_branch': instance.destinationBranch,
  'receiver_name': instance.receiverName,
  'receiver_phone_number': instance.receiverPhoneNumber,
  'alt_receiver_phone_number': instance.altReceiverPhoneNumber,
  'receiver_full_address': instance.receiverFullAddress,
  'weight': instance.weight,
  'delivery_charge': instance.deliveryCharge,
  'cod_charge': instance.codCharge,
  'package_access': instance.packageAccess,
  'reference_id': instance.referenceId,
  'pickup_point': instance.pickupPoint,
  'pickup_type': instance.pickupType,
  'package_type': instance.packageType,
  'remarks': instance.remarks,
};
