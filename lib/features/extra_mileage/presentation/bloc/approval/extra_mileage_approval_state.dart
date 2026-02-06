import 'package:equatable/equatable.dart';

class ExtraMileageApprovalState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExtraMileageApprovalInitialState extends ExtraMileageApprovalState {}

class ExtraMileageApprovalLoadingState extends ExtraMileageApprovalState {}

class ExtraMileageApprovedSuccessState extends ExtraMileageApprovalState {
  final String message;

  ExtraMileageApprovedSuccessState({
    this.message = 'Extra mileage approved successfully',
  });

  @override
  List<Object?> get props => [message];
}

class ExtraMileageDeclinedSuccessState extends ExtraMileageApprovalState {
  final String message;

  ExtraMileageDeclinedSuccessState({
    this.message = 'Extra mileage declined successfully',
  });

  @override
  List<Object?> get props => [message];
}

class ExtraMileageApprovalErrorState extends ExtraMileageApprovalState {
  final String message;

  ExtraMileageApprovalErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
