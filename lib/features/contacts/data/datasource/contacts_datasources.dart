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
    try {
      final response = await _dioClient.get(
        ApiEndpoints.headOfficeContacts,
      );

      debugPrint('🔵 API Response: ${response.data}');
      debugPrint('🔵 Response Type: ${response.data.runtimeType}');

      final dynamic responseData = response.data;
      
      // The API response already has the structure we need
      if (responseData is Map<String, dynamic>) {
        // Check if the response has success field
        if (responseData.containsKey('success') && 
            responseData['success'] == true &&
            responseData.containsKey('data')) {
          
          debugPrint('🔵 Extracting from "data" field');
          final jsonData = responseData['data'] as Map<String, dynamic>;
          
          debugPrint('🔵 JSON Data to parse: $jsonData');
          
          // Create model directly from the data field
          final model = HeadOfficeContactDataModel.fromJson(jsonData);
          
          // Convert to entity
          return HeadOfficeContactEntity(
            csrContact: model.csrContact.map((e) => e.toEntity()).toList(),
            departments: model.departments.map(
              (k, v) => MapEntry(
                k,
                v.map((e) => e.toEntity()).toList(),
              ),
            ),
            provinces: model.provinces.map(
              (k, v) => MapEntry(
                k,
                v.map((e) => e.toEntity()).toList(),
              ),
            ),
            hubContact: model.hubContact.map((e) => e.toEntity()).toList(),
            valleyContact: model.valleyContact.map((e) => e.toEntity()).toList(),
            issueContact: model.issueContact.map((e) => e.toEntity()).toList(),
          );
        } else {
          throw Exception('Invalid API response format: $responseData');
        }
      } else {
        throw Exception('Unexpected response format: ${responseData.runtimeType}');
      }
    } catch (e) {
      debugPrint('🔴 Error fetching head office contacts: $e');
      debugPrint('🔴 Stack trace: ${e.toString()}');
      rethrow;
    }
  }
}