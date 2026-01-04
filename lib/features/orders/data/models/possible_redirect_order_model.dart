import 'package:gaaubesi_vendor/features/orders/domain/entities/possible_redirect_order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'possible_redirect_order_model.g.dart';

@JsonSerializable()
class PossibleRedirectOrderModel extends PossibleRedirectOrderEntity {
  const PossibleRedirectOrderModel({
    required super.orderId,
    required super.codCharge,
    required super.destination,
    required super.createdOn,
    required super.receiver,
    required super.deliveryCharge,
  });

  @override
  @JsonKey(name: 'order_id')
  String get orderId => super.orderId;

  @override
  @JsonKey(name: 'cod_charge')
  String get codCharge => super.codCharge;

  @override
  String get destination => super.destination;

  @override
  @JsonKey(name: 'created_on')
  String get createdOn => super.createdOn;

  @override
  String get receiver => super.receiver;

  @override
  @JsonKey(name: 'delivery_charge')
  String get deliveryCharge => super.deliveryCharge;

  factory PossibleRedirectOrderModel.fromJson(Map<String, dynamic> json) =>
      _$PossibleRedirectOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$PossibleRedirectOrderModelToJson(this);
}
