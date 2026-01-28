import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/head_office_contact_entity.dart';

abstract class ContactsRepository {
  Future<Either<Failure, HeadOfficeContactEntity>> getHeadOfficeContacts();
}