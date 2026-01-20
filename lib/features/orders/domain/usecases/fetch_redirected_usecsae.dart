import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/redirected_orders_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/repositories/order_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FetchRedirectedUsecsae
    extends UseCase<RedirectedOrders, FetchRedirectedParams> {
  final OrderRepository repository;

  FetchRedirectedUsecsae(this.repository);

  @override
  Future<Either<Failure, RedirectedOrders>> call(
    FetchRedirectedParams params,
  ) async {
    return await repository.fetchRedirectedOrders(page: params.page);
  }
}

class FetchRedirectedParams {
  final int page;

  FetchRedirectedParams({required this.page});
}
