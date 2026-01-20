import 'package:equatable/equatable.dart';

class CalculateDeliveryCharge extends Equatable {
  final bool? success;
  final String? message;
  final String? deliveryCharge;
  final String? originalCharge;
  final String? discountedCharge;
  final bool? hasDiscount;

  const CalculateDeliveryCharge({
    this.success,
    this.message,
    this.deliveryCharge,
    this.originalCharge,
    this.discountedCharge,
    this.hasDiscount,
  });

  @override
  List<Object?> get props => [
        success,
        message,
        deliveryCharge,
        originalCharge,
        discountedCharge,
        hasDiscount,
      ];
}
