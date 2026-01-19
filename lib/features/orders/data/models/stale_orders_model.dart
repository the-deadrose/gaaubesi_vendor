// ignore_for_file: non_constant_identifier_names

import 'package:gaaubesi_vendor/features/orders/domain/entities/stale_orders_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stale_orders_model.g.dart';

@JsonSerializable()
class StaleOrdersListModel {
  final int order_id;
  final String order_id_with_status;
  final String? created_on;
  final String? created_on_formatted;
  final String? receiver_name;
  final String? receiver_phone;
  final String? receiver_alt_phone;
  final String? receiver_address;
  final String? source_branch;
  final String? destination_branch;
  final String? cod_charge;
  final String? last_delivery_status;
  final String? order_description;
  final bool? hold;
  final bool? vendor_return;
  final bool? is_exchange_order;
  final bool? is_refund_order;

  StaleOrdersListModel({
    required this.order_id,
    required this.order_id_with_status,
    this.created_on,
    this.created_on_formatted,
    this.receiver_name,
    this.receiver_phone,
    this.receiver_alt_phone,
    this.receiver_address,
    this.source_branch,
    this.destination_branch,
    this.cod_charge,
    this.last_delivery_status,
    this.order_description,
    this.hold,
    this.vendor_return,
    this.is_exchange_order,
    this.is_refund_order,
  });

  /// JSON serialization
  factory StaleOrdersListModel.fromJson(Map<String, dynamic> json) =>
      _$StaleOrdersListModelFromJson(json);

  Map<String, dynamic> toJson() => _$StaleOrdersListModelToJson(this);

  /// Convert model to entity
  StaleOrdersEntity toEntity() {
    return StaleOrdersEntity(
      orderId: order_id,
      orderIdWithStatus: order_id_with_status,
      createdOn: created_on != null ? DateTime.parse(created_on!) : DateTime.now(),
      createdOnFormatted: created_on_formatted ?? '',
      receiverName: receiver_name ?? '',
      receiverPhone: receiver_phone ?? '',
      receiverAltPhone: receiver_alt_phone ?? '',
      receiverAddress: receiver_address ?? '',
      sourceBranch: source_branch ?? '',
      destinationBranch: destination_branch ?? '',
      codCharge: cod_charge ?? '0.00',
      lastDeliveryStatus: last_delivery_status ?? '',
      orderDescription: order_description ?? '',
      hold: hold ?? false,
      vendorReturn: vendor_return ?? false,
      isExchangeOrder: is_exchange_order ?? false,
      isRefundOrder: is_refund_order ?? false,
    );
  }
}
