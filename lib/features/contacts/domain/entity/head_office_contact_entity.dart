
import 'package:equatable/equatable.dart';

class HeadOfficeContactEntity extends Equatable {
  final List<ContactPersonEntity> csrContact;
  final Map<String, List<ContactPersonEntity>> departments;
  final Map<String, List<ContactPersonEntity>> provinces;
  final List<ContactPersonEntity> hubContact;
  final List<ContactPersonEntity> valleyContact;
  final List<ContactPersonEntity> issueContact;

  const HeadOfficeContactEntity({
    required this.csrContact,
    required this.departments,
    required this.provinces,
    required this.hubContact,
    required this.valleyContact,
    required this.issueContact,
  });

  @override
  List<Object?> get props => [
        csrContact,
        departments,
        provinces,
        hubContact,
        valleyContact,
        issueContact,
      ];

  @override
  bool get stringify => true;
}

class ContactPersonEntity extends Equatable {
  final String contactPerson;
  final String phoneNo;

  const ContactPersonEntity({
    required this.contactPerson,
    required this.phoneNo,
  });

  @override
  List<Object?> get props => [contactPerson, phoneNo];

  @override
  bool get stringify => true;
}