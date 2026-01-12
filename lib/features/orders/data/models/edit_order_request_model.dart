import 'package:gaaubesi_vendor/features/orders/domain/entities/edit_order_request_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'edit_order_request_model.g.dart';

@JsonSerializable()
class EditOrderRequestModel extends OrderEditEntity {
  const EditOrderRequestModel({
    required super.branch,
    required super.destinationBranch,
    required super.weight,
    required super.codCharge,
    required super.packageAccess,
    required super.packageType,
    required super.remarks,
    required super.receiverName,
    required super.receiverPhoneNumber,
    required super.pickupType,
    required super.altReceiverPhoneNumber,
    required super.receiverFullAddress,
  });

  @JsonKey(name: 'branch')
  @override
  int get branch => super.branch;

  @JsonKey(name: 'destination_branch')
  @override
  int get destinationBranch => super.destinationBranch;

  @JsonKey(name: 'weight')
  @override
  double get weight => super.weight;

  @JsonKey(name: 'cod_charge')
  @override
  int get codCharge => super.codCharge;

  @JsonKey(name: 'package_access')
  @override
  String get packageAccess => super.packageAccess;

  @JsonKey(name: 'package_type')
  @override
  String get packageType => super.packageType;

  @JsonKey(name: 'remarks')
  @override
  String get remarks => super.remarks;

  @JsonKey(name: 'receiver_name')
  @override
  String get receiverName => super.receiverName;

  @JsonKey(name: 'receiver_phone_number')
  @override
  String get receiverPhoneNumber => super.receiverPhoneNumber;

  @JsonKey(name: 'pickup_type')
  @override
  String get pickupType => super.pickupType;

  @JsonKey(name: 'alt_receiver_phone_number')
  @override
  String get altReceiverPhoneNumber => super.altReceiverPhoneNumber;

  @JsonKey(name: 'receiver_full_address')
  @override
  String get receiverFullAddress => super.receiverFullAddress;

  factory EditOrderRequestModel.fromJson(Map<String, dynamic> json) =>
      _$EditOrderRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$EditOrderRequestModelToJson(this);
}
