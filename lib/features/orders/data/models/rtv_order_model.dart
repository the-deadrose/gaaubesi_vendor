import 'package:gaaubesi_vendor/features/orders/domain/entities/rtv_order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rtv_order_model.g.dart';

@JsonSerializable()
class RtvOrderModel extends RtvOrderEntity {
  const RtvOrderModel({
    required super.id,
    required super.orderId,
    required super.destinationBranch,
    required super.receiver,
    required super.receiverNumber,
    required super.rtvDate,
  });

  factory RtvOrderModel.create({
    int? id,
    String? orderId,
    String? destinationBranch,
    String? receiver,
    String? receiverNumber,
    String? rtvDate,
  }) {
    return RtvOrderModel(
      id: id ?? 0,
      orderId: orderId ?? '',
      destinationBranch: destinationBranch ?? '',
      receiver: receiver ?? '',
      receiverNumber: receiverNumber ?? '',
      rtvDate: rtvDate ?? '',
    );
  }

  @override
  @JsonKey(name: 'id', defaultValue:  0)
  int get id => super.id;

  @override
  @JsonKey(name: 'order_id', fromJson: _stringFromJson, defaultValue: '')
  String get orderId => super.orderId;

  @override
  @JsonKey(name: 'destination', fromJson: _stringFromJson, defaultValue: '')
  String get destinationBranch => super.destinationBranch;

  @override
  @JsonKey(name: 'receiver_name', fromJson: _stringFromJson, defaultValue: '')
  String get receiver => super.receiver;

  @override
  @JsonKey(name: 'receiver_number', fromJson: _stringFromJson, defaultValue: '')
  String get receiverNumber => super.receiverNumber;

  @override
  @JsonKey(name: 'created_date', fromJson: _stringFromJson, defaultValue: '')
  String get rtvDate => super.rtvDate;

  // Helper function to handle null values
  static String _stringFromJson(dynamic jsonValue) {
    if (jsonValue == null) return '';
    return jsonValue.toString();
  }

  factory RtvOrderModel.fromJson(Map<String, dynamic> json) =>
      _$RtvOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$RtvOrderModelToJson(this);
}