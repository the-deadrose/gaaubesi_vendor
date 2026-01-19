 import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/daily_transections/domain/entity/daily_transections_entity.dart';
import 'package:gaaubesi_vendor/features/daily_transections/domain/repo/daily_transection_repo.dart';
import 'package:injectable/injectable.dart';


@lazySingleton

class FetchDailyTransactionUsecase
    extends UseCase<List<DailyTransections>, FetchDailyTransactionUsecaseParams> {
  final DailyTransectionRepo _repository;

  FetchDailyTransactionUsecase(this._repository);

  @override
  Future<Either<Failure, List<DailyTransections>>> call(
      FetchDailyTransactionUsecaseParams params) async {
    final result = await _repository.fetchDailyTransections(date: params.date);
    return result; 
}
    }

class FetchDailyTransactionUsecaseParams {
  final String date;

  FetchDailyTransactionUsecaseParams({required this.date});
}