import 'package:gaaubesi_vendor/features/orders/domain/entities/rtv_order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rtv_order_model.g.dart';

@JsonSerializable()
class RtvOrderModel extends RtvOrderEntity {
  const RtvOrderModel({
    required super.orderId,
    required super.destinationBranch,
    required super.receiver,
    required super.receiverNumber,
    required super.rtvDate,
  });

  @override
  @JsonKey(name: 'order_id')
  String get orderId => super.orderId;

  @override
  @JsonKey(name: 'destination_branch')
  String get destinationBranch => super.destinationBranch;

  @override
  String get receiver => super.receiver;

  @override
  @JsonKey(name: 'receiver_number')
  String get receiverNumber => super.receiverNumber;

  @override
  @JsonKey(name: 'rtv_date')
  String get rtvDate => super.rtvDate;

  factory RtvOrderModel.fromJson(Map<String, dynamic> json) =>
      _$RtvOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$RtvOrderModelToJson(this);
}
