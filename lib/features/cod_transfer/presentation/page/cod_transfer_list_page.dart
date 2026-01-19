import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/domain/entity/cod_transfer_entity.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/presentation/bloc/cod_transfer_bloc.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/presentation/bloc/cod_transfer_event.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/presentation/bloc/cod_transfer_state.dart';

@RoutePage()
class CodTransferListScreen extends StatefulWidget {
  const CodTransferListScreen({super.key});

  @override
  State<CodTransferListScreen> createState() => _CodTransferListScreenState();
}

class _CodTransferListScreenState extends State<CodTransferListScreen> {
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  bool _isFetchingMore = false;

  final List<CodTransferList> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchInitial();
    _scrollController.addListener(_onScroll);
  }

  void _fetchInitial() {
    context.read<CodTransferBloc>().add(
          FetchCodTransferList(page: _page.toString()),
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 120 &&
        !_isFetchingMore) {
      _isFetchingMore = true;
      _page++;

      context.read<CodTransferBloc>().add(
            FetchCodTransferList(page: _page.toString()),
          );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('COD Transfers'),
      ),
      body: BlocConsumer<CodTransferBloc, CodTransferState>(
        listener: (context, state) {
          if (state is CodTransferListLoaded) {
            _items
              ..clear()
              ..addAll(state.codTransferList);
            _isFetchingMore = false;
          }

          if (state is CodTransferListPaginated) {
            _items.addAll(state.codTransferList);
            _isFetchingMore = false;
          }

          if (state is CodTransferListError ||
              state is CodTransferListPaginatingError) {
            _isFetchingMore = false;
          }
        },
        builder: (context, state) {
          if (state is CodTransferListLoading && _items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CodTransferListError && _items.isEmpty) {
            return Center(child: Text(state.message));
          }

          return RefreshIndicator(
            onRefresh: () async {
              _page = 1;
              _items.clear();
              _fetchInitial();
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _items.length + 1,
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  if (state is CodTransferListPaginating) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const SizedBox.shrink();
                }

                return CodTransferCard(item: _items[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

/// ----------------------------------------------------------------------
/// CARD WIDGET
/// ----------------------------------------------------------------------

class CodTransferCard extends StatelessWidget {
  final CodTransferList item;

  const CodTransferCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Amount', item.amount),
            _row('Payment ID', item.paymentId),
            _row('Receiver', item.receiver),
            _row('Orders Count', item.orderCount.toString()),
            _row('Collection Mode', item.collectionMode),
            _row('Transferred On', item.transferedOnFormatted),

            const SizedBox(height: 10),

            /// ORDER IDS
            if (item.orderIds.isNotEmpty) ...[
              const Text(
                'Order IDs',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: item.orderIds.map((id) {
                  return Chip(
                    label: Text(
                      id.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.grey.shade200,
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 10),

            Text(
              item.transactionMediumName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
