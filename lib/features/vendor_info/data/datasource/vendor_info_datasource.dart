import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/vendor_info/data/model/vendor_info_model.dart';
import 'package:gaaubesi_vendor/features/vendor_info/domain/entity/vendor_info_entity.dart';
import 'package:injectable/injectable.dart';

abstract class VendorInfoRemoteDatasource {
  Future<VendorInfoEntity> getVendorInfo();
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
}
