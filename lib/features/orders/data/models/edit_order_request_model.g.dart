// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_order_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditOrderRequestModel _$EditOrderRequestModelFromJson(
  Map<String, dynamic> json,
) => EditOrderRequestModel(
  branch: (json['branch'] as num).toInt(),
  destinationBranch: (json['destination_branch'] as num).toInt(),
  weight: (json['weight'] as num).toDouble(),
  codCharge: (json['cod_charge'] as num).toInt(),
  packageAccess: json['package_access'] as String,
  packageType: json['package_type'] as String,
  remarks: json['remarks'] as String,
  receiverName: json['receiver_name'] as String,
  receiverPhoneNumber: json['receiver_phone_number'] as String,
  pickupType: json['pickup_type'] as String,
  altReceiverPhoneNumber: json['alt_receiver_phone_number'] as String,
  receiverFullAddress: json['receiver_full_address'] as String,
);

Map<String, dynamic> _$EditOrderRequestModelToJson(
  EditOrderRequestModel instance,
) => <String, dynamic>{
  'branch': instance.branch,
  'destination_branch': instance.destinationBranch,
  'weight': instance.weight,
  'cod_charge': instance.codCharge,
  'package_access': instance.packageAccess,
  'package_type': instance.packageType,
  'remarks': instance.remarks,
  'receiver_name': instance.receiverName,
  'receiver_phone_number': instance.receiverPhoneNumber,
  'pickup_type': instance.pickupType,
  'alt_receiver_phone_number': instance.altReceiverPhoneNumber,
  'receiver_full_address': instance.receiverFullAddress,
};
