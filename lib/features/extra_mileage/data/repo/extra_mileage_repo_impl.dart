import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/data/datasource/extra_mileage_datasource.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/domain/entity/extra_mileage_list_entity.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/domain/repo/extra_mileage_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ExtraMileageRepo)
class ExtraMileageRepoImpl implements ExtraMileageRepo {
  final ExtraMileageRemoteDatasource _remoteDatasource;

  ExtraMileageRepoImpl(this._remoteDatasource);

  @override
  Future<Either<Failure, ExtraMileageResponseListEntity>> fetchExtraMileageList(
    String page,
    String status,
    String startDate,
    String endDate,
  ) async {
    try {
      final result = await _remoteDatasource.fetchExtraMileageList(
        page,
        status,
        startDate,
        endDate,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch extra mileage list'));
    }
  }
}
