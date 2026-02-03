import 'package:equatable/equatable.dart';

abstract class DeliveryReportAnalysisEvent extends Equatable {
  const DeliveryReportAnalysisEvent();

  @override
  List<Object?> get props => [];
}

class FetchDeliveryReportAnalysisEvent extends DeliveryReportAnalysisEvent {
  final String startDate;
  final String endDate;

  const FetchDeliveryReportAnalysisEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class ResetDeliveryReportAnalysisEvent extends DeliveryReportAnalysisEvent {
  const ResetDeliveryReportAnalysisEvent();

  @override
  List<Object?> get props => [];
}
