// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entity/payment_request_list_entity.dart';

part 'payment_request_list_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PaymentRequestListModel extends PaymentRequestListEntity {
  @JsonKey(name: 'results')
  final List<PaymentRequestModel> resultsList;
  
  @JsonKey(name: 'payment_methods')
  final List<PaymentMethodModel> paymentMethodsList;
  
  @JsonKey(name: 'bank_names')
  final List<BankNameModel> bankNamesList;

  const PaymentRequestListModel({
    required super.count,
    super.next,
    super.previous,
    required this.resultsList,
    required this.paymentMethodsList,
    required this.bankNamesList,
  }) : super(
          results: resultsList,
          paymentMethods: paymentMethodsList,
          bankNames: bankNamesList,
        );

  factory PaymentRequestListModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestListModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentRequestListModelToJson(this);
}

@JsonSerializable()
class PaymentRequestModel extends PaymentRequestEntity {
  @JsonKey(name: 'payment_method_id')
  final String? paymentMethodIdJson;
  
  @JsonKey(name: 'payment_method_name')
  final String? paymentMethodNameJson;
  
  @JsonKey(name: 'payment_bank_name')
  final String? paymentBankNameJson;
  
  @JsonKey(name: 'payment_account_name')
  final String? paymentAccountNameJson;
  
  @JsonKey(name: 'payment_account_number')
  final String? paymentAccountNumberJson;
  
  @JsonKey(name: 'payment_phone_number')
  final String? paymentPhoneNumberJson;
  
  @JsonKey(name: 'payment_person_name')
  final String? paymentPersonNameJson;
  
  @JsonKey(name: 'payment_person_phone')
  final String? paymentPersonPhoneJson;
  
  @JsonKey(name: 'status_display')
  final String statusDisplayJson;
  
  @JsonKey(name: 'created_on')
  final DateTime createdOnJson;
  
  @JsonKey(name: 'created_on_formatted')
  final String createdOnFormattedJson;
  
  @JsonKey(name: 'closed_on')
  final DateTime? closedOnJson;
  
  @JsonKey(name: 'closed_on_formatted')
  final String closedOnFormattedJson;
  
  @JsonKey(name: 'closed_by_name')
  final String closedByNameJson;

  const PaymentRequestModel({
    required super.id,
    this.paymentMethodIdJson,
    this.paymentMethodNameJson,
    this.paymentBankNameJson,
    this.paymentAccountNameJson,
    this.paymentAccountNumberJson,
    this.paymentPhoneNumberJson,
    this.paymentPersonNameJson,
    this.paymentPersonPhoneJson,
    required super.description,
    super.reply,
    required super.status,
    required this.statusDisplayJson,
    required this.createdOnJson,
    required this.createdOnFormattedJson,
    this.closedOnJson,
    required this.closedOnFormattedJson,
    required this.closedByNameJson,
  }) : super(
          paymentMethodId: paymentMethodIdJson,
          paymentMethodName: paymentMethodNameJson,
          paymentBankName: paymentBankNameJson,
          paymentAccountName: paymentAccountNameJson,
          paymentAccountNumber: paymentAccountNumberJson,
          paymentPhoneNumber: paymentPhoneNumberJson,
          paymentPersonName: paymentPersonNameJson,
          paymentPersonPhone: paymentPersonPhoneJson,
          statusDisplay: statusDisplayJson,
          createdOn: createdOnJson,
          createdOnFormatted: createdOnFormattedJson,
          closedOn: closedOnJson,
          closedOnFormatted: closedOnFormattedJson,
          closedByName: closedByNameJson,
        );

  factory PaymentRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentRequestModelToJson(this);
}

@JsonSerializable()
class PaymentMethodModel extends PaymentMethodEntity {
  const PaymentMethodModel({
    required super.id,
    required super.name,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodModelToJson(this);
}

@JsonSerializable()
class BankNameModel extends BankNameEntity {
  const BankNameModel({required super.name});

  factory BankNameModel.fromJson(Map<String, dynamic> json) =>
      _$BankNameModelFromJson(json);

  Map<String, dynamic> toJson() => _$BankNameModelToJson(this);
}