// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frequently_used_and_payment_method_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FrequentlyUsedAndPaymentMethodListModel
_$FrequentlyUsedAndPaymentMethodListModelFromJson(
  Map<String, dynamic> json,
) => FrequentlyUsedAndPaymentMethodListModel(
  paymentMethods:
      FrequentlyUsedAndPaymentMethodListModel._paymentMethodListFromJson(
        json['payment_methods'] as List?,
      ),
  bankNames: FrequentlyUsedAndPaymentMethodListModel._bankNameListFromJson(
    json['bank_names'] as List?,
  ),
  frequentlyUsedMethods:
      FrequentlyUsedAndPaymentMethodListModel._frequentlyUsedMethodListFromJson(
        json['frequently_used_methods'] as List?,
      ),
);

Map<String, dynamic> _$FrequentlyUsedAndPaymentMethodListModelToJson(
  FrequentlyUsedAndPaymentMethodListModel instance,
) => <String, dynamic>{
  'payment_methods': instance.paymentMethods.map((e) => e.toJson()).toList(),
  'bank_names': instance.bankNames.map((e) => e.toJson()).toList(),
  'frequently_used_methods': instance.frequentlyUsedMethods
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
