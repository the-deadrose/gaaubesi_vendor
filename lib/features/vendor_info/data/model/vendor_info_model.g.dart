// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VendorLocationModel _$VendorLocationModelFromJson(Map<String, dynamic> json) =>
    VendorLocationModel(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$VendorLocationModelToJson(
  VendorLocationModel instance,
) => <String, dynamic>{
  'type': instance.type,
  'coordinates': instance.coordinates,
};

VendorInfoModel _$VendorInfoModelFromJson(Map<String, dynamic> json) =>
    VendorInfoModel(
      id: (json['id'] as num).toInt(),
      fullName: json['full_name'] as String,
      profilePicture: json['profile_picture'] as String?,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      address: json['address'] as String,
      primaryBranch: json['primary_branch'] as String,
      website: json['website'] as String?,
      vendorLocation: VendorLocationModel.fromJson(
        json['vendor_location'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$VendorInfoModelToJson(VendorInfoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'profile_picture': instance.profilePicture,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'address': instance.address,
      'primary_branch': instance.primaryBranch,
      'website': instance.website,
      'vendor_location': instance.vendorLocation,
    };
