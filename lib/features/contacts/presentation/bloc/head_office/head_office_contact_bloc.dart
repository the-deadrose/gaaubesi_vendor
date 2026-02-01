import 'dart:async';
import 'package:flutter/cupertino.dart';
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
        debugPrint('🔴 BLoC: Emitting Error State: ${failure.toString()}');
        emit(HeadOfficeContactsError(message: failure.toString()));
      },
      (headOfficeContacts) {
        debugPrint('🟢 BLoC: Data received:');
        debugPrint('csrContact: \\${headOfficeContacts.csrContact}');
        debugPrint('departments: \\${headOfficeContacts.departments}');
        debugPrint('provinces: \\${headOfficeContacts.provinces}');
        debugPrint('hubContact: \\${headOfficeContacts.hubContact}');
        debugPrint('valleyContact: \\${headOfficeContacts.valleyContact}');
        debugPrint('issueContact: \\${headOfficeContacts.issueContact}');
        final hasData =
            headOfficeContacts.csrContact.isNotEmpty ||
            headOfficeContacts.departments.isNotEmpty ||
            headOfficeContacts.provinces.isNotEmpty ||
            headOfficeContacts.hubContact.isNotEmpty ||
            headOfficeContacts.valleyContact.isNotEmpty ||
            headOfficeContacts.issueContact.isNotEmpty;

        if (hasData) {
          debugPrint('🟢 BLoC: Emitting Loaded State');
          emit(
            HeadOfficeContactsLoaded(headOfficeContacts: headOfficeContacts),
          );
        } else {
          debugPrint('🟡 BLoC: Emitting Empty State');
          emit(HeadOfficeContactsEmpty());
        }
      },
    );
  }
}
