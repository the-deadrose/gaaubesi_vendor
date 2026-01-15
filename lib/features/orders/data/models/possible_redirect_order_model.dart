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
  @JsonKey(name: 'order_id', fromJson: _stringFromJson, defaultValue: '')
  String get orderId => super.orderId;

  @override
  @JsonKey(name: 'cod_charge', fromJson: _stringFromJson, defaultValue: '')
  String get codCharge => super.codCharge;

  @override
  @JsonKey(name: 'destination', fromJson: _stringFromJson, defaultValue: '')
  String get destination => super.destination;

  @override
  @JsonKey(name: 'create_date_formatted', fromJson: _stringFromJson, defaultValue: '')
  String get createdOn => super.createdOn;

  @override
  @JsonKey(name: 'receiver_name', fromJson: _stringFromJson, defaultValue: '')
  String get receiver => super.receiver;

  @override
  @JsonKey(name: 'delivery_charge', fromJson: _stringFromJson, defaultValue: '')
  String get deliveryCharge => super.deliveryCharge;

  // Helper function to handle null values
  static String _stringFromJson(dynamic jsonValue) {
    if (jsonValue == null) return '';
    return jsonValue.toString();
  }

  factory PossibleRedirectOrderModel.fromJson(Map<String, dynamic> json) =>
      _$PossibleRedirectOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$PossibleRedirectOrderModelToJson(this);
}
