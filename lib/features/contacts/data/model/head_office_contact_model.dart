import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/head_office_contact_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'head_office_contact_model.g.dart';

@JsonSerializable()
class HeadOfficeContactResponse extends Equatable {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'data')
  final HeadOfficeContactDataModel? data;

  const HeadOfficeContactResponse({this.message, this.data});

  factory HeadOfficeContactResponse.fromJson(Map<String, dynamic> json) =>
      _$HeadOfficeContactResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HeadOfficeContactResponseToJson(this);

  HeadOfficeContactEntity toEntity() {
    if (data == null) {
      return HeadOfficeContactEntity(
        csrContact: [],
        departments: {},
        provinces: {},
        hubContact: [],
        valleyContact: [],
        issueContact: [],
      );
    }

    return HeadOfficeContactEntity(
      csrContact: data!.csrContact
          .map((contact) => contact.toEntity())
          .toList(),
      departments: _convertMapToEntityMap(data!.departments),
      provinces: _convertMapToEntityMap(data!.provinces),
      hubContact: data!.hubContact
          .map((contact) => contact.toEntity())
          .toList(),
      valleyContact: data!.valleyContact
          .map((contact) => contact.toEntity())
          .toList(),
      issueContact: data!.issueContact
          .map((contact) => contact.toEntity())
          .toList(),
    );
  }

  Map<String, List<ContactPersonEntity>> _convertMapToEntityMap(
    Map<String, List<ContactPersonModel>>? modelMap,
  ) {
    if (modelMap == null || modelMap.isEmpty) {
      return {};
    }

    final Map<String, List<ContactPersonEntity>> result = {};
    modelMap.forEach((key, value) {
      result[key] = value.map((model) => model.toEntity()).toList();
    });
    return result;
  }

  @override
  List<Object?> get props => [message, data];
}

@JsonSerializable()
class HeadOfficeContactDataModel extends Equatable {
  @JsonKey(name: 'csr_contact', defaultValue: [])
  final List<ContactPersonModel> csrContact;

  @JsonKey(name: 'departments', defaultValue: {})
  final Map<String, List<ContactPersonModel>> departments;

  @JsonKey(name: 'provinces', defaultValue: {})
  final Map<String, List<ContactPersonModel>> provinces;

  @JsonKey(name: 'hub_contact', defaultValue: [])
  final List<ContactPersonModel> hubContact;

  @JsonKey(name: 'valley_contact', defaultValue: [])
  final List<ContactPersonModel> valleyContact;

  @JsonKey(name: 'issue_contact', defaultValue: [])
  final List<ContactPersonModel> issueContact;

  const HeadOfficeContactDataModel({
    required this.csrContact,
    required this.departments,
    required this.provinces,
    required this.hubContact,
    required this.valleyContact,
    required this.issueContact,
  });

  factory HeadOfficeContactDataModel.fromJson(Map<String, dynamic> json) =>
      _$HeadOfficeContactDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$HeadOfficeContactDataModelToJson(this);

  @override
  List<Object?> get props => [
    csrContact,
    departments,
    provinces,
    hubContact,
    valleyContact,
    issueContact,
  ];
}

@JsonSerializable()
class ContactPersonModel extends Equatable {
  @JsonKey(name: 'contact_person', defaultValue: '')
  final String contactPerson;

  @JsonKey(name: 'phone_no', defaultValue: '')
  final String phoneNo;

  const ContactPersonModel({
    required this.contactPerson,
    required this.phoneNo,
  });

  factory ContactPersonModel.fromJson(Map<String, dynamic> json) =>
      _$ContactPersonModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContactPersonModelToJson(this);

  ContactPersonEntity toEntity() {
    return ContactPersonEntity(contactPerson: contactPerson, phoneNo: phoneNo);
  }

  @override
  List<Object?> get props => [contactPerson, phoneNo];
}
