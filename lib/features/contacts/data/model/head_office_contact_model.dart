import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/head_office_contact_entity.dart';

part 'head_office_contact_model.g.dart';


@JsonSerializable()
class HeadOfficeContactResponse extends Equatable {
  final bool? success;
  final String? message;
  final HeadOfficeContactDataModel? data;

  const HeadOfficeContactResponse({
    this.success,
    this.message,
    this.data,
  });

  factory HeadOfficeContactResponse.fromJson(Map<String, dynamic> json) =>
      _$HeadOfficeContactResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HeadOfficeContactResponseToJson(this);

  HeadOfficeContactEntity toEntity() {
    final d = data;
    if (d == null) {
      return const HeadOfficeContactEntity(
        csrContact: [],
        departments: {},
        provinces: {},
        hubContact: [],
        valleyContact: [],
        issueContact: [],
      );
    }
    return HeadOfficeContactEntity(
      csrContact: d.csrContact.map((e) => e.toEntity()).toList(),
      departments: d.departments.map(
        (k, v) => MapEntry(
          k,
          v.map((e) => e.toEntity()).toList(),
        ),
      ),
      provinces: d.provinces.map(
        (k, v) => MapEntry(
          k,
          v.map((e) => e.toEntity()).toList(),
        ),
      ),
      hubContact: d.hubContact.map((e) => e.toEntity()).toList(),
      valleyContact: d.valleyContact.map((e) => e.toEntity()).toList(),
      issueContact: d.issueContact.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}
@JsonSerializable()

class HeadOfficeContactDataModel extends Equatable {
  @JsonKey(name: 'csr_contact', defaultValue: [])
  final List<ContactPersonModel> csrContact;

  @JsonKey(
    name: 'departments',
    fromJson: _mapFromJson,
    toJson: _mapToJson,
    defaultValue: {},
  )
  final Map<String, List<ContactPersonModel>> departments;

  @JsonKey(
    name: 'provinces',
    fromJson: _mapFromJson,
    toJson: _mapToJson,
    defaultValue: {},
  )
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

  Map<String, dynamic> toJson() =>
      _$HeadOfficeContactDataModelToJson(this);

  static Map<String, List<ContactPersonModel>> _mapFromJson(
    Map<String, dynamic>? json,
  ) {
    if (json == null) return {};
    return json.map(
      (key, value) => MapEntry(
        key,
        (value as List)
            .map((e) => ContactPersonModel.fromJson(e))
            .toList(),
      ),
    );
  }

  static Map<String, dynamic> _mapToJson(
    Map<String, List<ContactPersonModel>> map,
  ) {
    return map.map(
      (key, value) => MapEntry(
        key,
        value.map((e) => e.toJson()).toList(),
      ),
    );
  }

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
  @JsonKey(name: 'contact_person')
  final String contactPerson;

  @JsonKey(name: 'phone_no')
  final String phoneNo;

  const ContactPersonModel({
    required this.contactPerson,
    required this.phoneNo,
  });

  factory ContactPersonModel.fromJson(Map<String, dynamic> json) =>
      _$ContactPersonModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ContactPersonModelToJson(this);

  ContactPersonEntity toEntity() =>
      ContactPersonEntity(
        contactPerson: contactPerson,
        phoneNo: phoneNo,
      );

  @override
  List<Object?> get props => [contactPerson, phoneNo];
}
