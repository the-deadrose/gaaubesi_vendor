import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/head_office_contact_entity.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/repository/contacts_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FetchHeadofficeUsecase
    extends UseCase<HeadOfficeContactEntity, NoParams> {
  final ContactsRepository contactsRepository;

  FetchHeadofficeUsecase({required this.contactsRepository});

  @override
  Future<Either<Failure, HeadOfficeContactEntity>> call(NoParams params) {
    return contactsRepository.getHeadOfficeContacts();
  }
}
