// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRequestListModel _$PaymentRequestListModelFromJson(
  Map<String, dynamic> json,
) => PaymentRequestListModel(
  paymentMethodsModel: (json['payment_methods'] as List<dynamic>)
      .map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  bankNamesModel: (json['bank_names'] as List<dynamic>)
      .map((e) => BankNameModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  frequentlyUsedMethodsModel: (json['frequently_used_methods'] as List<dynamic>)
      .map((e) => FrequentlyUsedMethodModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PaymentRequestListModelToJson(
  PaymentRequestListModel instance,
) => <String, dynamic>{
  'payment_methods': instance.paymentMethodsModel
      .map((e) => e.toJson())
      .toList(),
  'bank_names': instance.bankNamesModel.map((e) => e.toJson()).toList(),
  'frequently_used_methods': instance.frequentlyUsedMethodsModel
      .map((e) => e.toJson())
      .toList(),
};

PaymentMethodModel _$PaymentMethodModelFromJson(Map<String, dynamic> json) =>
    PaymentMethodModel(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$PaymentMethodModelToJson(PaymentMethodModel instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

BankNameModel _$BankNameModelFromJson(Map<String, dynamic> json) =>
    BankNameModel(name: json['name'] as String);

Map<String, dynamic> _$BankNameModelToJson(BankNameModel instance) =>
    <String, dynamic>{'name': instance.name};

FrequentlyUsedMethodModel _$FrequentlyUsedMethodModelFromJson(
  Map<String, dynamic> json,
) => FrequentlyUsedMethodModel(
  id: (json['id'] as num).toInt(),
  paymentMethod: PaymentMethodModel.fromJson(
    json['payment_method'] as Map<String, dynamic>,
  ),
  paymentBankName: json['payment_bank_name'] as String?,
  paymentAccountName: json['payment_account_name'] as String?,
  paymentAccountNumber: json['payment_account_number'] as String?,
  paymentPhoneNumber: json['payment_phone_number'] as String?,
  paymentPersonName: json['payment_person_name'] as String?,
  paymentPersonPhone: json['payment_person_phone'] as String?,
  renderPaymentDetails: json['render_payment_details'] as String,
);

Map<String, dynamic> _$FrequentlyUsedMethodModelToJson(
  FrequentlyUsedMethodModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'payment_method': instance.paymentMethod.toJson(),
  'payment_bank_name': instance.paymentBankName,
  'payment_account_name': instance.paymentAccountName,
  'payment_account_number': instance.paymentAccountNumber,
  'payment_phone_number': instance.paymentPhoneNumber,
  'payment_person_name': instance.paymentPersonName,
  'payment_person_phone': instance.paymentPersonPhone,
  'render_payment_details': instance.renderPaymentDetails,
};
