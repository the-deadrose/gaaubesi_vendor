import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/daily_transections/data/model/daily_transections_model.dart';
import 'package:gaaubesi_vendor/features/daily_transections/domain/entity/daily_transections_entity.dart';
import 'package:injectable/injectable.dart';

abstract class DailyTransectionRemoteDatasource {
  Future<DailyTransections> fetchDailyTransections({
    required String date,
  });
}

@LazySingleton(as: DailyTransectionRemoteDatasource)

class DailyTransectionDatasourceImpl implements DailyTransectionRemoteDatasource {
  final DioClient _dioClient;

  DailyTransectionDatasourceImpl(this._dioClient);

  @override
  Future<DailyTransections> fetchDailyTransections({
    required String date,
  }) async {
    try {
      final queryParameters = {
        'date': date,
      };
      final response = await _dioClient.get(
         ApiEndpoints.dailyTransections,
        queryParameters: queryParameters,
      );
      return DailyTransectionsModel.fromJson(response.data).toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
