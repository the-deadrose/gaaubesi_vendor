import 'package:equatable/equatable.dart';

abstract class SalesReportAnalysisEvent extends Equatable {
  const SalesReportAnalysisEvent();

  @override
  List<Object?> get props => [];
}

class FetchSalesReportAnalysisEvent extends SalesReportAnalysisEvent {
  final String startDate;
  final String endDate;

  const FetchSalesReportAnalysisEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class ResetSalesReportAnalysisEvent extends SalesReportAnalysisEvent {
  const ResetSalesReportAnalysisEvent();

  @override
  List<Object?> get props => [];
}
