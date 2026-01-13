import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/delivered_order_entity.dart';

part 'delivered_order_model.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class DeliveredOrderModel extends DeliveredOrderEntity {
  @JsonKey(name: 'order_id', defaultValue: 0)
  final int orderId;

  @JsonKey(name: 'reference_id', defaultValue: '')
  final String referenceId;

  @JsonKey(name: 'destination', defaultValue: '')
  final String destination;

  @JsonKey(name: 'receiver_name', defaultValue: '')
  final String receiverName;

  @JsonKey(name: 'receiver_number', defaultValue: '')
  final String receiverNumber;

  @JsonKey(name: 'alt_receiver_number', defaultValue: '')
  final String altReceiverNumber;

  @JsonKey(name: 'cod_charge', defaultValue: '0.00')
  final String codCharge;

  @JsonKey(name: 'delivery_charge', defaultValue: '0.00')
  final String deliveryCharge;

  @JsonKey(name: 'delivered_date')
  final DateTime? deliveredDate;

  @JsonKey(name: 'delivered_date_formatted', defaultValue: '')
  final String deliveredDateFormatted;

  const DeliveredOrderModel({
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
  }) : super(
          orderId: orderId,
          referenceId: referenceId,
          destination: destination,
          receiverName: receiverName,
          receiverNumber: receiverNumber,
          altReceiverNumber: altReceiverNumber,
          codCharge: codCharge,
          deliveryCharge: deliveryCharge,
          deliveredDate: deliveredDate,
          deliveredDateFormatted: deliveredDateFormatted,
        );

  /// JSON Serialization
  factory DeliveredOrderModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveredOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveredOrderModelToJson(this);

  /// Model → Entity
  DeliveredOrderEntity toEntity() => DeliveredOrderEntity(
        orderId: orderId,
        referenceId: referenceId,
        destination: destination,
        receiverName: receiverName,
        receiverNumber: receiverNumber,
        altReceiverNumber: altReceiverNumber,
        codCharge: codCharge,
        deliveryCharge: deliveryCharge,
        deliveredDate: deliveredDate,
        deliveredDateFormatted: deliveredDateFormatted,
      );

  /// Entity → Model
  factory DeliveredOrderModel.fromEntity(DeliveredOrderEntity entity) =>
      DeliveredOrderModel(
        orderId: entity.orderId,
        referenceId: entity.referenceId,
        destination: entity.destination,
        receiverName: entity.receiverName,
        receiverNumber: entity.receiverNumber,
        altReceiverNumber: entity.altReceiverNumber,
        codCharge: entity.codCharge,
        deliveryCharge: entity.deliveryCharge,
        deliveredDate: entity.deliveredDate,
        deliveredDateFormatted: entity.deliveredDateFormatted,
      );

  /// Empty model factory
  factory DeliveredOrderModel.empty() => const DeliveredOrderModel(
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

  /// Check if model is empty
  bool get isEmpty => this == DeliveredOrderModel.empty();

  /// Check if model is not empty
  bool get isNotEmpty => !isEmpty;

  @override
  String toString() {
    return 'DeliveredOrderModel(orderId: $orderId, referenceId: $referenceId, destination: $destination)';
  }
}