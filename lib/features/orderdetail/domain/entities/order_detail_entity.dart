import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final int id;
  final String messageType;
  final String messageText;
  final DateTime sentOn;
  final String sentOnFormatted;
  final String sentByName;

  const MessageEntity({
    required this.id,
    required this.messageType,
    required this.messageText,
    required this.sentOn,
    required this.sentOnFormatted,
    required this.sentByName,
  });

  @override
  List<Object?> get props => [
    id,
    messageType,
    messageText,
    sentOn,
    sentOnFormatted,
    sentByName,
  ];
}

class CommentsEntity extends Equatable {
  final int id;
  final String comments;
  final String commentType;
  final String commentTypeDisplay;
  final String? status;
  final String? statusDisplay;
  final String addedByName;
  final String createdOn;
  final String createdOnFormatted;
  final bool isImportant;
  final bool canReply;
  const CommentsEntity({
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
  });

  @override
  List<Object?> get props => [
    id,
    comments,
    commentType,
    commentTypeDisplay,
    status,
    statusDisplay,
    addedByName,
    createdOn,
    createdOnFormatted,
    isImportant,
    canReply,
  ];
}

class OrderDetailEntity extends Equatable {
  final int orderId;
  final String orderIdWithStatus;
  final bool getIsEditable;
  final String trackId;
  final String orderType;
  final String vendorName;
  final String vendorReferenceId;
  final String sourceBranch;
  final String sourceBranchCode;
  final String destinationBranch;
  final String destinationBranchCode;
  final String warehouseBranch;
  final String receiverName;
  final String receiverNumber;
  final String altReceiverNumber;
  final String receiverAddress;
  final String weight;
  final String codCharge;
  final String deliveryCharge;
  final String packageAccess;
  final String pickupType;
  final String paymentType;
  final String lastDeliveryStatus;
  final String orderDescription;
  final String deliveryInstruction;
  final DateTime createdOn;
  final String createdOnFormatted;
  final DateTime? deliveredDate;
  final String deliveredDateFormatted;
  final bool hold;
  final bool vendorReturn;
  final bool isExchangeOrder;
  final bool isRefundOrder;
  final bool isActive;
  final String qrCode;
  final List<MessageEntity>? messages;
  final List<CommentsEntity>? comments;

  const OrderDetailEntity({
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
    required this.getIsEditable,
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
  });

  @override
  List<Object?> get props => [
    orderId,
    orderIdWithStatus,
    trackId,
    orderType,
    vendorName,
    vendorReferenceId,
    sourceBranch,
    sourceBranchCode,
    destinationBranch,
    destinationBranchCode,
    warehouseBranch,
    receiverName,
    receiverNumber,
    altReceiverNumber,
    receiverAddress,
    weight,
    codCharge,
    deliveryCharge,
    packageAccess,
    pickupType,
    paymentType,
    lastDeliveryStatus,
    orderDescription,
    deliveryInstruction,
    createdOn,
    createdOnFormatted,
    deliveredDate,
    deliveredDateFormatted,
    hold,
    vendorReturn,
    isExchangeOrder,
    isRefundOrder,
    isActive,
    qrCode,
    messages,
    comments,
    getIsEditable
  ];
}
