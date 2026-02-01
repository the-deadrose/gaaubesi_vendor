// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'head_office_contact_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HeadOfficeContactResponse _$HeadOfficeContactResponseFromJson(
  Map<String, dynamic> json,
) => HeadOfficeContactResponse(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : HeadOfficeContactDataModel.fromJson(
          json['data'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$HeadOfficeContactResponseToJson(
  HeadOfficeContactResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

HeadOfficeContactDataModel _$HeadOfficeContactDataModelFromJson(
  Map<String, dynamic> json,
) => HeadOfficeContactDataModel(
  csrContact:
      (json['csr_contact'] as List<dynamic>?)
          ?.map((e) => ContactPersonModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  departments: json['departments'] == null
      ? {}
      : HeadOfficeContactDataModel._mapFromJson(
          json['departments'] as Map<String, dynamic>?,
        ),
  provinces: json['provinces'] == null
      ? {}
      : HeadOfficeContactDataModel._mapFromJson(
          json['provinces'] as Map<String, dynamic>?,
        ),
  hubContact:
      (json['hub_contact'] as List<dynamic>?)
          ?.map((e) => ContactPersonModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  valleyContact:
      (json['valley_contact'] as List<dynamic>?)
          ?.map((e) => ContactPersonModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  issueContact:
      (json['issue_contact'] as List<dynamic>?)
          ?.map((e) => ContactPersonModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$HeadOfficeContactDataModelToJson(
  HeadOfficeContactDataModel instance,
) => <String, dynamic>{
  'csr_contact': instance.csrContact,
  'departments': HeadOfficeContactDataModel._mapToJson(instance.departments),
  'provinces': HeadOfficeContactDataModel._mapToJson(instance.provinces),
  'hub_contact': instance.hubContact,
  'valley_contact': instance.valleyContact,
  'issue_contact': instance.issueContact,
};

ContactPersonModel _$ContactPersonModelFromJson(Map<String, dynamic> json) =>
    ContactPersonModel(
      contactPerson: json['contact_person'] as String,
      phoneNo: json['phone_no'] as String,
    );

Map<String, dynamic> _$ContactPersonModelToJson(ContactPersonModel instance) =>
    <String, dynamic>{
      'contact_person': instance.contactPerson,
      'phone_no': instance.phoneNo,
    };
