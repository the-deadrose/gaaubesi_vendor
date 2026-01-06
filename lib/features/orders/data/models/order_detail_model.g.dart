// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderDetailModel _$OrderDetailModelFromJson(Map<String, dynamic> json) =>
    OrderDetailModel(
      orderId: (json['order_id'] as num?)?.toInt(),
      sourceBranch: json['source_branch'] as String?,
      destinationBranch: json['destination_branch'] as String?,
      vendor: json['vendor'] as String?,
      codCharge: (json['cod_charge'] as num?)?.toDouble(),
      deliveryCharge: (json['delivery_charge'] as num?)?.toDouble(),
      lastDeliveryStatus: json['last_delivery_status'] as String?,
      receiver: json['receiver'] as String?,
      receiverNumber: json['receiver_number'] as String?,
      altReceiverNumber: json['alt_receiver_number'] as String?,
      receiverAddress: json['receiver_address'] as String?,
      createdOn: json['created_on'] as String?,
      createdBy: json['created_by'] as String?,
      trackId: json['track_id'] as String?,
      packageAccess: json['package_access'] as String?,
      orderDeliveryInstruction: json['order_delivery_instruction'] as String?,
      description: json['description'] as String?,
      vendorReferenceId: json['vendor_reference_id'] as String?,
      priority: json['priority'] as String?,
      orderContactName: json['order_contact_name'] as String?,
      orderContactNumber: json['order_contact_number'] as String?,
      codPaid: json['cod_paid'] as String?,
      paymentCollection: json['payment_collection'] as String?,
      lastUpdated: json['last_updated'] as String?,
    );

Map<String, dynamic> _$OrderDetailModelToJson(OrderDetailModel instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'source_branch': instance.sourceBranch,
      'destination_branch': instance.destinationBranch,
      'vendor': instance.vendor,
      'cod_charge': instance.codCharge,
      'delivery_charge': instance.deliveryCharge,
      'last_delivery_status': instance.lastDeliveryStatus,
      'receiver': instance.receiver,
      'receiver_number': instance.receiverNumber,
      'alt_receiver_number': instance.altReceiverNumber,
      'receiver_address': instance.receiverAddress,
      'created_on': instance.createdOn,
      'created_by': instance.createdBy,
      'track_id': instance.trackId,
      'package_access': instance.packageAccess,
      'order_delivery_instruction': instance.orderDeliveryInstruction,
      'description': instance.description,
      'vendor_reference_id': instance.vendorReferenceId,
      'priority': instance.priority,
      'order_contact_name': instance.orderContactName,
      'order_contact_number': instance.orderContactNumber,
      'cod_paid': instance.codPaid,
      'payment_collection': instance.paymentCollection,
      'last_updated': instance.lastUpdated,
    };
