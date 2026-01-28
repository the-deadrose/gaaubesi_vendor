import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/contacts/data/model/head_office_contact_model.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/head_office_contact_entity.dart';
import 'package:injectable/injectable.dart';

abstract class ContactsRemoteDatasources {
  Future<HeadOfficeContactEntity> fetchHeadOfficeContacts();
}
@LazySingleton(as: ContactsRemoteDatasources)


class ContactsRemoteDatasourcesImp implements ContactsRemoteDatasources {
  final DioClient _dioClient;
  ContactsRemoteDatasourcesImp(this._dioClient);

  @override
  Future<HeadOfficeContactEntity> fetchHeadOfficeContacts() async {
    // try {
      final response = await _dioClient.get(
        ApiEndpoints.headOfficeContacts,
      );

      debugPrint('🔵 API Response: ${response.data}');
      debugPrint('🔵 Response Type: ${response.data.runtimeType}');

      final dynamic responseData = response.data;
      final Map<String, dynamic> jsonData;

      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          debugPrint('🔵 Extracting from "data" field');
          jsonData = responseData['data'] as Map<String, dynamic>;
        } else {
          jsonData = responseData;
        }
      } else {
        throw Exception(
          'Unexpected response format: ${responseData.runtimeType}',
        );
      }

      debugPrint('🔵 JSON Data to parse: $jsonData');
      final model = HeadOfficeContactResponse.fromJson(jsonData);
      debugPrint('🔵 Parsed contacts count: ${model.data?.csrContact.length}');

      return model.toEntity();
    // } catch (e) {
    //   debugPrint('🔴 Error fetching head office contacts: $e');
    //   rethrow;
    // }
  }
}