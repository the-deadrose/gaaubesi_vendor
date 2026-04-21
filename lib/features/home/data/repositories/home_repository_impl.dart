import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import 'package:gaaubesi_vendor/core/data/failure_mapper.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/home/data/datasources/home_remote_data_source.dart';
import 'package:gaaubesi_vendor/features/home/domain/entities/vendor_stats_entity.dart';
import 'package:gaaubesi_vendor/features/home/domain/repositories/home_repository.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, VendorStatsEntity>> getVendorStats() async {
    try {
      final stats = await _remoteDataSource.getVendorStats();
      return Right(stats);
    } catch (e) {
      return Left(toFailure(e));
    }
  }
}
