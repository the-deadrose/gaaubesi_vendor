import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/di/injection.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_state.dart';
import 'package:gaaubesi_vendor/features/home/domain/entities/vendor_stats_entity.dart';
import 'package:gaaubesi_vendor/features/home/presentation/bloc/home_bloc.dart';
import 'package:gaaubesi_vendor/features/home/presentation/bloc/home_event.dart';
import 'package:gaaubesi_vendor/features/home/presentation/bloc/home_state.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeBloc>()..add(const HomeLoadStats()),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          title: const Text(
            'Dashboard',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {
                context.router.push(const NoticeListRoute());
              },
            ),
          ],
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            if (authState is AuthUnauthenticated) {
              context.router.replace(const LoginRoute());
            }
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return _buildLoadingState();
              }
              if (state is HomeError) {
                return _buildErrorState(context, state.message);
              }
              if (state is HomeLoaded) {
                return _buildLoadedState(context, state.stats);
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildShimmerCard(height: 120),
        const SizedBox(height: 16),
        _buildShimmerCard(height: 80),
        const SizedBox(height: 16),
        _buildShimmerCard(height: 200),
        const SizedBox(height: 16),
        _buildShimmerCard(height: 150),
      ],
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<HomeBloc>().add(const HomeLoadStats()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, VendorStatsEntity stats) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const HomeRefreshStats());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _WelcomeCard(
            vendorName: stats.vendorName,
            onAddTicket: () {
              context.router.push(const CreateTicketRoute());
            },
            onCodRequest: () {
              context.router.push(const PaymentRequestRoute());
            },
            onAddOrder: () {
              context.router.push(const CreateOrderRoute());
            },
          ),
          const SizedBox(height: 16),

          _StatCard(
            title: 'Pending COD',
            value: 'Rs. ${_formatCurrency(stats.pendingCod)}',
            icon: Icons.account_balance_wallet,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Success Rate',
                  value: '${stats.successPercent.toStringAsFixed(1)}%',
                  icon: Icons.trending_up,
                  color: AppTheme.successGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  title: 'Return Rate',
                  value: '${stats.returnPercent.toStringAsFixed(1)}%',
                  icon: Icons.trending_down,
                  color: AppTheme.warningYellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _ActivityCard(stats: stats),
          const SizedBox(height: 16),

          _ProcessingCard(stats: stats),
          const SizedBox(height: 16),

          _PackagesCard(stats: stats),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String vendorName;
  final VoidCallback onAddTicket;
  final VoidCallback onCodRequest;
  final VoidCallback onAddOrder;

  const _WelcomeCard({
    required this.vendorName,
    required this.onAddTicket,
    required this.onCodRequest,
    required this.onAddOrder,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  vendorName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: Colors.blue,
            onPressed: () async {
              final result = await showMenu<String>(
                context: context,
                position: const RelativeRect.fromLTRB(100, 80, 16, 0),
                items: const [
                  PopupMenuItem(
                    value: 'ticket',
                    child: Row(
                      children: [
                        Icon(Icons.confirmation_number_outlined),
                        SizedBox(width: 8),
                        Text('Add Tickets'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'cod',
                    child: Row(
                      children: [
                        Icon(Icons.payment),
                        SizedBox(width: 8),
                        Text('COD Request'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: '0rder',
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping_outlined),
                        SizedBox(width: 8),
                        Text('Add Order'),
                      ],
                    ),
                  ),
                ],
              );

              if (result == 'ticket') {
                onAddTicket();
              }  if (result == 'cod') {
                onCodRequest();
              } if (result == '0rder') {
                onAddOrder();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final VendorStatsEntity stats;

  const _ActivityCard({required this.stats});

  void _navigateToComments(BuildContext context) {
    context.router.push(CommentsRoute(initialTab: 0));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Activity",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _ActivityItem(
                label: 'Orders Created',
                value: stats.todayOrderCreated.toString(),
                color: AppTheme.infoBlue,
              ),
              _ActivityItem(
                label: 'Deliveries',
                value: stats.todayDelivery.toString(),
                color: AppTheme.successGreen,
              ),
              _ActivityItem(
                label: 'Returns',
                value: stats.todaysReturnedDelivery.toString(),
                color: AppTheme.rojo,
              ),
              GestureDetector(
                onTap: () => _navigateToComments(context),
                child: _ActivityItem(
                  label: 'Comments',
                  value: stats.todaysComment.toString(),
                  color: AppTheme.marianBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ActivityItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessingCard extends StatelessWidget {
  final VendorStatsEntity stats;

  const _ProcessingCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final processing = stats.processingOrders;
    final totalProcessing =
        processing.dropOff +
        processing.pickup +
        processing.dispatch +
        processing.hold;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Processing',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                '$totalProcessing orders',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _ProcessingItem(
                label: 'Drop Off',
                count: processing.dropOff,
                total: totalProcessing,
              ),
              _ProcessingItem(
                label: 'Pickup',
                count: processing.pickup,
                total: totalProcessing,
              ),
              _ProcessingItem(
                label: 'Dispatch',
                count: processing.dispatch,
                total: totalProcessing,
              ),
              if (processing.hold > 0)
                _ProcessingItem(
                  label: 'On Hold',
                  count: processing.hold,
                  total: totalProcessing,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProcessingItem extends StatelessWidget {
  final String label;
  final int count;
  final int total;

  const _ProcessingItem({
    required this.label,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PackagesCard extends StatelessWidget {
  final VendorStatsEntity stats;

  const _PackagesCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Packages Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.totalPackages.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Packages',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.deliveredPackages.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Delivered',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatCurrency(double amount) {
  if (amount >= 10000000) {
    return '${(amount / 10000000).toStringAsFixed(1)}Cr';
  } else if (amount >= 100000) {
    return '${(amount / 100000).toStringAsFixed(1)}L';
  } else if (amount >= 1000) {
    return '${(amount / 1000).toStringAsFixed(1)}K';
  }
  return amount.toStringAsFixed(0);
}
