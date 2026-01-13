import 'package:equatable/equatable.dart';

class DeliveredOrderEntity extends Equatable {
  final int orderId;
  final String referenceId;
  final String destination;
  final String receiverName;
  final String receiverNumber;
  final String altReceiverNumber;
  final String codCharge;
  final String deliveryCharge;
  final DateTime? deliveredDate;
  final String deliveredDateFormatted;

  const DeliveredOrderEntity({
    required this.orderId,
    required this.referenceId,
    required this.destination,
    required this.receiverName,
    required this.receiverNumber,
    required this.altReceiverNumber,
    required this.codCharge,
    required this.deliveryCharge,
    required this.deliveredDate,
    required this.deliveredDateFormatted,
  });

  /// Copy with method for immutability
  DeliveredOrderEntity copyWith({
    int? orderId,
    String? referenceId,
    String? destination,
    String? receiverName,
    String? receiverNumber,
    String? altReceiverNumber,
    String? codCharge,
    String? deliveryCharge,
    DateTime? deliveredDate,
    String? deliveredDateFormatted,
  }) {
    return DeliveredOrderEntity(
      orderId: orderId ?? this.orderId,
      referenceId: referenceId ?? this.referenceId,
      destination: destination ?? this.destination,
      receiverName: receiverName ?? this.receiverName,
      receiverNumber: receiverNumber ?? this.receiverNumber,
      altReceiverNumber: altReceiverNumber ?? this.altReceiverNumber,
      codCharge: codCharge ?? this.codCharge,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      deliveredDate: deliveredDate ?? this.deliveredDate,
      deliveredDateFormatted: deliveredDateFormatted ?? this.deliveredDateFormatted,
    );
  }

  /// Empty entity factory
  factory DeliveredOrderEntity.empty() => const DeliveredOrderEntity(
        orderId: 0,
        referenceId: '',
        destination: '',
        receiverName: '',
        receiverNumber: '',
        altReceiverNumber: '',
        codCharge: '0.00',
        deliveryCharge: '0.00',
        deliveredDate: null,
        deliveredDateFormatted: '',
      );

  /// Check if entity is empty
  bool get isEmpty => this == DeliveredOrderEntity.empty();

  /// Check if entity is not empty
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [
        orderId,
        referenceId,
        destination,
        receiverName,
        receiverNumber,
        altReceiverNumber,
        codCharge,
        deliveryCharge,
        deliveredDate,
        deliveredDateFormatted,
      ];
}