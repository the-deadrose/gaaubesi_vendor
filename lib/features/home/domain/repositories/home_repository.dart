import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/home/domain/entities/vendor_stats_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, VendorStatsEntity>> getVendorStats();
}
