import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/data/model/extra_mileage_list_model.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/domain/entity/extra_mileage_list_entity.dart';
import 'package:injectable/injectable.dart';

abstract class ExtraMileageRemoteDatasource {
  Future<ExtraMileageResponseListEntity> fetchExtraMileageList(
    String page,
    String status,
    String startDate,
    String endDate,
  );

  Future<Either<Failure, void>> approveExtraMileage(String mileageId);
  Future<Either<Failure, void>> rejectExtraMileage(String mileageId);
}

@LazySingleton(as: ExtraMileageRemoteDatasource)
class ExtraMileageRemoteDatasourceImpl implements ExtraMileageRemoteDatasource {
  final DioClient _dioClient;

  ExtraMileageRemoteDatasourceImpl(this._dioClient);

  @override
  Future<ExtraMileageResponseListEntity> fetchExtraMileageList(
    String page,
    String status,
    String startDate,
    String endDate,
  ) async {
    try {
      final hasParams =
          page.isNotEmpty ||
          status.isNotEmpty ||
          startDate.isNotEmpty ||
          endDate.isNotEmpty;

      dynamic response;
      if (hasParams) {
        final queryParameters = <String, dynamic>{};
        if (page.isNotEmpty) queryParameters['page'] = page;
        if (status.isNotEmpty) queryParameters['status'] = status;
        if (startDate.isNotEmpty) queryParameters['start_date'] = startDate;
        if (endDate.isNotEmpty) queryParameters['end_date'] = endDate;

        response = await _dioClient.get(
          ApiEndpoints.extraMileageList,
          queryParameters: queryParameters,
        );
      } else {
        response = await _dioClient.get(ApiEndpoints.extraMileageList);
      }

      return ExtraMileageResponseListModel.fromJson(response.data).toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, void>> approveExtraMileage(String mileageId) async {
    try {
      await _dioClient.post('${ApiEndpoints.approveExtraMileage}/$mileageId');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectExtraMileage(String mileageId) async {
    try {
      await _dioClient.post('${ApiEndpoints.declineExtraMileage}/$mileageId');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
