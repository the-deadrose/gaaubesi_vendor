import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/entity/frequently_used_and_payment_method_entity.dart';

class FrequentlyUsedPaymentMethodState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FrequentlyUsedPaymentMethodInitial
    extends FrequentlyUsedPaymentMethodState {}

class FrequentlyUsedPaymentMethodLoading
    extends FrequentlyUsedPaymentMethodState {}

class FrequentlyUsedPaymentMethodEmpty
    extends FrequentlyUsedPaymentMethodState {}

class FrequentlyUsedPaymentMethodError
    extends FrequentlyUsedPaymentMethodState {
  final String message;
  FrequentlyUsedPaymentMethodError(this.message);

  @override
  List<Object?> get props => [message];
}

class FrequentlyUsedPaymentMethodLoaded
    extends FrequentlyUsedPaymentMethodState {
  final FrequentlyUsedAndPaymentMethodList frequentlyUsedAndPaymentMethodList;

  FrequentlyUsedPaymentMethodLoaded(this.frequentlyUsedAndPaymentMethodList);

  @override
  List<Object?> get props => [frequentlyUsedAndPaymentMethodList];
}
