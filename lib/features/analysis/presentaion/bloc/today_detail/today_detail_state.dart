import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/today_detail_entity.dart';

class TodayDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TodayDetailInitialState extends TodayDetailState {}

class TodayDetailLoadingState extends TodayDetailState {}

class TodayDetailLoadedState extends TodayDetailState {
  final List<TodayDetailEntity> todayDetailList;

  TodayDetailLoadedState({required this.todayDetailList});

  @override
  List<Object?> get props => [todayDetailList];
}

class TodayDetailErrorState extends TodayDetailState {
  final String message;

  TodayDetailErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class TodayDetailEmptyState extends TodayDetailState {}
