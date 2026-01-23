import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/vendor_info/domain/entity/vendor_info_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vendor_info_model.g.dart';

@JsonSerializable()
class VendorLocationModel extends Equatable {
  @JsonKey(name: 'type')
  final String type;
  
  @JsonKey(name: 'coordinates')
  final List<double> coordinates;

  const VendorLocationModel({
    required this.type,
    required this.coordinates,
  });

  factory VendorLocationModel.fromJson(Map<String, dynamic> json) =>
      _$VendorLocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$VendorLocationModelToJson(this);

  VendorLocationEntity toEntity() {
    return VendorLocationEntity(
      type: type,
      coordinates: coordinates,
    );
  }

  @override
  List<Object?> get props => [type, coordinates];

  @override
  bool get stringify => true;
}

@JsonSerializable()
class VendorInfoModel extends Equatable {
  @JsonKey(name: 'id')
  final int id;
  
  @JsonKey(name: 'full_name')
  final String fullName;
  
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  
  @JsonKey(name: 'email')
  final String email;
  
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  
  @JsonKey(name: 'address')
  final String address;
  
  @JsonKey(name: 'primary_branch')
  final String primaryBranch;
  
  @JsonKey(name: 'website')
  final String? website;
  
  @JsonKey(name: 'vendor_location')
  final VendorLocationModel vendorLocation;

  const VendorInfoModel({
    required this.id,
    required this.fullName,
    this.profilePicture,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.primaryBranch,
    this.website,
    required this.vendorLocation,
  });

  factory VendorInfoModel.fromJson(Map<String, dynamic> json) =>
      _$VendorInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$VendorInfoModelToJson(this);

  VendorInfoEntity toEntity() {
    return VendorInfoEntity(
      id: id,
      fullName: fullName,
      profilePicture: profilePicture,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      primaryBranch: primaryBranch,
      website: website,
      vendorLocation: vendorLocation.toEntity(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    profilePicture,
    email,
    phoneNumber,
    address,
    primaryBranch,
    website,
    vendorLocation,
  ];

  @override
  bool get stringify => true;
}