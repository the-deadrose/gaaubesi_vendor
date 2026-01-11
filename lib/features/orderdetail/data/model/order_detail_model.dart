import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:gaaubesi_vendor/features/orderdetail/domain/entities/order_detail_entity.dart';

part 'order_detail_model.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
)
class MessageModel extends MessageEntity {
  @JsonKey(defaultValue: 0)
  final int id;

  @JsonKey(defaultValue: '', name: 'message_type')
  final String messageType;

  @JsonKey(defaultValue: '', name: 'message_text')
  final String messageText;

  @JsonKey(
    fromJson: _dateTimeFromJson,
    toJson: _dateTimeToJson,
    name: 'sent_on',
  )
  final DateTime sentOn;

  @JsonKey(defaultValue: '', name: 'sent_on_formatted')
  final String sentOnFormatted;

  @JsonKey(defaultValue: '', name: 'sent_by_name')
  final String sentByName;

  const MessageModel({
    required this.id,
    required this.messageType,
    required this.messageText,
    required this.sentOn,
    required this.sentOnFormatted,
    required this.sentByName,
  }) : super(
          id: id,
          messageType: messageType,
          messageText: messageText,
          sentOn: sentOn,
          sentOnFormatted: sentOnFormatted,
          sentByName: sentByName,
        );

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  static DateTime _dateTimeFromJson(String? value) {
    if (value == null || value.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _dateTimeToJson(DateTime value) {
    return value.toIso8601String();
  }
}

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
)
class CommentsModel extends CommentsEntity {
  @JsonKey(defaultValue: 0)
  final int id;

  @JsonKey(defaultValue: '')
  final String comments;

  @JsonKey(defaultValue: '')
  final String commentType;

  @JsonKey(defaultValue: '')
  final String commentTypeDisplay;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'status_display')
  final String? statusDisplay;

  @JsonKey(defaultValue: '', name: 'added_by_name')
  final String addedByName;

  @JsonKey(defaultValue: '', name: 'created_on')
  final String createdOn;

  @JsonKey(defaultValue: '', name: 'created_on_formatted')
  final String createdOnFormatted;

  @JsonKey(defaultValue: false)
  final bool isImportant;

  @JsonKey(defaultValue: false, name: 'can_reply')
  final bool canReply;

  const CommentsModel({
    required this.id,
    required this.comments,
    required this.commentType,
    required this.commentTypeDisplay,
    this.status,
    this.statusDisplay,
    required this.addedByName,
    required this.createdOn,
    required this.createdOnFormatted,
    required this.isImportant,
    required this.canReply,
  }) : super(
          id: id,
          comments: comments,
          commentType: commentType,
          commentTypeDisplay: commentTypeDisplay,
          status: status,
          statusDisplay: statusDisplay,
          addedByName: addedByName,
          createdOn: createdOn,
          createdOnFormatted: createdOnFormatted,
          isImportant: isImportant,
          canReply: canReply,
        );

  factory CommentsModel.fromJson(Map<String, dynamic> json) =>
      _$CommentsModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentsModelToJson(this);
}

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
)
class OrderDetailModel extends OrderDetailEntity {
  @JsonKey(defaultValue: 0)
  final int orderId;

  @JsonKey(defaultValue: '')
  final String orderIdWithStatus;

  @JsonKey(defaultValue: '')
  final String trackId;

  @JsonKey(defaultValue: '')
  final String orderType;

  @JsonKey(defaultValue: '')
  final String vendorName;

  @JsonKey(defaultValue: '')
  final String vendorReferenceId;

  @JsonKey(defaultValue: '')
  final String sourceBranch;

  @JsonKey(defaultValue: '')
  final String sourceBranchCode;

  @JsonKey(defaultValue: '')
  final String destinationBranch;

  @JsonKey(defaultValue: '')
  final String destinationBranchCode;

  @JsonKey(defaultValue: '')
  final String warehouseBranch;

  @JsonKey(defaultValue: '')
  final String receiverName;

  @JsonKey(defaultValue: '')
  final String receiverNumber;

  @JsonKey(defaultValue: '')
  final String altReceiverNumber;

  @JsonKey(defaultValue: '')
  final String receiverAddress;

  @JsonKey(defaultValue: '0.00')
  final String weight;

  @JsonKey(defaultValue: '0.00')
  final String codCharge;

  @JsonKey(defaultValue: '0.00')
  final String deliveryCharge;

  @JsonKey(defaultValue: '')
  final String packageAccess;

  @JsonKey(defaultValue: '')
  final String pickupType;

  @JsonKey(defaultValue: '')
  final String paymentType;

  @JsonKey(defaultValue: '')
  final String lastDeliveryStatus;

  @JsonKey(defaultValue: '')
  final String orderDescription;

  @JsonKey(defaultValue: '')
  final String deliveryInstruction;

  @JsonKey(
   defaultValue: false,
  )
  final bool getIsEditable;

  @JsonKey(
    fromJson: _dateTimeFromJson,
    toJson: _dateTimeToJson,
  )
  final DateTime createdOn;

  @JsonKey(defaultValue: '')
  final String createdOnFormatted;

  @JsonKey(
    fromJson: _nullableDateTimeFromJson,
    toJson: _nullableDateTimeToJson,
  )
  final DateTime? deliveredDate;

  @JsonKey(defaultValue: '')
  final String deliveredDateFormatted;

  @JsonKey(defaultValue: false)
  final bool hold;

  @JsonKey(defaultValue: false)
  final bool vendorReturn;

  @JsonKey(defaultValue: false)
  final bool isExchangeOrder;

  @JsonKey(defaultValue: false)
  final bool isRefundOrder;

  @JsonKey(defaultValue: false)
  final bool isActive;

  @JsonKey(defaultValue: '')
  final String qrCode;

  @JsonKey(defaultValue: [], name: 'message')
  final List<MessageModel>? messages;

  @JsonKey(defaultValue: [], name: 'comment')
  final List<CommentsModel>? comments;

  const OrderDetailModel({
    required this.orderId,
    required this.orderIdWithStatus,
    required this.trackId,
    required this.getIsEditable,
    required this.orderType,
    required this.vendorName,
    required this.vendorReferenceId,
    required this.sourceBranch,
    required this.sourceBranchCode,
    required this.destinationBranch,
    required this.destinationBranchCode,
    required this.warehouseBranch,
    required this.receiverName,
    required this.receiverNumber,
    required this.altReceiverNumber,
    required this.receiverAddress,
    required this.weight,
    required this.codCharge,
    required this.deliveryCharge,
    required this.packageAccess,
    required this.pickupType,
    required this.paymentType,
    required this.lastDeliveryStatus,
    required this.orderDescription,
    required this.deliveryInstruction,
    required this.createdOn,
    required this.createdOnFormatted,
    required this.deliveredDate,
    required this.deliveredDateFormatted,
    required this.hold,
    required this.vendorReturn,
    required this.isExchangeOrder,
    required this.isRefundOrder,
    required this.isActive,
    required this.qrCode,
    this.messages,
    this.comments,
  }) : super(
          orderId: orderId,
          orderIdWithStatus: orderIdWithStatus,
          trackId: trackId,
          orderType: orderType,
          getIsEditable: getIsEditable,
          vendorName: vendorName,
          vendorReferenceId: vendorReferenceId,
          sourceBranch: sourceBranch,
          sourceBranchCode: sourceBranchCode,
          destinationBranch: destinationBranch,
          destinationBranchCode: destinationBranchCode,
          warehouseBranch: warehouseBranch,
          receiverName: receiverName,
          receiverNumber: receiverNumber,
          altReceiverNumber: altReceiverNumber,
          receiverAddress: receiverAddress,
          weight: weight,
          codCharge: codCharge,
          deliveryCharge: deliveryCharge,
          packageAccess: packageAccess,
          pickupType: pickupType,
          paymentType: paymentType,
          lastDeliveryStatus: lastDeliveryStatus,
          orderDescription: orderDescription,
          deliveryInstruction: deliveryInstruction,
          createdOn: createdOn,
          createdOnFormatted: createdOnFormatted,
          deliveredDate: deliveredDate,
          deliveredDateFormatted: deliveredDateFormatted,
          hold: hold,
          vendorReturn: vendorReturn,
          isExchangeOrder: isExchangeOrder,
          isRefundOrder: isRefundOrder,
          isActive: isActive,
          qrCode: qrCode,
          messages: messages,
          comments: comments,
        );

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    debugPrint('JSON keys in order detail: ${json.keys.toList()}');
    if (json.containsKey('messages')) {
      debugPrint('Messages in JSON: ${json['messages']}');
    }
    if (json.containsKey('comments')) {
      debugPrint('Comments in JSON: ${json['comments']}');
    }
    return _$OrderDetailModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OrderDetailModelToJson(this);

  static DateTime _dateTimeFromJson(String? value) {
    if (value == null || value.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _dateTimeToJson(DateTime value) {
    return value.toIso8601String();
  }

  static DateTime? _nullableDateTimeFromJson(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  static String? _nullableDateTimeToJson(DateTime? value) {
    return value?.toIso8601String();
  }
}
