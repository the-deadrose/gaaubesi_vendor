import 'package:json_annotation/json_annotation.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/order_detail_entity.dart';

part 'order_detail_model.g.dart';

@JsonSerializable()
class OrderDetailModel extends OrderDetailEntity {
  const OrderDetailModel({
    required super.orderId,
    required super.sourceBranch,
    required super.destinationBranch,
    required super.vendor,
    required super.codCharge,
    required super.deliveryCharge,
    required super.lastDeliveryStatus,
    required super.receiver,
    required super.receiverNumber,
    super.altReceiverNumber,
    required super.receiverAddress,
    required super.createdOn,
    required super.createdBy,
    required super.trackId,
    required super.packageAccess,
    super.orderDeliveryInstruction,
    required super.description,
    super.vendorReferenceId,
    required super.priority,
    super.orderContactName,
    super.orderContactNumber,
    required super.codPaid,
    required super.paymentCollection,
    required super.lastUpdated,
  });

  @override
  @JsonKey(name: 'order_id')
  int get orderId => super.orderId;

  @override
  @JsonKey(name: 'source_branch')
  String get sourceBranch => super.sourceBranch;

  @override
  @JsonKey(name: 'destination_branch')
  String get destinationBranch => super.destinationBranch;

  @override
  @JsonKey(name: 'vendor')
  String get vendor => super.vendor;

  @override
  @JsonKey(name: 'cod_charge')
  double get codCharge => super.codCharge;

  @override
  @JsonKey(name: 'delivery_charge')
  double get deliveryCharge => super.deliveryCharge;

  @override
  @JsonKey(name: 'last_delivery_status')
  String get lastDeliveryStatus => super.lastDeliveryStatus;

  @override
  @JsonKey(name: 'receiver')
  String get receiver => super.receiver;

  @override
  @JsonKey(name: 'receiver_number')
  String get receiverNumber => super.receiverNumber;

  @override
  @JsonKey(name: 'alt_receiver_number')
  String? get altReceiverNumber => super.altReceiverNumber;

  @override
  @JsonKey(name: 'receiver_address')
  String get receiverAddress => super.receiverAddress;

  @override
  @JsonKey(name: 'created_on')
  String get createdOn => super.createdOn;

  @override
  @JsonKey(name: 'created_by')
  String get createdBy => super.createdBy;

  @override
  @JsonKey(name: 'track_id')
  String get trackId => super.trackId;

  @override
  @JsonKey(name: 'package_access')
  String get packageAccess => super.packageAccess;

  @override
  @JsonKey(name: 'order_delivery_instruction')
  String? get orderDeliveryInstruction => super.orderDeliveryInstruction;

  @override
  @JsonKey(name: 'description')
  String get description => super.description;

  @override
  @JsonKey(name: 'vendor_reference_id')
  String? get vendorReferenceId => super.vendorReferenceId;

  @override
  @JsonKey(name: 'priority')
  String get priority => super.priority;

  @override
  @JsonKey(name: 'order_contact_name')
  String? get orderContactName => super.orderContactName;

  @override
  @JsonKey(name: 'order_contact_number')
  String? get orderContactNumber => super.orderContactNumber;

  @override
  @JsonKey(name: 'cod_paid')
  String get codPaid => super.codPaid;

  @override
  @JsonKey(name: 'payment_collection')
  String get paymentCollection => super.paymentCollection;

  @override
  @JsonKey(name: 'last_updated')
  String get lastUpdated => super.lastUpdated;

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDetailModelToJson(this);
}
