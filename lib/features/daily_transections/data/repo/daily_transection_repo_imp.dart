import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/daily_transections/data/datasource/daily_transection_datasource.dart';
import 'package:gaaubesi_vendor/features/daily_transections/domain/entity/daily_transections_entity.dart';
import 'package:gaaubesi_vendor/features/daily_transections/domain/repo/daily_transection_repo.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: DailyTransectionRepo)

class DailyTransectionRepoImp implements DailyTransectionRepo {
  final DailyTransectionRemoteDatasource remoteDatasource;

  DailyTransectionRepoImp({required this.remoteDatasource});

  @override
  Future<Either<Failure, List<DailyTransections>>> fetchDailyTransections({String date = ''}) async {
    try {
      final dailyTransections = await remoteDatasource.fetchDailyTransections(date: date);
      return right([dailyTransections]);
    } catch (e) {
      rethrow;
    }
  }
}