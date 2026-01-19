import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/daily_transections/domain/entity/daily_transections_entity.dart';

abstract class DailyTransectionRepo {
  Future<Either<Failure, List<DailyTransections>>> fetchDailyTransections({String date});
}