import 'package:gaaubesi_vendor/features/payments/domain/entity/payment_request_list_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_request_list_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PaymentRequestListModel extends PaymentRequestList {
  @JsonKey(name: 'payment_methods')
  final List<PaymentMethodModel> paymentMethodsModel;

  @JsonKey(name: 'bank_names')
  final List<BankNameModel> bankNamesModel;

  @JsonKey(name: 'frequently_used_methods')
  final List<FrequentlyUsedMethodModel> frequentlyUsedMethodsModel;

  const PaymentRequestListModel({
    required this.paymentMethodsModel,
    required this.bankNamesModel,
    required this.frequentlyUsedMethodsModel,
  }) : super(
          paymentMethods: paymentMethodsModel,
          bankNames: bankNamesModel,
          frequentlyUsedMethods: frequentlyUsedMethodsModel,
        );

  factory PaymentRequestListModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestListModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentRequestListModelToJson(this);
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
  const BankNameModel({
    required super.name,
  });

  factory BankNameModel.fromJson(Map<String, dynamic> json) =>
      _$BankNameModelFromJson(json);

  Map<String, dynamic> toJson() => _$BankNameModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FrequentlyUsedMethodModel extends FrequentlyUsedMethodEntity {
  @JsonKey(name: 'payment_method')
  @override
  PaymentMethodModel get paymentMethod => super.paymentMethod as PaymentMethodModel;

  @JsonKey(name: 'payment_bank_name')
  @override
  String? get paymentBankName => super.paymentBankName;

  @JsonKey(name: 'payment_account_name')
  @override
  String? get paymentAccountName => super.paymentAccountName;

  @JsonKey(name: 'payment_account_number')
  @override
  String? get paymentAccountNumber => super.paymentAccountNumber;

  @JsonKey(name: 'payment_phone_number')
  @override
  String? get paymentPhoneNumber => super.paymentPhoneNumber;

  @JsonKey(name: 'payment_person_name')
  @override
  String? get paymentPersonName => super.paymentPersonName;

  @JsonKey(name: 'payment_person_phone')
  @override
  String? get paymentPersonPhone => super.paymentPersonPhone;

  @JsonKey(name: 'render_payment_details')
  @override
  String get renderPaymentDetails => super.renderPaymentDetails;

  const FrequentlyUsedMethodModel({
    required super.id,
    required PaymentMethodModel paymentMethod,
    super.paymentBankName,
    super.paymentAccountName,
    super.paymentAccountNumber,
    super.paymentPhoneNumber,
    super.paymentPersonName,
    super.paymentPersonPhone,
    required super.renderPaymentDetails,
  }) : super(paymentMethod: paymentMethod);

  factory FrequentlyUsedMethodModel.fromJson(Map<String, dynamic> json) =>
      _$FrequentlyUsedMethodModelFromJson(json);

  Map<String, dynamic> toJson() => _$FrequentlyUsedMethodModelToJson(this);
}