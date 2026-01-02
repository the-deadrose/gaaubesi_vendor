import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/di/injection.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/order_detail_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/cards/order_card_actions.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/common/card_action_button.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/order_detail/order_detail_header.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/order_detail/order_detail_info_tile.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/order_detail/order_detail_section.dart';

@RoutePage()
class OrderDetailPage extends StatelessWidget {
  final int orderId;

  const OrderDetailPage({
    super.key,
    @PathParam('orderId') required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OrderDetailBloc>()
        ..add(OrderDetailRequested(orderId: orderId)),
      child: const _OrderDetailView(),
    );
  }
}

class _OrderDetailView extends StatefulWidget {
  const _OrderDetailView();

  @override
  State<_OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<_OrderDetailView>
    with OrderCardActionsMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: true,
        elevation: 0,
        actions: [
          BlocBuilder<OrderDetailBloc, OrderDetailState>(
            builder: (context, state) {
              if (state is OrderDetailLoaded) {
                return IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () {
                    context.read<OrderDetailBloc>().add(
                          OrderDetailRefreshRequested(
                            orderId: state.order.orderId,
                          ),
                        );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<OrderDetailBloc, OrderDetailState>(
        builder: (context, state) {
          if (state is OrderDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrderDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load order',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<OrderDetailBloc>().add(
                            OrderDetailRequested(
                              orderId: int.parse(
                                context.router.current.params
                                    .getString('orderId', '0'),
                              ),
                            ),
                          );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is OrderDetailLoaded) {
            return _buildContent(context, state.order);
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocBuilder<OrderDetailBloc, OrderDetailState>(
        builder: (context, state) {
          if (state is OrderDetailLoaded) {
            return _buildActionBar(context, state.order);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, OrderDetailEntity order) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderDetailBloc>().add(
              OrderDetailRefreshRequested(orderId: order.orderId),
            );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            OrderDetailHeader(order: order),
            _buildReceiverSection(order),
            _buildDeliverySection(order),
            _buildChargesSection(order),
            _buildPackageSection(order),
            _buildTimelineSection(order),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiverSection(OrderDetailEntity order) {
    return OrderDetailSection(
      title: 'Receiver Information',
      icon: Icons.person_rounded,
      iconColor: Colors.blue,
      child: Column(
        children: [
          OrderDetailInfoTile(
            label: 'Name',
            value: order.receiver,
            icon: Icons.person_outline_rounded,
          ),
          OrderDetailInfoTile(
            label: 'Phone',
            value: order.receiverNumber,
            icon: Icons.phone_rounded,
            onTap: () => makePhoneCall(order.receiverNumber),
          ),
          if (order.altReceiverNumber?.isNotEmpty == true)
            OrderDetailInfoTile(
              label: 'Alt. Phone',
              value: order.altReceiverNumber!,
              icon: Icons.phone_android_rounded,
              onTap: () => makePhoneCall(order.altReceiverNumber!),
            ),
          OrderDetailInfoTile(
            label: 'Address',
            value: order.receiverAddress,
            icon: Icons.location_on_rounded,
            onTap: () => openMaps(order.receiverAddress),
          ),
          if (order.orderContactName?.isNotEmpty == true)
            OrderDetailInfoTile(
              label: 'Contact Person',
              value: order.orderContactName!,
              icon: Icons.contact_phone_rounded,
            ),
        ],
      ),
    );
  }

  Widget _buildDeliverySection(OrderDetailEntity order) {
    return OrderDetailSection(
      title: 'Delivery Details',
      icon: Icons.local_shipping_rounded,
      iconColor: Colors.teal,
      child: Column(
        children: [
          OrderDetailInfoTile(
            label: 'From',
            value: order.sourceBranch,
            icon: Icons.store_rounded,
          ),
          OrderDetailInfoTile(
            label: 'To',
            value: order.destinationBranch,
            icon: Icons.location_city_rounded,
          ),
          if (order.orderDeliveryInstruction?.isNotEmpty == true)
            OrderDetailInfoTile(
              label: 'Instructions',
              value: order.orderDeliveryInstruction!,
              icon: Icons.info_outline_rounded,
            ),
        ],
      ),
    );
  }

  Widget _buildChargesSection(OrderDetailEntity order) {
    return OrderDetailSection(
      title: 'Charges & Payment',
      icon: Icons.payments_rounded,
      iconColor: Colors.green,
      child: Column(
        children: [
          OrderDetailInfoRow(
            label1: 'COD Amount',
            value1: 'Rs. ${order.codCharge.toStringAsFixed(2)}',
            value1Color: Colors.green,
            label2: 'Delivery Charge',
            value2: 'Rs. ${order.deliveryCharge.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          OrderDetailInfoRow(
            label1: 'COD Status',
            value1: order.codPaid,
            value1Color: order.codPaid.toLowerCase().contains('pending')
                ? Colors.orange
                : Colors.green,
            label2: 'Payment',
            value2: order.paymentCollection,
            value2Color: order.paymentCollection.toLowerCase().contains('pending')
                ? Colors.orange
                : Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildPackageSection(OrderDetailEntity order) {
    return OrderDetailSection(
      title: 'Package Info',
      icon: Icons.inventory_2_rounded,
      iconColor: Colors.purple,
      child: Column(
        children: [
          OrderDetailInfoTile(
            label: 'Description',
            value: order.description,
            icon: Icons.description_rounded,
          ),
          if (order.vendorReferenceId?.isNotEmpty == true)
            OrderDetailInfoTile(
              label: 'Reference ID',
              value: order.vendorReferenceId!,
              icon: Icons.tag_rounded,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(OrderDetailEntity order) {
    return OrderDetailSection(
      title: 'Timeline',
      icon: Icons.schedule_rounded,
      iconColor: Colors.indigo,
      child: Column(
        children: [
          OrderDetailInfoTile(
            label: 'Created On',
            value: order.createdOn,
            icon: Icons.event_rounded,
          ),
          OrderDetailInfoTile(
            label: 'Created By',
            value: order.createdBy,
            icon: Icons.person_add_rounded,
          ),
          OrderDetailInfoTile(
            label: 'Last Updated',
            value: order.lastUpdated,
            icon: Icons.update_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, OrderDetailEntity order) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: CardActionButton(
                icon: Icons.call_rounded,
                label: 'Call',
                onTap: () => makePhoneCall(order.receiverNumber),
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CardActionButton(
                icon: Icons.map_rounded,
                label: 'Track',
                onTap: () => openMaps(order.receiverAddress),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CardActionButton(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () => shareOrder(order.orderId.toString()),
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
