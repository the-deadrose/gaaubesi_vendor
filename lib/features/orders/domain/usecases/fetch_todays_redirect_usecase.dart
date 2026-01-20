import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/today_redirect_order_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/repositories/order_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FetchTodaysRedirectUsecase
    extends UseCase<TodayRedirectOrderList, FetchTodaysRedirectedParams> {
  final OrderRepository repository;

  FetchTodaysRedirectUsecase(this.repository);

  @override
  Future<Either<Failure, TodayRedirectOrderList>> call(
    FetchTodaysRedirectedParams params,
  ) async {
    return await repository.fetchRedirectedOrdersToday(page: params.page);
  }
}

class FetchTodaysRedirectedParams {
  final int page;

  FetchTodaysRedirectedParams({required this.page});
}
