import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/app/home/data/datasources/home_remote_data_source.dart';
import 'package:gaaubesi_vendor/app/home/domain/entities/vendor_stats_entity.dart';
import 'package:gaaubesi_vendor/app/home/domain/repositories/home_repository.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, VendorStatsEntity>> getVendorStats() async {
    try {
      final stats = await _remoteDataSource.getVendorStats();
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
