import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/head_office_contact_entity.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/service_station_entity.dart';

abstract class ContactsRepository {
  Future<Either<Failure, HeadOfficeContactEntity>> getHeadOfficeContacts();
  Future<Either<Failure, ServiceStationListEntity>> getServiceStations({
    required String page,
    String? searchQuery,
  });
}
