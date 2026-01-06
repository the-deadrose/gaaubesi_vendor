import 'package:equatable/equatable.dart';

/// Entity representing detailed order information.
class OrderDetailEntity extends Equatable {
  final int? orderId;
  final String? sourceBranch;
  final String? destinationBranch;
  final String? vendor;
  final double? codCharge;
  final double? deliveryCharge;
  final String? lastDeliveryStatus;
  final String? receiver;
  final String? receiverNumber;
  final String? altReceiverNumber;
  final String? receiverAddress;
  final String? createdOn;
  final String? createdBy;
  final String? trackId;
  final String? packageAccess;
  final String? orderDeliveryInstruction;
  final String? description;
  final String? vendorReferenceId;
  final String? priority;
  final String? orderContactName;
  final String? orderContactNumber;
  final String? codPaid;
  final String? paymentCollection;
  final String? lastUpdated;

  const OrderDetailEntity({
    this.orderId,
    this.sourceBranch,
    this.destinationBranch,
    this.vendor,
    this.codCharge,
    this.deliveryCharge,
    this.lastDeliveryStatus,
    this.receiver,
    this.receiverNumber,
    this.altReceiverNumber,
    this.receiverAddress,
    this.createdOn,
    this.createdBy,
    this.trackId,
    this.packageAccess,
    this.orderDeliveryInstruction,
    this.description,
    this.vendorReferenceId,
    this.priority,
    this.orderContactName,
    this.orderContactNumber,
    this.codPaid,
    this.paymentCollection,
    this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        orderId,
        sourceBranch,
        destinationBranch,
        vendor,
        codCharge,
        deliveryCharge,
        lastDeliveryStatus,
        receiver,
        receiverNumber,
        altReceiverNumber,
        receiverAddress,
        createdOn,
        createdBy,
        trackId,
        packageAccess,
        orderDeliveryInstruction,
        description,
        vendorReferenceId,
        priority,
        orderContactName,
        orderContactNumber,
        codPaid,
        paymentCollection,
        lastUpdated,
      ];
}
