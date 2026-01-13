import 'package:gaaubesi_vendor/features/orders/domain/entities/create_order_request_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_order_request_model.g.dart';

@JsonSerializable()
class CreateOrderRequestModel extends CreateOrderRequestEntity {
  const CreateOrderRequestModel({
    required super.branch,
    required super.destinationBranch,
    required super.receiverName,
    required super.receiverPhoneNumber,
    super.altReceiverPhoneNumber,
    required super.receiverFullAddress,
    required super.weight,
    required super.codCharge,
    required super.packageAccess,
    super.referenceId,
    super.pickupPoint,
    required super.pickupType,
    required super.packageType,
    super.remarks,
  });

  @JsonKey(name: 'branch')
  @override
  String get branch => super.branch;

  @JsonKey(name: 'destination_branch')
  @override
  String get destinationBranch => super.destinationBranch;

  @JsonKey(name: 'receiver_name')
  @override
  String get receiverName => super.receiverName;

  @JsonKey(name: 'receiver_phone_number')
  @override
  String get receiverPhoneNumber => super.receiverPhoneNumber;

  @JsonKey(name: 'alt_receiver_phone_number')
  @override
  String? get altReceiverPhoneNumber => super.altReceiverPhoneNumber;

  @JsonKey(name: 'receiver_full_address')
  @override
  String get receiverFullAddress => super.receiverFullAddress;

  @JsonKey(name: 'weight')
  @override
  double get weight => super.weight;


  @JsonKey(name: 'cod_charge')
  @override
  double get codCharge => super.codCharge;

  @JsonKey(name: 'package_access')
  @override
  String get packageAccess => super.packageAccess;

  @JsonKey(name: 'reference_id')
  @override
  String? get referenceId => super.referenceId;

  @JsonKey(name: 'pickup_point')
  @override
  String? get pickupPoint => super.pickupPoint;

  @JsonKey(name: 'pickup_type')
  @override
  String get pickupType => super.pickupType;

  @JsonKey(name: 'package_type')
  @override
  String get packageType => super.packageType;

  @JsonKey(name: 'remarks')
  @override
  String? get remarks => super.remarks;

  factory CreateOrderRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrderRequestModelToJson(this);
}
