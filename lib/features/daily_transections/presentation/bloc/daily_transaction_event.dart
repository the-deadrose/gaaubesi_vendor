import 'package:equatable/equatable.dart';

abstract class DailyTransactionEvent extends Equatable {
  const DailyTransactionEvent();

  @override
  List<Object?> get props => [];
}

class FetchDailyTransactionEvent extends DailyTransactionEvent {
  final String date;

  const FetchDailyTransactionEvent({required this.date});

  @override
  List<Object?> get props => [date];
}
