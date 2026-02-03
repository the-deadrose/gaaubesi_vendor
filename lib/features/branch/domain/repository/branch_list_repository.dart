import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/pickup_point_entity.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/redirect_station_list_entity.dart';

abstract class BranchListRepository {
  Future<Either<Failure, List<OrderStatusEntity>>> getBranchList(String branch);
  Future<Either<Failure, List<PickupPointEntity>>> getPickupPoints();
  Future<Either<Failure, RedirectStationListEntity>> getRedirectStations({
    required String page,
    String? searchQuery,
  });
}
