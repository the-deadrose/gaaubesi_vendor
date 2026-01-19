// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/domain/entity/cod_transfer_entity.dart';

part 'cod_transfer_model.g.dart';

/// ---------------- SAFE JSON HELPERS ----------------

int _intFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

String _stringFromJson(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

List<int> _intListFromJson(dynamic value) {
  if (value == null || value is! List) return const [];
  return value.map((e) => _intFromJson(e)).toList();
}

/// ---------------- TOP-LEVEL PAGINATED RESPONSE ----------------

@JsonSerializable()
class CodTransferPaginatedResponse {
  final int count;
  final String? next;
  final String? previous;
  final CodTransferResponseModel results;

  CodTransferPaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory CodTransferPaginatedResponse.fromJson(Map<String, dynamic> json) =>
      _$CodTransferPaginatedResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CodTransferPaginatedResponseToJson(this);

  /// Convert to entity list
  List<CodTransferList> toEntityList() {
    return results.toEntityList();
  }
}

/// ---------------- NESTED RESPONSE MODEL ----------------

@JsonSerializable()
class CodTransferResponseModel {
  final List<CodTransferListModel> results;
  final Map<String, dynamic>? metadata;

  CodTransferResponseModel({
    required this.results,
    this.metadata,
  });

  factory CodTransferResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CodTransferResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CodTransferResponseModelToJson(this);

  /// Convert to entity list
  List<CodTransferList> toEntityList() {
    return results.map((model) => model.toEntity()).toList();
  }
}

/// ---------------- MODEL ----------------

@JsonSerializable()
class CodTransferListModel {
  @JsonKey(fromJson: _intFromJson)
  final int id;

  @JsonKey(fromJson: _stringFromJson)
  final String amount;

  @JsonKey(name: 'payment_id', fromJson: _stringFromJson)
  final String paymentId;

  @JsonKey(fromJson: _stringFromJson)
  final String receiver;

  @JsonKey(fromJson: _stringFromJson)
  final String notes;

  @JsonKey(name: 'collection_mode', fromJson: _stringFromJson)
  final String collectionMode;

  @JsonKey(name: 'created_on', fromJson: _stringFromJson)
  final String createdOn;

  @JsonKey(name: 'created_on_formatted', fromJson: _stringFromJson)
  final String createdOnFormatted;

  @JsonKey(name: 'transfered_on', fromJson: _stringFromJson)
  final String transferedOn;

  @JsonKey(name: 'transfered_on_formatted', fromJson: _stringFromJson)
  final String transferedOnFormatted;

  @JsonKey(name: 'transaction_medium_name', fromJson: _stringFromJson)
  final String transactionMediumName;

  @JsonKey(name: 'order_count', fromJson: _intFromJson)
  final int orderCount;

  @JsonKey(name: 'order_ids', fromJson: _intListFromJson)
  final List<int> orderIds;

  @JsonKey(name: 'amount_before_codt', fromJson: _stringFromJson)
  final String amountBeforeCodt;

  const CodTransferListModel({
    required this.id,
    required this.amount,
    required this.paymentId,
    required this.receiver,
    required this.notes,
    required this.collectionMode,
    required this.createdOn,
    required this.createdOnFormatted,
    required this.transferedOn,
    required this.transferedOnFormatted,
    required this.transactionMediumName,
    required this.orderCount,
    required this.orderIds,
    required this.amountBeforeCodt,
  });

  factory CodTransferListModel.fromJson(Map<String, dynamic> json) =>
      _$CodTransferListModelFromJson(json);

  Map<String, dynamic> toJson() => _$CodTransferListModelToJson(this);

  /// ---------------- ENTITY MAPPER ----------------

  CodTransferList toEntity() {
    return CodTransferList(
      id: id,
      amount: amount,
      paymentId: paymentId,
      receiver: receiver,
      notes: notes,
      collectionMode: collectionMode,
      createdOn: DateTime.tryParse(createdOn) ?? DateTime.now(),
      createdOnFormatted: createdOnFormatted,
      transferedOn: DateTime.tryParse(transferedOn) ?? DateTime.now(),
      transferedOnFormatted: transferedOnFormatted,
      transactionMediumName: transactionMediumName,
      orderCount: orderCount,
      orderIds: orderIds,
      amountBeforeCodt: amountBeforeCodt,
    );
  }
}
