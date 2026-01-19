import 'package:equatable/equatable.dart';

abstract class CodTransferEvent extends Equatable {
  const CodTransferEvent();

  @override
  List<Object?> get props => [];
}

class FetchCodTransferList extends CodTransferEvent {
  final String page;

  const FetchCodTransferList({required this.page});

  @override
  List<Object?> get props => [page];
}
