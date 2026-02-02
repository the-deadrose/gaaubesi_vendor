import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/contacts/data/model/head_office_contact_model.dart';
import 'package:gaaubesi_vendor/features/contacts/data/model/service_station_model.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/head_office_contact_entity.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/service_station_entity.dart';
import 'package:injectable/injectable.dart';

abstract class ContactsRemoteDatasources {
  Future<HeadOfficeContactEntity> fetchHeadOfficeContacts();
  Future<ServiceStationListEntity> fetchServiceStations({
    required String page,
    String? searchQuery,
  });
}

@LazySingleton(as: ContactsRemoteDatasources)
class ContactsRemoteDatasourcesImp implements ContactsRemoteDatasources {
  final DioClient _dioClient;
  ContactsRemoteDatasourcesImp(this._dioClient);

  @override
  Future<HeadOfficeContactEntity> fetchHeadOfficeContacts() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.headOfficeContacts);

      debugPrint(' API Response received');
      debugPrint(' Response Type: ${response.data.runtimeType}');

      final dynamic responseData = response.data;

      if (responseData is! Map<String, dynamic>) {
        throw Exception(
          'Unexpected response format: ${responseData.runtimeType}',
        );
      }

      debugPrint(' Response keys: ${responseData.keys.toList()}');

      final model = HeadOfficeContactDataModel.fromJson(responseData);

      debugPrint('Successfully parsed contact data');

      return HeadOfficeContactEntity(
        csrContact: model.csrContact.map((e) => e.toEntity()).toList(),
        departments: model.departments.map(
          (k, v) => MapEntry(k, v.map((e) => e.toEntity()).toList()),
        ),
        provinces: model.provinces.map(
          (k, v) => MapEntry(k, v.map((e) => e.toEntity()).toList()),
        ),
        hubContact: model.hubContact.map((e) => e.toEntity()).toList(),
        valleyContact: model.valleyContact.map((e) => e.toEntity()).toList(),
        issueContact: model.issueContact.map((e) => e.toEntity()).toList(),
      );
    } catch (e, stackTrace) {
      debugPrint('🔴 Error fetching head office contacts: $e');
      debugPrint('🔴 Stack trace: $stackTrace');

      rethrow;
    }
  }

  @override
  Future<ServiceStationListEntity> fetchServiceStations({
    required String page,
    String? searchQuery,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.serviceStations,
        queryParameters: {
          QueryParams.page: page,
          if (searchQuery != null && searchQuery.isNotEmpty)
            'search': searchQuery,
        },
      );
      debugPrint(' API Response received for Service Stations');
      debugPrint(' Response Type: ${response.data.runtimeType}');
      final dynamic responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw Exception(
          'Unexpected response format: ${responseData.runtimeType}',
        );
      }
      debugPrint(' Response keys: ${responseData.keys.toList()}');

      final model = ServiceStationListModel.fromJson(responseData);

      debugPrint('Successfully parsed service station data');

      return model.toEntity();
    } catch (e, stackTrace) {
      debugPrint('🔴 Error fetching service stations: $e');
      debugPrint('🔴 Stack trace: $stackTrace');

      rethrow;
    }
  }
}
