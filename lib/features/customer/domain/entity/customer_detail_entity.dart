import 'package:equatable/equatable.dart';

class CustomerDetailEntity extends Equatable {
  final int id;
  final String name;
  final String phoneNumber;
  final String email;
  final String address;
  final List<CustomerOrderEntity> orders;

  const CustomerDetailEntity({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.orders,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        email,
        address,
        orders,
      ];
}

class CustomerOrderEntity extends Equatable {
  final int orderId;
  final String lastDeliveryStatus;
  final String branch;
  final String destination;
  final String createdOn;

  const CustomerOrderEntity({
    required this.orderId,
    required this.lastDeliveryStatus,
    required this.branch,
    required this.destination,
    required this.createdOn,
  });

  @override
  List<Object?> get props => [
        orderId,
        lastDeliveryStatus,
        branch,
        destination,
        createdOn,
      ];
}
