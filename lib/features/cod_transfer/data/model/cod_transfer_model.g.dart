// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cod_transfer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodTransferPaginatedResponse _$CodTransferPaginatedResponseFromJson(
  Map<String, dynamic> json,
) => CodTransferPaginatedResponse(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results: CodTransferResponseModel.fromJson(
    json['results'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$CodTransferPaginatedResponseToJson(
  CodTransferPaginatedResponse instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};

CodTransferResponseModel _$CodTransferResponseModelFromJson(
  Map<String, dynamic> json,
) => CodTransferResponseModel(
  results: (json['results'] as List<dynamic>)
      .map((e) => CodTransferListModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$CodTransferResponseModelToJson(
  CodTransferResponseModel instance,
) => <String, dynamic>{
  'results': instance.results,
  'metadata': instance.metadata,
};

CodTransferListModel _$CodTransferListModelFromJson(
  Map<String, dynamic> json,
) => CodTransferListModel(
  id: _intFromJson(json['id']),
  amount: _stringFromJson(json['amount']),
  paymentId: _stringFromJson(json['payment_id']),
  receiver: _stringFromJson(json['receiver']),
  notes: _stringFromJson(json['notes']),
  collectionMode: _stringFromJson(json['collection_mode']),
  createdOn: _stringFromJson(json['created_on']),
  createdOnFormatted: _stringFromJson(json['created_on_formatted']),
  transferedOn: _stringFromJson(json['transfered_on']),
  transferedOnFormatted: _stringFromJson(json['transfered_on_formatted']),
  transactionMediumName: _stringFromJson(json['transaction_medium_name']),
  orderCount: _intFromJson(json['order_count']),
  orderIds: _intListFromJson(json['order_ids']),
  amountBeforeCodt: _stringFromJson(json['amount_before_codt']),
);

Map<String, dynamic> _$CodTransferListModelToJson(
  CodTransferListModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'payment_id': instance.paymentId,
  'receiver': instance.receiver,
  'notes': instance.notes,
  'collection_mode': instance.collectionMode,
  'created_on': instance.createdOn,
  'created_on_formatted': instance.createdOnFormatted,
  'transfered_on': instance.transferedOn,
  'transfered_on_formatted': instance.transferedOnFormatted,
  'transaction_medium_name': instance.transactionMediumName,
  'order_count': instance.orderCount,
  'order_ids': instance.orderIds,
  'amount_before_codt': instance.amountBeforeCodt,
};
