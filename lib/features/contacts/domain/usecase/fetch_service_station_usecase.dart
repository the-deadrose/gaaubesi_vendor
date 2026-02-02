import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/service_station_entity.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/repository/contacts_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FetchServiceStationUsecase
    extends UseCase<ServiceStationListEntity, FetchServiceStationParams> {
  final ContactsRepository contactsRepository;

  FetchServiceStationUsecase({required this.contactsRepository});

  @override
  Future<Either<Failure, ServiceStationListEntity>> call(
    FetchServiceStationParams params,
  ) {
    return contactsRepository.getServiceStations(page: params.page , searchQuery: params.searchQuery);
  }
}

class FetchServiceStationParams {
  final String page;
  final String? searchQuery;

  FetchServiceStationParams({required this.page , this.searchQuery});
}
