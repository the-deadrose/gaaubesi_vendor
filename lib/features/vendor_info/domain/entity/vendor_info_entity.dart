import 'package:equatable/equatable.dart';

class VendorLocationEntity extends Equatable {
  final String type;
  final List<double> coordinates;

  const VendorLocationEntity({
    required this.type,
    required this.coordinates,
  });

  @override
  List<Object?> get props => [type, coordinates];

  @override
  bool get stringify => true;
}

class VendorInfoEntity extends Equatable {
  final int id;
  final String fullName;
  final String? profilePicture;
  final String email;
  final String phoneNumber;
  final String address;
  final String primaryBranch;
  final String? website;
  final VendorLocationEntity vendorLocation;

  const VendorInfoEntity({
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

  VendorInfoEntity copyWith({
    int? id,
    String? fullName,
    String? profilePicture,
    String? email,
    String? phoneNumber,
    String? address,
    String? primaryBranch,
    String? website,
    VendorLocationEntity? vendorLocation,
  }) {
    return VendorInfoEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      profilePicture: profilePicture ?? this.profilePicture,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      primaryBranch: primaryBranch ?? this.primaryBranch,
      website: website ?? this.website,
      vendorLocation: vendorLocation ?? this.vendorLocation,
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