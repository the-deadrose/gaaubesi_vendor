import 'package:equatable/equatable.dart';

abstract class VendorInfoEvent extends Equatable {
  const VendorInfoEvent();

  @override
  List<Object?> get props => [];
}

class FetchVendorInfoEvent extends VendorInfoEvent {
  const FetchVendorInfoEvent();

  @override
  List<Object?> get props => [];
}

class UpdateVendorInfoEvent extends VendorInfoEvent {
  final String address;
  final int? nearestPickupPoint;
  final double? latitude;
  final double? longitude;
  final String? profilePicture;

  const UpdateVendorInfoEvent({
    required this.address,
    this.nearestPickupPoint,
    this.latitude,
    this.longitude,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
    address,
    nearestPickupPoint,
    latitude,
    longitude,
    profilePicture,
  ];
}
