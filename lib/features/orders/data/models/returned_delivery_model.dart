import 'package:json_annotation/json_annotation.dart';
import 'package:gaaubesi_vendor/features/orders/data/models/returned_order_model.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/returned_delivery_entity.dart';

part 'returned_delivery_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ReturnedDeliveryModel extends ReturnedDeliveryEntity {
  @JsonKey(name: 'delivery_id', defaultValue: '')
  final String deliveryId;

  @JsonKey(name: 'date_sent', defaultValue: '')
  final String dateSent;

  @JsonKey(name: 'date_sent_formatted', defaultValue: '')
  final String dateSentFormatted;

  @JsonKey(name: 'orders_list', defaultValue: [])
  final List<ReturnedOrderModel> ordersList;

  @JsonKey(name: 'orders_count', defaultValue: 0)
  final int ordersCount;

  @JsonKey(name: 'print_url', defaultValue: '')
  final String printUrl;

  const ReturnedDeliveryModel({
    required this.deliveryId,
    required this.dateSent,
    required this.dateSentFormatted,
    required this.ordersList,
    required this.ordersCount,
    required this.printUrl,
  }) : super(
          deliveryId: deliveryId,
          dateSent: dateSent,
          dateSentFormatted: dateSentFormatted,
          ordersList: ordersList,
          ordersCount: ordersCount,
          printUrl: printUrl,
        );

  factory ReturnedDeliveryModel.fromJson(Map<String, dynamic> json) =>
      _$ReturnedDeliveryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReturnedDeliveryModelToJson(this);
}
