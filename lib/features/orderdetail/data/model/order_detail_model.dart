import 'package:json_annotation/json_annotation.dart';
import 'package:gaaubesi_vendor/features/orderdetail/domain/entities/order_detail_entity.dart';

part '../../../orders/data/models/order_detail_model.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
)
class MessageModel extends MessageEntity {
  @JsonKey(defaultValue: 0)
  @override
  final int id;

  @JsonKey(defaultValue: '', name: 'message_type')
  @override
  final String messageType;

  @JsonKey(defaultValue: '', name: 'message_text')
  @override
  final String messageText;

  @JsonKey(
    fromJson: _dateTimeFromJson,
    toJson: _dateTimeToJson,
    name: 'sent_on',
  )
  @override
  final DateTime sentOn;

  @JsonKey(defaultValue: '', name: 'sent_on_formatted')
  @override
  final String sentOnFormatted;

  @JsonKey(defaultValue: '', name: 'sent_by_name')
  @override
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
class OrderDetailModel extends OrderDetailEntity {
  @JsonKey(defaultValue: 0)
  @override
  final int orderId;

  @JsonKey(defaultValue: '')
  @override
  final String orderIdWithStatus;

  @JsonKey(defaultValue: '')
  @override
  final String trackId;

  @JsonKey(defaultValue: '')
  @override
  final String orderType;

  @JsonKey(defaultValue: '')
  @override
  final String vendorName;

  @JsonKey(defaultValue: '')
  @override
  final String vendorReferenceId;

  @JsonKey(defaultValue: '')
  @override
  final String sourceBranch;

  @JsonKey(defaultValue: '')
  @override
  final String sourceBranchCode;

  @JsonKey(defaultValue: '')
  @override
  final String destinationBranch;

  @JsonKey(defaultValue: '')
  @override
  final String destinationBranchCode;

  @JsonKey(defaultValue: '')
  @override
  final String warehouseBranch;

  @JsonKey(defaultValue: '')
  @override
  final String receiverName;

  @JsonKey(defaultValue: '')
  @override
  final String receiverNumber;

  @JsonKey(defaultValue: '')
  @override
  final String altReceiverNumber;

  @JsonKey(defaultValue: '')
  @override
  final String receiverAddress;

  @JsonKey(defaultValue: '0.00')
  @override
  final String weight;

  @JsonKey(defaultValue: '0.00')
  @override
  final String codCharge;

  @JsonKey(defaultValue: '0.00')
  @override
  final String deliveryCharge;

  @JsonKey(defaultValue: '')
  @override
  final String packageAccess;

  @JsonKey(defaultValue: '')
  @override
  final String pickupType;

  @JsonKey(defaultValue: '')
  @override
  final String paymentType;

  @JsonKey(defaultValue: '')
  @override
  final String lastDeliveryStatus;

  @JsonKey(defaultValue: '')
  @override
  final String orderDescription;

  @JsonKey(defaultValue: '')
  @override
  final String deliveryInstruction;

  @JsonKey(
    fromJson: _dateTimeFromJson,
    toJson: _dateTimeToJson,
  )
  @override
  final DateTime createdOn;

  @JsonKey(defaultValue: '')
  @override
  final String createdOnFormatted;

  @JsonKey(
    fromJson: _nullableDateTimeFromJson,
    toJson: _nullableDateTimeToJson,
  )
  @override
  final DateTime? deliveredDate;

  @JsonKey(defaultValue: '')
  @override
  final String deliveredDateFormatted;

  @JsonKey(defaultValue: false)
  @override
  final bool hold;

  @JsonKey(defaultValue: false)
  @override
  final bool vendorReturn;

  @JsonKey(defaultValue: false)
  @override
  final bool isExchangeOrder;

  @JsonKey(defaultValue: false)
  @override
  final bool isRefundOrder;

  @JsonKey(defaultValue: false)
  @override
  final bool isActive;

  @JsonKey(defaultValue: '')
  @override
  final String qrCode;

  @JsonKey(defaultValue: [], name: 'message')
  @override
  final List<MessageModel>? messages;

  const OrderDetailModel({
    required this.orderId,
    required this.orderIdWithStatus,
    required this.trackId,
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
  }) : super(
          orderId: orderId,
          orderIdWithStatus: orderIdWithStatus,
          trackId: trackId,
          orderType: orderType,
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
        );

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    print('JSON keys in order detail: ${json.keys.toList()}');
    if (json.containsKey('messages')) {
      print('Messages in JSON: ${json['messages']}');
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

