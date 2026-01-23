import 'package:json_annotation/json_annotation.dart';
import '../../domain/entity/customer_detail_entity.dart';

part 'customer_detail_model.g.dart';

/// ===============================
/// Customer Detail Model
/// ===============================
@JsonSerializable(explicitToJson: true)
class CustomerDetailModel {
  @JsonKey(defaultValue: 0)
  final int id;

  @JsonKey(defaultValue: '')
  final String name;

  @JsonKey(name: 'phone_number', defaultValue: '')
  final String phoneNumber;

  @JsonKey(defaultValue: '')
  final String email;

  @JsonKey(defaultValue: '')
  final String address;

  @JsonKey(defaultValue: [])
  final List<CustomerOrderModel> orders;

  const CustomerDetailModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.orders,
  });

  factory CustomerDetailModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerDetailModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CustomerDetailModelToJson(this);

  /// 🔁 Model → Entity
  CustomerDetailEntity toEntity() {
    return CustomerDetailEntity(
      id: id,
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      address: address,
      orders: orders.map((e) => e.toEntity()).toList(),
    );
  }
}

/// ===============================
/// Customer Order Model
/// ===============================
@JsonSerializable()
class CustomerOrderModel {
  @JsonKey(name: 'order_id', defaultValue: 0)
  final int orderId;

  @JsonKey(name: 'last_delivery_status', defaultValue: '')
  final String lastDeliveryStatus;

  @JsonKey(defaultValue: '')
  final String branch;

  @JsonKey(defaultValue: '')
  final String destination;

  @JsonKey(name: 'created_on', defaultValue: '')
  final String createdOn;

  const CustomerOrderModel({
    required this.orderId,
    required this.lastDeliveryStatus,
    required this.branch,
    required this.destination,
    required this.createdOn,
  });

  factory CustomerOrderModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerOrderModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CustomerOrderModelToJson(this);

  /// 🔁 Model → Entity
  CustomerOrderEntity toEntity() {
    return CustomerOrderEntity(
      orderId: orderId,
      lastDeliveryStatus: lastDeliveryStatus,
      branch: branch,
      destination: destination,
      createdOn: createdOn,
    );
  }
}
