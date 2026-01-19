import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/domain/entity/cod_transfer_entity.dart';

class CodTransferState extends Equatable {
  const CodTransferState();

  @override
  List<Object?> get props => [];
}

class CodTransferListInitial extends CodTransferState {
  const CodTransferListInitial();
}

class CodTransferListLoading extends CodTransferState {
  const CodTransferListLoading();
}

class CodTransferListLoaded extends CodTransferState {
  final List<CodTransferList> codTransferList;
  const CodTransferListLoaded({required this.codTransferList});
  @override
  List<Object?> get props => [codTransferList];
}

class CodTransferListError extends CodTransferState {
  final String message;
  const CodTransferListError({required this.message});
  @override
  List<Object?> get props => [message];
}

class CodTransferListPaginating extends CodTransferState {
  const CodTransferListPaginating();
}

class CodTransferListPaginatingError extends CodTransferState {
  final String message;
  const CodTransferListPaginatingError({required this.message});
  @override
  List<Object?> get props => [message];
}

class CodTransferListPaginated extends CodTransferState {
  final List<CodTransferList> codTransferList;
  const CodTransferListPaginated({required this.codTransferList});
  @override
  List<Object?> get props => [codTransferList];
}
