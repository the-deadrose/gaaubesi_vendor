import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/daily_transections/domain/entity/daily_transections_entity.dart';

class DailyTransactionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DailyTransactionListInitial extends DailyTransactionState {}

class DailyTransactionListLoading extends DailyTransactionState {}

class DailyTransactionListLoaded extends DailyTransactionState {
  final List<DailyTransections> dailyTransections;
  DailyTransactionListLoaded({required this.dailyTransections});

  @override
  List<Object?> get props => [dailyTransections];
}

class DailyTransactionListError extends DailyTransactionState {
  final String message;
  DailyTransactionListError({required this.message});

  @override
  List<Object?> get props => [message];
}
