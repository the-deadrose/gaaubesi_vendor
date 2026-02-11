import 'package:json_annotation/json_annotation.dart';
import '../../domain/entity/today_detail_entity.dart';

part 'today_detail_model.g.dart';

@JsonSerializable()
class TodayDetailModel extends TodayDetailEntity {
  @JsonKey(name: 's_n')
  final int? sNModel;

  @JsonKey(name: 'order_id')
  final int? orderIdModel;

  @JsonKey(name: 'source_branch')
  final String? sourceBranchModel;

  @JsonKey(name: 'destination_branch')
  final String? destinationBranchModel;

  @JsonKey(name: 'receiver_name')
  final String? receiverNameModel;

  @JsonKey(name: 'receiver_address')
  final String? receiverAddressModel;

  @JsonKey(name: 'delivery_charge')
  final String? deliveryChargeModel;

  @JsonKey(name: 'cod', defaultValue: '0.00')
  final String cod;

  @JsonKey(name: 'created_at')
  final DateTime? createdAtModel;

  @JsonKey(name: 'last_delivery_status')
  final String? lastDeliveryStatusModel;

  TodayDetailModel({
    this.sNModel,
    this.orderIdModel,
    this.sourceBranchModel,
    this.destinationBranchModel,
    this.receiverNameModel,
    this.receiverAddressModel,
    this.deliveryChargeModel,
    this.cod = '0.00',
    this.createdAtModel,
    this.lastDeliveryStatusModel,
  }) : super(
          sN: sNModel ?? 0,
          orderId: orderIdModel ?? 0,
          sourceBranch: sourceBranchModel ?? '',
          destinationBranch: destinationBranchModel ?? '',
          receiverName: receiverNameModel ?? '',
          receiverAddress: receiverAddressModel ?? '',
          deliveryCharge: deliveryChargeModel ?? '0.00',
          cod: cod,
          createdAt: createdAtModel ?? DateTime.fromMillisecondsSinceEpoch(0),
          lastDeliveryStatus: lastDeliveryStatusModel ?? '',
        );

  factory TodayDetailModel.fromJson(Map<String, dynamic> json) =>
      _$TodayDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodayDetailModelToJson(this);

  TodayDetailEntity toEntity() {
    return TodayDetailEntity(
      sN: sN,
      orderId: orderId,
      sourceBranch: sourceBranch,
      destinationBranch: destinationBranch,
      receiverName: receiverName,
      receiverAddress: receiverAddress,
      deliveryCharge: deliveryCharge,
      cod: cod,
      createdAt: createdAt,
      lastDeliveryStatus: lastDeliveryStatus,
    );
  }
}
