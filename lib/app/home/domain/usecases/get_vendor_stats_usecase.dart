import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/app/home/domain/entities/vendor_stats_entity.dart';
import 'package:gaaubesi_vendor/app/home/domain/repositories/home_repository.dart';

@lazySingleton
class GetVendorStatsUseCase implements UseCase<VendorStatsEntity, NoParams> {
  final HomeRepository _repository;

  GetVendorStatsUseCase(this._repository);

  @override
  Future<Either<Failure, VendorStatsEntity>> call(NoParams params) async {
    return await _repository.getVendorStats();
  }
}
