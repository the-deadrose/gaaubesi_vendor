import 'package:equatable/equatable.dart';

class OrderStatusEntity extends Equatable {
  final String value; // Branch ID as string
  final String label; // Display name
  final String code; // Branch code (e.g., "RTPL", "ATRY")

  const OrderStatusEntity({
    required this.value,
    required this.label,
    required this.code,
  });

  @override
  List<Object?> get props => [value, label, code];
}
