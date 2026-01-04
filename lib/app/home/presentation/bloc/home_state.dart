import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/app/home/domain/entities/vendor_stats_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final VendorStatsEntity stats;
  final bool showAmounts;

  const HomeLoaded(this.stats, {this.showAmounts = true});

  @override
  List<Object> get props => [stats, showAmounts];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
