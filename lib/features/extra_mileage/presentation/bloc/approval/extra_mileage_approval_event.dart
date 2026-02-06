import 'package:equatable/equatable.dart';

abstract class ExtraMileageApprovalEvent extends Equatable {
  const ExtraMileageApprovalEvent();

  @override
  List<Object?> get props => [];
}

class ApproveExtraMileageRequestEvent extends ExtraMileageApprovalEvent {
  final String mileageId;

  const ApproveExtraMileageRequestEvent({required this.mileageId});

  @override
  List<Object?> get props => [mileageId];
}

class DeclineExtraMileageRequestEvent extends ExtraMileageApprovalEvent {
  final String mileageId;

  const DeclineExtraMileageRequestEvent({required this.mileageId});

  @override
  List<Object?> get props => [mileageId];
}
