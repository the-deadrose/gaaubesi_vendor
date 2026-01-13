import 'package:equatable/equatable.dart';

class PickupPointEntity extends Equatable {
  final String value;
  final String label;
  const PickupPointEntity({required this.value, required this.label});

  @override
  List<Object?> get props => [value, label];
}
