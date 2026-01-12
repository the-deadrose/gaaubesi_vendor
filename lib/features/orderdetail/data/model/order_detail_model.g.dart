// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  id: (json['id'] as num?)?.toInt() ?? 0,
  messageType: json['message_type'] as String? ?? '',
  messageText: json['message_text'] as String? ?? '',
  sentOn: MessageModel._dateTimeFromJson(json['sent_on'] as String?),
  sentOnFormatted: json['sent_on_formatted'] as String? ?? '',
  sentByName: json['sent_by_name'] as String? ?? '',
);

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message_type': instance.messageType,
      'message_text': instance.messageText,
      'sent_on': MessageModel._dateTimeToJson(instance.sentOn),
      'sent_on_formatted': instance.sentOnFormatted,
      'sent_by_name': instance.sentByName,
    };

CommentsModel _$CommentsModelFromJson(Map<String, dynamic> json) =>
    CommentsModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      comments: json['comments'] as String? ?? '',
      commentType: json['comment_type'] as String? ?? '',
      commentTypeDisplay: json['comment_type_display'] as String? ?? '',
      status: json['status'] as String?,
      statusDisplay: json['status_display'] as String?,
      addedByName: json['added_by_name'] as String? ?? '',
      createdOn: json['created_on'] as String? ?? '',
      createdOnFormatted: json['created_on_formatted'] as String? ?? '',
      isImportant: json['is_important'] as bool? ?? false,
      canReply: json['can_reply'] as bool? ?? false,
    );

Map<String, dynamic> _$CommentsModelToJson(CommentsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'comments': instance.comments,
      'comment_type': instance.commentType,
      'comment_type_display': instance.commentTypeDisplay,
      'status': instance.status,
      'status_display': instance.statusDisplay,
      'added_by_name': instance.addedByName,
      'created_on': instance.createdOn,
      'created_on_formatted': instance.createdOnFormatted,
      'is_important': instance.isImportant,
      'can_reply': instance.canReply,
    };

OrderDetailModel _$OrderDetailModelFromJson(Map<String, dynamic> json) =>
    OrderDetailModel(
      orderId: (json['order_id'] as num?)?.toInt() ?? 0,
      orderIdWithStatus: json['order_id_with_status'] as String? ?? '',
      trackId: json['track_id'] as String? ?? '',
      getIsEditable: json['is_editable'] as bool? ?? false,
      orderType: json['order_type'] as String? ?? '',
      vendorName: json['vendor_name'] as String? ?? '',
      vendorReferenceId: json['vendor_reference_id'] as String? ?? '',
      sourceBranch: json['source_branch'] as String? ?? '',
      sourceBranchCode: json['source_branch_code'] as String? ?? '',
      destinationBranch: json['destination_branch'] as String? ?? '',
      destinationBranchCode: json['destination_branch_code'] as String? ?? '',
      warehouseBranch: json['warehouse_branch'] as String? ?? '',
      receiverName: json['receiver_name'] as String? ?? '',
      receiverNumber: json['receiver_number'] as String? ?? '',
      altReceiverNumber: json['alt_receiver_number'] as String? ?? '',
      receiverAddress: json['receiver_address'] as String? ?? '',
      weight: json['weight'] as String? ?? '0.00',
      codCharge: json['cod_charge'] as String? ?? '0.00',
      deliveryCharge: json['delivery_charge'] as String? ?? '0.00',
      packageAccess: json['package_access'] as String? ?? '',
      pickupType: json['pickup_type'] as String? ?? '',
      paymentType: json['payment_type'] as String? ?? '',
      lastDeliveryStatus: json['last_delivery_status'] as String? ?? '',
      orderDescription: json['order_description'] as String? ?? '',
      deliveryInstruction: json['delivery_instruction'] as String? ?? '',
      createdOn: OrderDetailModel._dateTimeFromJson(
        json['created_on'] as String?,
      ),
      createdOnFormatted: json['created_on_formatted'] as String? ?? '',
      deliveredDate: OrderDetailModel._nullableDateTimeFromJson(
        json['delivered_date'] as String?,
      ),
      deliveredDateFormatted: json['delivered_date_formatted'] as String? ?? '',
      hold: json['hold'] as bool? ?? false,
      vendorReturn: json['vendor_return'] as bool? ?? false,
      isExchangeOrder: json['is_exchange_order'] as bool? ?? false,
      isRefundOrder: json['is_refund_order'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? false,
      qrCode: json['qr_code'] as String? ?? '',
      messages:
          (json['message'] as List<dynamic>?)
              ?.map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      comments:
          (json['comment'] as List<dynamic>?)
              ?.map((e) => CommentsModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$OrderDetailModelToJson(OrderDetailModel instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'order_id_with_status': instance.orderIdWithStatus,
      'track_id': instance.trackId,
      'order_type': instance.orderType,
      'vendor_name': instance.vendorName,
      'vendor_reference_id': instance.vendorReferenceId,
      'source_branch': instance.sourceBranch,
      'source_branch_code': instance.sourceBranchCode,
      'destination_branch': instance.destinationBranch,
      'destination_branch_code': instance.destinationBranchCode,
      'warehouse_branch': instance.warehouseBranch,
      'receiver_name': instance.receiverName,
      'receiver_number': instance.receiverNumber,
      'alt_receiver_number': instance.altReceiverNumber,
      'receiver_address': instance.receiverAddress,
      'weight': instance.weight,
      'cod_charge': instance.codCharge,
      'delivery_charge': instance.deliveryCharge,
      'package_access': instance.packageAccess,
      'pickup_type': instance.pickupType,
      'payment_type': instance.paymentType,
      'last_delivery_status': instance.lastDeliveryStatus,
      'order_description': instance.orderDescription,
      'delivery_instruction': instance.deliveryInstruction,
      'is_editable': instance.getIsEditable,
      'created_on': OrderDetailModel._dateTimeToJson(instance.createdOn),
      'created_on_formatted': instance.createdOnFormatted,
      'delivered_date': OrderDetailModel._nullableDateTimeToJson(
        instance.deliveredDate,
      ),
      'delivered_date_formatted': instance.deliveredDateFormatted,
      'hold': instance.hold,
      'vendor_return': instance.vendorReturn,
      'is_exchange_order': instance.isExchangeOrder,
      'is_refund_order': instance.isRefundOrder,
      'is_active': instance.isActive,
      'qr_code': instance.qrCode,
      'message': instance.messages?.map((e) => e.toJson()).toList(),
      'comment': instance.comments?.map((e) => e.toJson()).toList(),
    };
