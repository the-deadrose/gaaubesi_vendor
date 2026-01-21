// ignore_for_file: invalid_annotation_target

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/entity/frequently_used_and_payment_method_entity.dart';

part 'frequently_used_and_payment_method_model.g.dart';


@JsonSerializable(explicitToJson: true)
class FrequentlyUsedAndPaymentMethodListModel extends Equatable {
  @JsonKey(
    name: 'payment_methods',
    fromJson: _paymentMethodListFromJson,
  )
  final List<PaymentMethodModel> paymentMethods;

  @JsonKey(
    name: 'bank_names',
    fromJson: _bankNameListFromJson,
  )
  final List<BankNameModel> bankNames;

  @JsonKey(
    name: 'frequently_used_methods',
    fromJson: _frequentlyUsedMethodListFromJson,
  )
  final List<FrequentlyUsedMethodModel> frequentlyUsedMethods;

  const FrequentlyUsedAndPaymentMethodListModel({
    required this.paymentMethods,
    required this.bankNames,
    required this.frequentlyUsedMethods,
  });

  factory FrequentlyUsedAndPaymentMethodListModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$FrequentlyUsedAndPaymentMethodListModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$FrequentlyUsedAndPaymentMethodListModelToJson(this);

  @override
  List<Object?> get props => [
        paymentMethods,
        bankNames,
        frequentlyUsedMethods,
      ];

  /// Convert model to entity
  FrequentlyUsedAndPaymentMethodList toEntity() {
    return FrequentlyUsedAndPaymentMethodList(
      paymentMethods: paymentMethods.map((model) {
        return PaymentMethod(id: model.id, name: model.name);
      }).toList(),
      bankNames: bankNames.map((model) {
        return BankName(name: model.name);
      }).toList(),
      frequentlyUsedMethods: frequentlyUsedMethods.map((model) {
        return FrequentlyUsedMethod(
          id: model.id,
          paymentMethod: PaymentMethod(
            id: model.paymentMethod.id,
            name: model.paymentMethod.name,
          ),
          paymentBankName: model.paymentBankName,
          paymentAccountName: model.paymentAccountName,
          paymentAccountNumber: model.paymentAccountNumber,
          paymentPhoneNumber: model.paymentPhoneNumber,
          paymentPersonName: model.paymentPersonName,
          paymentPersonPhone: model.paymentPersonPhone,
          renderPaymentDetails: model.renderPaymentDetails,
        );
      }).toList(),
    );
  }


  static List<PaymentMethodModel> _paymentMethodListFromJson(
    List<dynamic>? json,
  ) =>
      json
          ?.map(
            (e) => PaymentMethodModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      [];

  static List<BankNameModel> _bankNameListFromJson(
    List<dynamic>? json,
  ) =>
      json
          ?.map(
            (e) => BankNameModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      [];

  static List<FrequentlyUsedMethodModel>
      _frequentlyUsedMethodListFromJson(
    List<dynamic>? json,
  ) =>
          json
              ?.map(
                (e) => FrequentlyUsedMethodModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [];
}


@JsonSerializable()
class PaymentMethodModel extends Equatable {
  final String id;
  final String name;

  const PaymentMethodModel({
    required this.id,
    required this.name,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PaymentMethodModelToJson(this);

  @override
  List<Object?> get props => [id, name];
}


@JsonSerializable()
class BankNameModel extends Equatable {
  final String name;

  const BankNameModel({
    required this.name,
  });

  factory BankNameModel.fromJson(Map<String, dynamic> json) =>
      _$BankNameModelFromJson(json);

  Map<String, dynamic> toJson() => _$BankNameModelToJson(this);

  @override
  List<Object?> get props => [name];
}


@JsonSerializable(explicitToJson: true)
class FrequentlyUsedMethodModel extends Equatable {
  final int id;

  @JsonKey(name: 'payment_method')
  final PaymentMethodModel paymentMethod;

  @JsonKey(name: 'payment_bank_name')
  final String? paymentBankName;

  @JsonKey(name: 'payment_account_name')
  final String? paymentAccountName;

  @JsonKey(name: 'payment_account_number')
  final String? paymentAccountNumber;

  @JsonKey(name: 'payment_phone_number')
  final String? paymentPhoneNumber;

  @JsonKey(name: 'payment_person_name')
  final String? paymentPersonName;

  @JsonKey(name: 'payment_person_phone')
  final String? paymentPersonPhone;

  @JsonKey(name: 'render_payment_details')
  final String renderPaymentDetails;

  const FrequentlyUsedMethodModel({
    required this.id,
    required this.paymentMethod,
    this.paymentBankName,
    this.paymentAccountName,
    this.paymentAccountNumber,
    this.paymentPhoneNumber,
    this.paymentPersonName,
    this.paymentPersonPhone,
    required this.renderPaymentDetails,
  });

  factory FrequentlyUsedMethodModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$FrequentlyUsedMethodModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$FrequentlyUsedMethodModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        paymentMethod,
        paymentBankName,
        paymentAccountName,
        paymentAccountNumber,
        paymentPhoneNumber,
        paymentPersonName,
        paymentPersonPhone,
        renderPaymentDetails,
      ];
}
