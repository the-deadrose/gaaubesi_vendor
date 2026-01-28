import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/contacts/data/datasource/contacts_datasources.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/head_office_contact_entity.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/repository/contacts_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ContactsRepository)
class ContactsRepositoryImpl implements ContactsRepository {
  final ContactsRemoteDatasources remoteDatasources;

  ContactsRepositoryImpl({required this.remoteDatasources});

  @override
  Future<Either<Failure, HeadOfficeContactEntity>>
  getHeadOfficeContacts() async {
    // try {
      final result = await remoteDatasources.fetchHeadOfficeContacts();
      return Right(result);
    // } catch (e) {
    //   return Left(ServerFailure('Failed to fetch head office contacts'));
    // }
  }
}
