import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/head_office_contact_entity.dart';

class HeadOfficeContactsState extends Equatable{
  @override
  List<Object?> get props => [];
}

class HeadOfficeContactsInitial extends HeadOfficeContactsState {}

class HeadOfficeContactsLoading extends HeadOfficeContactsState {}


class HeadOfficeContactsLoaded extends HeadOfficeContactsState {
  final HeadOfficeContactEntity headOfficeContacts;

  HeadOfficeContactsLoaded({required this.headOfficeContacts});

  @override
  List<Object?> get props => [headOfficeContacts];
}

class HeadOfficeContactsError extends HeadOfficeContactsState {
  final String message;

  HeadOfficeContactsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class HeadOfficeContactsEmpty extends HeadOfficeContactsState {}