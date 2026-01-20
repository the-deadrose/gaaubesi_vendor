import 'package:equatable/equatable.dart';

class RedirectedOrders extends Equatable {
  final int count;
  final String next;
  final String previous;
  final List<RedirectedOrderItem> results;

  const RedirectedOrders({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  @override
  List<Object?> get props => [
        count,
        next,
        previous,
        results,
      ];
}

class RedirectedOrderItem extends Equatable {
  final String parentOrderId;
  final int childOrderId;
  final String childOrderStatus;
  final String vendorName;
  final DateTime createdOn;

  const RedirectedOrderItem({
    required this.parentOrderId,
    required this.childOrderId,
    required this.childOrderStatus,
    required this.vendorName,
    required this.createdOn,
  });

  @override
  List<Object?> get props => [
        parentOrderId,
        childOrderId,
        childOrderStatus,
        vendorName,
        createdOn,
      ];
}
