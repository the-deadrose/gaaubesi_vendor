// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRequestListModel _$PaymentRequestListModelFromJson(
  Map<String, dynamic> json,
) => PaymentRequestListModel(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  resultsList: (json['results'] as List<dynamic>)
      .map((e) => PaymentRequestModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  paymentMethodsList: (json['payment_methods'] as List<dynamic>)
      .map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  bankNamesList: (json['bank_names'] as List<dynamic>)
      .map((e) => BankNameModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PaymentRequestListModelToJson(
  PaymentRequestListModel instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.resultsList.map((e) => e.toJson()).toList(),
  'payment_methods': instance.paymentMethodsList
      .map((e) => e.toJson())
      .toList(),
  'bank_names': instance.bankNamesList.map((e) => e.toJson()).toList(),
};

PaymentRequestModel _$PaymentRequestModelFromJson(Map<String, dynamic> json) =>
    PaymentRequestModel(
      id: (json['id'] as num).toInt(),
      paymentMethodIdJson: json['payment_method_id'] as String?,
      paymentMethodNameJson: json['payment_method_name'] as String?,
      paymentBankNameJson: json['payment_bank_name'] as String?,
      paymentAccountNameJson: json['payment_account_name'] as String?,
      paymentAccountNumberJson: json['payment_account_number'] as String?,
      paymentPhoneNumberJson: json['payment_phone_number'] as String?,
      paymentPersonNameJson: json['payment_person_name'] as String?,
      paymentPersonPhoneJson: json['payment_person_phone'] as String?,
      description: json['description'] as String,
      reply: json['reply'] as String?,
      status: json['status'] as String,
      statusDisplayJson: json['status_display'] as String,
      createdOnJson: DateTime.parse(json['created_on'] as String),
      createdOnFormattedJson: json['created_on_formatted'] as String,
      closedOnJson: json['closed_on'] == null
          ? null
          : DateTime.parse(json['closed_on'] as String),
      closedOnFormattedJson: json['closed_on_formatted'] as String,
      closedByNameJson: json['closed_by_name'] as String,
    );

Map<String, dynamic> _$PaymentRequestModelToJson(
  PaymentRequestModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'description': instance.description,
  'reply': instance.reply,
  'status': instance.status,
  'payment_method_id': instance.paymentMethodIdJson,
  'payment_method_name': instance.paymentMethodNameJson,
  'payment_bank_name': instance.paymentBankNameJson,
  'payment_account_name': instance.paymentAccountNameJson,
  'payment_account_number': instance.paymentAccountNumberJson,
  'payment_phone_number': instance.paymentPhoneNumberJson,
  'payment_person_name': instance.paymentPersonNameJson,
  'payment_person_phone': instance.paymentPersonPhoneJson,
  'status_display': instance.statusDisplayJson,
  'created_on': instance.createdOnJson.toIso8601String(),
  'created_on_formatted': instance.createdOnFormattedJson,
  'closed_on': instance.closedOnJson?.toIso8601String(),
  'closed_on_formatted': instance.closedOnFormattedJson,
  'closed_by_name': instance.closedByNameJson,
};

PaymentMethodModel _$PaymentMethodModelFromJson(Map<String, dynamic> json) =>
    PaymentMethodModel(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$PaymentMethodModelToJson(PaymentMethodModel instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

BankNameModel _$BankNameModelFromJson(Map<String, dynamic> json) =>
    BankNameModel(name: json['name'] as String);

Map<String, dynamic> _$BankNameModelToJson(BankNameModel instance) =>
    <String, dynamic>{'name': instance.name};
