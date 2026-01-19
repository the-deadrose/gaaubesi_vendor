import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/daily_transections/domain/entity/daily_transections_entity.dart';
import 'package:gaaubesi_vendor/features/daily_transections/presentation/bloc/daily_transaction_bloc.dart';
import 'package:gaaubesi_vendor/features/daily_transections/presentation/bloc/daily_transaction_event.dart';
import 'package:gaaubesi_vendor/features/daily_transections/presentation/bloc/daily_transaction_state.dart';

@RoutePage()
class DailyTransactionScreen extends StatefulWidget {
  final String? date;

  const DailyTransactionScreen({super.key, @QueryParam() this.date});

  @override
  State<DailyTransactionScreen> createState() =>
      _DailyTransactionScreenState();
}

class _DailyTransactionScreenState extends State<DailyTransactionScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<DailyTransactionBloc>()
        .add(FetchDailyTransactionEvent(date: widget.date ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Transactions${widget.date != null ? ' (${widget.date})' : ''}'),
      ),
      body: BlocConsumer<DailyTransactionBloc, DailyTransactionState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is DailyTransactionListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DailyTransactionListError) {
            return Center(child: Text(state.message));
          }

          if (state is DailyTransactionListLoaded) {
            final dailyList = state.dailyTransections;

            if (dailyList.isEmpty) {
              return const Center(child: Text('No transactions found for this date'));
            }

            final daily = dailyList.first;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DailyTransactionBloc>().add(
                    FetchDailyTransactionEvent(date: widget.date.toString()));
              },
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _summaryCard(daily),
                  const SizedBox(height: 12),
                  _ordersSection('Delivered Orders', daily.deliveredOrders),
                  const SizedBox(height: 12),
                  _ordersSection('Returned Orders', daily.returnedOrders),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// ---------------- SUMMARY CARD ----------------
  Widget _summaryCard(DailyTransections daily) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row('COD Transfer Total', daily.codTransferTotal),
            _row('Delivered Orders', daily.deliveredOrdersCount.toString()),
            _row('Returned Orders', daily.returnedOrdersCount.toString()),
            _row('Total COD Delivered', daily.totalCodChargeDelivered),
            _row('Total Delivery Delivered', daily.totalDeliveryChargeDelivered),
            _row('Total COD Returned', daily.totalCodChargeReturned),
            _row('Total Delivery Returned', daily.totalDeliveryChargeReturned),
          ],
        ),
      ),
    );
  }

  /// ---------------- ORDERS SECTION ----------------
  Widget _ordersSection(String title, List<DailyOrder> orders) {
    if (orders.isEmpty) {
      return Text('$title: No orders', style: const TextStyle(fontSize: 16));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...orders.map((order) => _orderCard(order)),
      ],
    );
  }

  /// ---------------- ORDER CARD ----------------
  Widget _orderCard(DailyOrder order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _row('Order ID', order.orderId.toString()),
            _row('COD Charge', order.codCharge),
            _row('Delivery Charge', order.deliveryCharge),
            _row('Delivered On', order.deliveredDateFormatted),
          ],
        ),
      ),
    );
  }

  /// ---------------- ROW WIDGET ----------------
  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style:  TextStyle(color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
