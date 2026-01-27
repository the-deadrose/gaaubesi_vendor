import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/vendor_info/data/model/vendor_info_model.dart';
import 'package:gaaubesi_vendor/features/vendor_info/domain/entity/vendor_info_entity.dart';
import 'package:injectable/injectable.dart';

abstract class VendorInfoRemoteDatasource {
  Future<VendorInfoEntity> getVendorInfo();
  Future<void> updateVendorInfo({
    required String address,
    required int? nearestPickupPoint,
    required double? latitude,
    required double? longitude,
    required String? profilePicture,
  });
}

@LazySingleton(as: VendorInfoRemoteDatasource)
class VendorInfoDatasourceImpl implements VendorInfoRemoteDatasource {
  final DioClient _dioClient;
  VendorInfoDatasourceImpl(this._dioClient);

  @override
  Future<VendorInfoEntity> getVendorInfo() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.vendorInfo);
      final dynamic responseData = response.data;
      final Map<String, dynamic> jsonData;

      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          jsonData = responseData['data'] as Map<String, dynamic>;
        } else {
          jsonData = responseData;
        }
      } else {
        throw Exception(
          'Unexpected response format: ${responseData.runtimeType}',
        );
      }

      final model = VendorInfoModel.fromJson(jsonData);
      return model.toEntity();
    } catch (e) {
      throw Exception('Error fetching vendor info: $e');
    }
  }

  @override
  Future<void> updateVendorInfo({
    required String address,
    required int? nearestPickupPoint,
    required double? latitude,
    required double? longitude,
    required String? profilePicture,
  }) async {
    try {
      final Map<String, dynamic> body = {"address": address};

      if (nearestPickupPoint != null) {
        body["nearest_pickup_point"] = nearestPickupPoint;
      }

      if (latitude != null && longitude != null) {
        body["vendor_location"] = {
          "type": "Point",
          "coordinates": [longitude, latitude],
        };
      }

      if (profilePicture != null && profilePicture.isNotEmpty) {
        body["profile_picture"] = profilePicture;
      }

      await _dioClient.patch(ApiEndpoints.editProfile, data: body);
    } catch (e) {
      throw Exception('Error updating vendor info: $e');
    }
  }
}
