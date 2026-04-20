import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoadStats extends HomeEvent {
  const HomeLoadStats();
}

class HomeRefreshStats extends HomeEvent {
  final Completer<void>? completer;
  const HomeRefreshStats({this.completer});

  @override
  List<Object?> get props => [completer];
}
