import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/configure/theme/theme.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/today_detail_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/today_detail/today_detail_bloc.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/today_detail/today_detail_event.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/today_detail/today_detail_state.dart';

@RoutePage()
class TodayDetailScreen extends StatefulWidget {
  const TodayDetailScreen({super.key});

  @override
  State<TodayDetailScreen> createState() => _TodayDetailScreenState();
}

class _TodayDetailScreenState extends State<TodayDetailScreen> {
  String _selectedStatus = 'today_orders';

  final List<StatusChip> _statusChips = [
    StatusChip(label: 'Today Orders', value: 'today_orders'),
    StatusChip(label: 'Delivered', value: 'delivered_orders'),
    StatusChip(label: 'RTV Orders', value: 'rtv_orders'),
    StatusChip(label: 'Pending', value: 'pending_orders'),
    StatusChip(label: 'Return Delivered', value: 'returned_delivered_orders'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodayDetailBloc>().add(
        FetchTodayDetailEvent(status: _selectedStatus),
      );
    });
  }

  void _onStatusChanged(String status) {
    setState(() {
      _selectedStatus = status;
    });
    context.read<TodayDetailBloc>().add(FetchTodayDetailEvent(status: status));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteSmoke,
      appBar: AppBar(
        backgroundColor: AppTheme.marianBlue,
        foregroundColor: AppTheme.whiteSmoke,
        title: const Text('Today\'s Order Details'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Status Filter Section
          _buildStatusFilterSection(),
          const SizedBox(height: 8),

          // Content
          Expanded(
            child: BlocBuilder<TodayDetailBloc, TodayDetailState>(
              builder: (context, state) {
                return _buildContentBasedOnState(state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        
      ),
      margin: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_alt,
                size: 20,
                color: AppTheme.marianBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Filter by Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.blackBean,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '5 statuses',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Scrollable Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _statusChips.length,
              itemBuilder: (context, index) {
                final chip = _statusChips[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      chip.label,
                      style: TextStyle(
                        color: _selectedStatus == chip.value
                            ? Colors.white
                            : AppTheme.darkGray,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: _selectedStatus == chip.value,
                    onSelected: (selected) => _onStatusChanged(chip.value),
                    selectedColor: AppTheme.marianBlue,
                    backgroundColor: AppTheme.lightGray,
                    side: BorderSide(
                      color: AppTheme.powerBlue.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: _selectedStatus == chip.value ? 2 : 0,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBasedOnState(TodayDetailState state) {
    if (state is TodayDetailLoadingState) {
      return _buildShimmerLoading();
    } else if (state is TodayDetailLoadedState) {
      return _buildOrderListView(state.todayDetailList);
    } else if (state is TodayDetailEmptyState) {
      return _buildEmptyView();
    } else if (state is TodayDetailErrorState) {
      return _buildErrorView(state.message);
    }
    return _buildInitialView();
  }

  Widget _buildInitialView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppTheme.powerBlue.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a status to view order details',
              style: TextStyle(fontSize: 16, color: AppTheme.darkGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 20,
                      width: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 20,
                      width: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderListView(List<TodayDetailEntity> orders) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TodayDetailBloc>().add(
          RefreshTodayDetailEvent(status: _selectedStatus),
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(TodayDetailEntity order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getStatusColor(
              order.lastDeliveryStatus,
            ).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(order.lastDeliveryStatus),
            size: 20,
            color: _getStatusColor(order.lastDeliveryStatus),
          ),
        ),
        title: Text(
          'Order #${order.orderId}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.blackBean,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              order.receiverName,
              style: TextStyle(fontSize: 13, color: AppTheme.darkGray),
            ),
            const SizedBox(height: 2),
            Text(
              order.receiverAddress.length > 40
                  ? '${order.receiverAddress.substring(0, 40)}...'
                  : order.receiverAddress,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.darkGray.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(
              order.lastDeliveryStatus,
            ).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getStatusColor(
                order.lastDeliveryStatus,
              ).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            order.lastDeliveryStatus,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(order.lastDeliveryStatus),
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID and SN
                _buildDetailRow('Order ID', '${order.orderId}'),
                _buildDetailRow('S/N', '${order.sN}'),
                const SizedBox(height: 12),

                // Branch Information
                _buildSectionHeader('Branch Information'),
                _buildDetailRow('Source Branch', order.sourceBranch),
                _buildDetailRow('Destination Branch', order.destinationBranch),
                const SizedBox(height: 12),

                // Receiver Information
                _buildSectionHeader('Receiver Information'),
                _buildDetailRow('Receiver Name', order.receiverName),
                _buildDetailRow('Receiver Address', order.receiverAddress),
                const SizedBox(height: 12),

                // Payment Information
                _buildSectionHeader('Payment Information'),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        'Delivery Charge',
                        order.deliveryCharge,
                      ),
                    ),
                    Expanded(child: _buildDetailRow('COD Amount', order.cod)),
                  ],
                ),
                const SizedBox(height: 12),

                // Order Status
                _buildSectionHeader('Order Status'),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        'Status',
                        order.lastDeliveryStatus,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailRow(
                        'Created',
                        '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.marianBlue,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.blackBean,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppTheme.marianBlue.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No Orders Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.blackBean,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no orders in ${_getStatusLabel(_selectedStatus)} at the moment.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
            ),
            const SizedBox(height: 24),
            Text(
              '✓ Check back later for updates',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.marianBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppTheme.rojo),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.rojo,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TodayDetailBloc>().add(
                  FetchTodayDetailEvent(status: _selectedStatus),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.marianBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return AppTheme.successGreen;
      case 'pending':
        return Colors.orange;
      case 'rtv':
      case 'returned':
        return AppTheme.rojo;
      case 'processing':
        return AppTheme.infoBlue;
      default:
        return AppTheme.marianBlue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'rtv':
      case 'returned':
        return Icons.undo;
      case 'processing':
        return Icons.autorenew;
      default:
        return Icons.inventory;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'today_orders':
        return 'Today Orders';
      case 'delivered_orders':
        return 'Delivered Orders';
      case 'rtv_orders':
        return 'RTV Orders';
      case 'pending_orders':
        return 'Pending Orders';
      case 'returned_delivered_orders':
        return 'Return Delivered Orders';
      default:
        return 'Orders';
    }
  }
}

class StatusChip {
  final String label;
  final String value;

  StatusChip({required this.label, required this.value});
}
