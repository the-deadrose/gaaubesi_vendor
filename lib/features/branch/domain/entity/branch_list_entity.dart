import 'package:equatable/equatable.dart';

class OrderStatusEntity extends Equatable {
  final String value;
  final String label;

  const OrderStatusEntity({
    required this.value,
    required this.label,
  });

  @override
  List<Object?> get props => [value, label];
}
