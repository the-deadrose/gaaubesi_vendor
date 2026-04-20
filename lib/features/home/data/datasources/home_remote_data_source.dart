import 'package:injectable/injectable.dart';

import 'package:gaaubesi_vendor/configure/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/data/remote_call.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/home/data/models/vendor_stats_model.dart';

abstract class HomeRemoteDataSource {
  Future<VendorStatsModel> getVendorStats();
}

@LazySingleton(as: HomeRemoteDataSource)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient _dioClient;

  HomeRemoteDataSourceImpl(this._dioClient);

  @override
  Future<VendorStatsModel> getVendorStats() {
    return remoteCall(
      () => _dioClient.get(ApiEndpoints.vendorStats),
      (response) {
        if (response.statusCode != 200) {
          throw ServerException(
            'Failed to fetch vendor stats',
            statusCode: response.statusCode,
          );
        }
        return VendorStatsModel.fromJson(response.data);
      },
    );
  }
}
