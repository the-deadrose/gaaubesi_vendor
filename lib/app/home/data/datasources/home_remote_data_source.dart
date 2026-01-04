import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/app/home/data/models/vendor_stats_model.dart';

abstract class HomeRemoteDataSource {
  Future<VendorStatsModel> getVendorStats();
}

@LazySingleton(as: HomeRemoteDataSource)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient _dioClient;

  HomeRemoteDataSourceImpl(this._dioClient);

  @override
  Future<VendorStatsModel> getVendorStats() async {
    try {
      final response = await _dioClient.get('/vendor/dashboard/stats/');

      if (response.statusCode == 200) {
        return VendorStatsModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to fetch vendor stats');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Unknown error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
