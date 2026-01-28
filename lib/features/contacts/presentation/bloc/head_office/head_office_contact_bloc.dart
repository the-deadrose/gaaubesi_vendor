import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/usecase/fetch_headoffice_usecase.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/head_office/head_office_contacts_events.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/head_office/head_office_contacts_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class HeadOfficeContactsBloc
    extends Bloc<HeadOfficeContactsEvents, HeadOfficeContactsState> {
  final FetchHeadofficeUsecase fetchHeadofficeUsecase;

  HeadOfficeContactsBloc({required this.fetchHeadofficeUsecase})
    : super(HeadOfficeContactsInitial()) {
    on<FetchHeadOfficeContactsEvent>(_onFetchHeadOfficeContacts);
  }

  Future<void> _onFetchHeadOfficeContacts(
    FetchHeadOfficeContactsEvent event,
    Emitter<HeadOfficeContactsState> emit,
  ) async {
    emit(HeadOfficeContactsLoading());

    final result = await fetchHeadofficeUsecase(NoParams());

    result.fold(
      (failure) {
        emit(HeadOfficeContactsError(message: failure.toString()));
      },
      (headOfficeContacts) {
        final hasData =
            headOfficeContacts.csrContact.isNotEmpty ||
            headOfficeContacts.departments.isNotEmpty ||
            headOfficeContacts.provinces.isNotEmpty ||
            headOfficeContacts.hubContact.isNotEmpty ||
            headOfficeContacts.valleyContact.isNotEmpty ||
            headOfficeContacts.issueContact.isNotEmpty;

        if (hasData) {
          emit(
            HeadOfficeContactsLoaded(headOfficeContacts: headOfficeContacts),
          );
        } else {
          emit(HeadOfficeContactsEmpty());
        }
      },
    );
  }
}
