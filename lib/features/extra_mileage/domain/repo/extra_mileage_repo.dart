import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/domain/entity/extra_mileage_list_entity.dart';

abstract class ExtraMileageRepo {
  Future<Either<Failure, ExtraMileageResponseListEntity>> fetchExtraMileageList(
    String page,
    String status,
    String startDate,
    String endDate,
  );
}
