import 'package:equatable/equatable.dart';

class StaleOrdersEntity extends Equatable {
  final int orderId;
  final String orderIdWithStatus;
  final DateTime createdOn;
  final String createdOnFormatted;
  final String receiverName;
  final String receiverPhone;
  final String receiverAltPhone;
  final String receiverAddress;
  final String sourceBranch;
  final String destinationBranch;
  final String codCharge;
  final String lastDeliveryStatus;
  final String orderDescription;
  final bool hold;
  final bool vendorReturn;
  final bool isExchangeOrder;
  final bool isRefundOrder;

  const StaleOrdersEntity({
    required this.orderId,
    required this.orderIdWithStatus,
    required this.createdOn,
    required this.createdOnFormatted,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAltPhone,
    required this.receiverAddress,
    required this.sourceBranch,
    required this.destinationBranch,
    required this.codCharge,
    required this.lastDeliveryStatus,
    required this.orderDescription,
    required this.hold,
    required this.vendorReturn,
    required this.isExchangeOrder,
    required this.isRefundOrder,
  });

  @override
  List<Object?> get props => [
        orderId,
        orderIdWithStatus,
        createdOn,
        createdOnFormatted,
        receiverName,
        receiverPhone,
        receiverAltPhone,
        receiverAddress,
        sourceBranch,
        destinationBranch,
        codCharge,
        lastDeliveryStatus,
        orderDescription,
        hold,
        vendorReturn,
        isExchangeOrder,
        isRefundOrder,
      ];
}
