
import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/domain/entity/calculate_deliver_charge_entity.dart';

abstract class CalculateDeliveryChargeState extends Equatable {
  const CalculateDeliveryChargeState();

  @override
  List<Object?> get props => [];
}

class CalculateDeliveryChargeInitial extends CalculateDeliveryChargeState {}

class CalculateDeliveryChargeLoading extends CalculateDeliveryChargeState {}

class CalculateDeliveryChargeLoaded extends CalculateDeliveryChargeState {
  final CalculateDeliveryCharge calculateDeliveryCharge;

  const CalculateDeliveryChargeLoaded({required this.calculateDeliveryCharge});

  @override
  List<Object?> get props => [calculateDeliveryCharge];
}

class CalculateDeliveryChargeError extends CalculateDeliveryChargeState {
  final String message;

  const CalculateDeliveryChargeError({required this.message});

  @override
  List<Object?> get props => [message];
}
