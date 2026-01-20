import 'package:equatable/equatable.dart';


abstract class CalculateDeliveryChargeEvent extends Equatable {
  const CalculateDeliveryChargeEvent();

  @override
  List<Object?> get props => [];
}

class CalculateDeliveryChargeRequested extends CalculateDeliveryChargeEvent {
  final String sourceBranchId;
  final String destinationBranchId;
  final String weight;

  const CalculateDeliveryChargeRequested({
    required this.sourceBranchId,
    required this.destinationBranchId,
    required this.weight,
  });

  @override
  List<Object?> get props => [sourceBranchId, destinationBranchId , weight];
}
