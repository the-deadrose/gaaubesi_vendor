import 'package:equatable/equatable.dart';

/// Entity representing detailed order information.
class OrderDetailEntity extends Equatable {
  final int orderId;
  final String sourceBranch;
  final String destinationBranch;
  final String vendor;
  final double codCharge;
  final double deliveryCharge;
  final String lastDeliveryStatus;
  final String receiver;
  final String receiverNumber;
  final String? altReceiverNumber;
  final String receiverAddress;
  final String createdOn;
  final String createdBy;
  final String trackId;
  final String packageAccess;
  final String? orderDeliveryInstruction;
  final String description;
  final String? vendorReferenceId;
  final String priority;
  final String? orderContactName;
  final String? orderContactNumber;
  final String codPaid;
  final String paymentCollection;
  final String lastUpdated;

  const OrderDetailEntity({
    required this.orderId,
    required this.sourceBranch,
    required this.destinationBranch,
    required this.vendor,
    required this.codCharge,
    required this.deliveryCharge,
    required this.lastDeliveryStatus,
    required this.receiver,
    required this.receiverNumber,
    this.altReceiverNumber,
    required this.receiverAddress,
    required this.createdOn,
    required this.createdBy,
    required this.trackId,
    required this.packageAccess,
    this.orderDeliveryInstruction,
    required this.description,
    this.vendorReferenceId,
    required this.priority,
    this.orderContactName,
    this.orderContactNumber,
    required this.codPaid,
    required this.paymentCollection,
    required this.lastUpdated,
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
