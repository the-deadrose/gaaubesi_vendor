import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/returned_order_entity.dart';

class ReturnedDeliveryEntity extends Equatable {
  final String deliveryId;
  final String dateSent;
  final String dateSentFormatted;
  final List<ReturnedOrderEntity> ordersList;
  final int ordersCount;
  final String printUrl;

  const ReturnedDeliveryEntity({
    required this.deliveryId,
    required this.dateSent,
    required this.dateSentFormatted,
    required this.ordersList,
    required this.ordersCount,
    required this.printUrl,
  });

  @override
  List<Object?> get props => [
        deliveryId,
        dateSent,
        dateSentFormatted,
        ordersList,
        ordersCount,
        printUrl,
      ];
}
