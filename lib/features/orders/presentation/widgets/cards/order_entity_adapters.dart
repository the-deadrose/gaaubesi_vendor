import 'package:gaaubesi_vendor/features/orders/domain/entities/delivered_order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/possible_redirect_order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/redirected_orders_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/returned_order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/rtv_order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/stale_orders_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/today_redirect_order_entity.dart';

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

extension DeliveredOrderEntityAdapter on DeliveredOrderEntity {
  OrderEntity toOrderEntity() {
    return OrderEntity(
      orderId: orderId,
      orderIdWithStatus: '$orderId Delivered',
      deliveredDate: deliveredDateFormatted,
      receiverName: receiverName,
      receiverNumber: receiverNumber,
      altReceiverNumber: altReceiverNumber,
      receiverAddress: '',
      deliveryCharge: deliveryCharge,
      codCharge: codCharge,
      lastDeliveryStatus: 'Delivered',
      source: '',
      destination: destination,
      desc: '',
    );
  }
}

extension PossibleRedirectOrderEntityAdapter on PossibleRedirectOrderEntity {
  OrderEntity toOrderEntity() {
    final parsedId = int.tryParse(orderId) ?? 0;
    return OrderEntity(
      orderId: parsedId,
      orderIdWithStatus: '$orderId Possible Redirect',
      deliveredDate: createdOn,
      receiverName: receiver,
      receiverNumber: '',
      receiverAddress: '',
      deliveryCharge: deliveryCharge,
      codCharge: codCharge,
      lastDeliveryStatus: 'Possible Redirect',
      source: '',
      destination: destination,
      desc: '',
    );
  }
}

extension ReturnedOrderEntityAdapter on ReturnedOrderEntity {
  OrderEntity toOrderEntity() {
    final parsedId = int.tryParse(orderId) ?? 0;
    return OrderEntity(
      orderId: parsedId,
      orderIdWithStatus: '$orderId Returned',
      deliveredDate: '',
      receiverName: customerName,
      receiverNumber: customerNumber,
      receiverAddress: receiverAddress,
      deliveryCharge: '0',
      codCharge: codCharge,
      lastDeliveryStatus: 'Returned',
      source: source,
      destination: destination,
      desc: '',
    );
  }
}

extension RtvOrderEntityAdapter on RtvOrderEntity {
  OrderEntity toOrderEntity() {
    return OrderEntity(
      orderId: id,
      orderIdWithStatus: '$orderId RTV',
      deliveredDate: rtvDate,
      receiverName: receiver,
      receiverNumber: receiverNumber,
      receiverAddress: '',
      deliveryCharge: '0',
      codCharge: '0',
      lastDeliveryStatus: 'RTV',
      source: '',
      destination: destinationBranch,
      desc: '',
    );
  }
}

extension StaleOrdersEntityAdapter on StaleOrdersEntity {
  OrderEntity toOrderEntity() {
    return OrderEntity(
      orderId: orderId,
      orderIdWithStatus: orderIdWithStatus,
      deliveredDate: createdOnFormatted,
      receiverName: receiverName,
      receiverNumber: receiverPhone,
      altReceiverNumber: receiverAltPhone,
      receiverAddress: receiverAddress,
      deliveryCharge: '0',
      codCharge: codCharge,
      lastDeliveryStatus: lastDeliveryStatus,
      source: sourceBranch,
      destination: destinationBranch,
      desc: orderDescription,
    );
  }
}

extension RedirectedOrderItemAdapter on RedirectedOrderItem {
  OrderEntity toOrderEntity() {
    return OrderEntity(
      orderId: childOrderId,
      orderIdWithStatus: '$parentOrderId → $childOrderId',
      deliveredDate: _formatDate(createdOn),
      receiverName: vendorName,
      receiverNumber: '',
      receiverAddress: '',
      deliveryCharge: '0',
      codCharge: '0',
      lastDeliveryStatus: childOrderStatus,
      source: parentOrderId,
      destination: '',
      desc: '',
    );
  }
}

extension TodayRedirectOrderAdapter on TodayRedirectOrder {
  OrderEntity toOrderEntity() {
    return OrderEntity(
      orderId: childOrderId,
      orderIdWithStatus: '$parentOrderId → $childOrderId',
      deliveredDate: _formatDate(createdOn),
      receiverName: '',
      receiverNumber: '',
      receiverAddress: '',
      deliveryCharge: childDeliveryCharge.toStringAsFixed(0),
      codCharge: childCodCharge.toStringAsFixed(0),
      lastDeliveryStatus: childOrderStatus,
      source: parentOrderId,
      destination: '',
      desc: '',
    );
  }
}
