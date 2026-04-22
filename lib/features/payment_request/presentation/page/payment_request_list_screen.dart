import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/configure/theme/theme.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/entity/payment_request_list_entity.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/payment_request/payment_request_bloc.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/payment_request/payment_request_event.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/payment_request/payment_request_state.dart';

@RoutePage()
class PaymentRequestListScreen extends StatefulWidget {
  const PaymentRequestListScreen({super.key});

  @override
  State<PaymentRequestListScreen> createState() =>
      _PaymentRequestListScreenState();
}

class _PaymentRequestListScreenState extends State<PaymentRequestListScreen> {
  final _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  String _selectedStatus = 'all';
  String _selectedPaymentMethod = 'all';
  String _selectedBankName = 'all';
  List<PaymentMethodEntity> _paymentMethods = [];
  List<BankNameEntity> _bankNames = [];

  @override
  void initState() {
    super.initState();
    _fetchPaymentRequests();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchPaymentRequests({bool loadMore = false}) {
    if (!loadMore) {
      _currentPage = 1;
    }

    context.read<PaymentRequestBloc>().add(
      FetchPaymentRequestsEvent(
        page: _currentPage.toString(),
        status: _selectedStatus,
        paymentMethod: _selectedPaymentMethod,
        bankName: _selectedBankName,
      ),
    );
  }

  void _onScroll() {
    if (_isLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final delta = 200.0;

    if (maxScroll - currentScroll <= delta) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    final state = context.read<PaymentRequestBloc>().state;
    if (state is FetchPaymentRequestsSuccess) {
      if (state.paymentRequestList.next != null) {
        setState(() {
          _isLoadingMore = true;
          _currentPage++;
        });
        _fetchPaymentRequests(loadMore: true);
      }
    }
  }

  void _showFiltersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _FiltersBottomSheet(
          selectedStatus: _selectedStatus,
          selectedPaymentMethod: _selectedPaymentMethod,
          selectedBankName: _selectedBankName,
          paymentMethods: _paymentMethods,
          bankNames: _bankNames,
          onApply: (status, paymentMethod, bankName) {
            setState(() {
              _selectedStatus = status;
              _selectedPaymentMethod = paymentMethod;
              _selectedBankName = bankName;
            });
            _fetchPaymentRequests();
          },
        );
      },
    );
  }

  bool get _hasActiveFilters =>
      _selectedStatus != 'all' ||
      _selectedPaymentMethod != 'all' ||
      _selectedBankName != 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final bgColor = isDarkMode
        ? const Color(0xFF0F1115)
        : const Color(0xFFF6F7FB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Payment Requests',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          _buildActionButton(
            icon: Icons.tune_rounded,
            badge: _hasActiveFilters,
            onPressed: _showFiltersDialog,
          ),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: _buildFab(theme),
      body: BlocConsumer<PaymentRequestBloc, PaymentRequestState>(
        listener: (context, state) {
          if (state is FetchPaymentRequestsSuccess) {
            setState(() {
              _paymentMethods = state.paymentRequestList.paymentMethods;
              _bankNames = state.paymentRequestList.bankNames;
            });
          }

          if (state is FetchPaymentRequestsSuccess && _isLoadingMore) {
            setState(() {
              _isLoadingMore = false;
            });
          }
        },
        builder: (context, state) {
          if (state is FetchPaymentRequestsLoading && !_isLoadingMore) {
            return _buildLoadingShimmer();
          }

          if (state is FetchPaymentRequestsFailure) {
            return _buildErrorState(state.error);
          }

          if (state is PaymentRequestListEmpty) {
            return _buildEmptyState();
          }

          if (state is FetchPaymentRequestsSuccess) {
            return _buildPaymentRequestList(state.paymentRequestList);
          }

          if (state is CreatePaymentRequestLoading) {
            return _buildLoadingState();
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildFab(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final created = await context.router.push(const PaymentRequestRoute());
        if (created == true && mounted) {
          _fetchPaymentRequests();
        }
      },
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 4,
      icon: const Icon(Icons.add_rounded, size: 22),
      label: const Text(
        'New Request',
        style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool badge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(icon, size: 20),
              padding: EdgeInsets.zero,
            ),
          ),
          if (badge)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentRequestList(PaymentRequestListEntity paymentRequestList) {
    return RefreshIndicator(
      onRefresh: () async {
        _fetchPaymentRequests();
      },
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdjacent(child: _buildStatsSummary(paymentRequestList)),
          if (_hasActiveFilters)
            SliverToBoxAdjacent(child: _buildActiveFilters()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            sliver: paymentRequestList.results.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildFilteredEmptyState(),
                  )
                : SliverList.separated(
                    itemCount:
                        paymentRequestList.results.length +
                        (_isLoadingMore ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index >= paymentRequestList.results.length) {
                        return _buildLoadMoreIndicator();
                      }

                      final request = paymentRequestList.results[index];
                      return _PaymentRequestCard(request: request);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (_selectedStatus != 'all')
                    _buildActiveFilterChip(
                      label:
                          _selectedStatus[0].toUpperCase() +
                          _selectedStatus.substring(1),
                      onRemove: () {
                        setState(() => _selectedStatus = 'all');
                        _fetchPaymentRequests();
                      },
                    ),
                  if (_selectedPaymentMethod != 'all')
                    _buildActiveFilterChip(
                      label: 'Method',
                      onRemove: () {
                        setState(() => _selectedPaymentMethod = 'all');
                        _fetchPaymentRequests();
                      },
                    ),
                  if (_selectedBankName != 'all')
                    _buildActiveFilterChip(
                      label: _selectedBankName,
                      onRemove: () {
                        setState(() => _selectedBankName = 'all');
                        _fetchPaymentRequests();
                      },
                    ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatus = 'all';
                _selectedPaymentMethod = 'all';
                _selectedBankName = 'all';
              });
              _fetchPaymentRequests();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Clear',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(PaymentRequestListEntity paymentRequestList) {
    final pendingCount = paymentRequestList.results
        .where((request) => request.status == 'pending')
        .length;

    final declinedCount = paymentRequestList.results
        .where((request) => request.status == 'declined')
        .length;

    final settledCount = paymentRequestList.results
        .where((request) => request.status == 'settled')
        .length;

    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.insights_rounded, size: 18, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).extra.darkGray,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${paymentRequestList.count} total requests',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  count: pendingCount,
                  label: 'Pending',
                  color: Colors.orange,
                  icon: Icons.schedule_rounded,
                ),
              ),
              _StatDivider(),
              Expanded(
                child: _StatItem(
                  count: declinedCount,
                  label: 'Declined',
                  color: Colors.red,
                  icon: Icons.cancel_rounded,
                ),
              ),
              _StatDivider(),
              Expanded(
                child: _StatItem(
                  count: settledCount,
                  label: 'Settled',
                  color: Colors.green,
                  icon: Icons.check_circle_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: _ShimmerCard(),
        );
      },
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    size: 32,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).extra.darkGray,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _fetchPaymentRequests,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 36,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No matches found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your filters to see more results',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).extra.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedStatus = 'all';
                _selectedPaymentMethod = 'all';
                _selectedBankName = 'all';
              });
              _fetchPaymentRequests();
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 44,
                    color: primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'No payment requests yet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Submit your first payment request and track its approval in real time.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).extra.darkGray,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () async {
                final created = await context.router.push(
                  const PaymentRequestRoute(),
                );
                if (created == true && mounted) {
                  _fetchPaymentRequests();
                }
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Create your first request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Creating payment request...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).extra.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}

class SliverToBoxAdjacent extends StatelessWidget {
  final Widget child;
  const SliverToBoxAdjacent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: child);
  }
}

class _PaymentRequestCard extends StatelessWidget {
  final PaymentRequestEntity request;

  const _PaymentRequestCard({required this.request});

  Color _getStatusColor() {
    switch (request.status) {
      case 'pending':
        return Colors.orange;
      case 'declined':
        return Colors.red;
      case 'replied':
        return Colors.blue;
      case 'settled':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getMethodIcon() {
    final method = request.paymentMethodName?.toLowerCase() ?? '';
    if (method.contains('esewa')) {
      return Icons.account_balance_wallet_rounded;
    } else if (method.contains('bank')) {
      return Icons.account_balance_rounded;
    } else if (method.contains('khalti')) {
      return Icons.payment_rounded;
    } else {
      return Icons.attach_money_rounded;
    }
  }

  String _getStatusText() {
    switch (request.status) {
      case 'pending':
        return 'Pending';
      case 'declined':
        return 'Declined';
      case 'replied':
        return 'Replied';
      case 'settled':
        return 'Settled';
      default:
        return request.statusDisplay;
    }
  }

  IconData _getStatusIcon() {
    switch (request.status) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'declined':
        return Icons.cancel_rounded;
      case 'replied':
        return Icons.reply_rounded;
      case 'settled':
        return Icons.check_circle_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final theme = Theme.of(context);
    final darkGray = theme.extra.darkGray;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status accent stripe
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getMethodIcon(),
                                size: 22,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.paymentMethodName ?? 'Payment',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        '#${request.id}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                          color: darkGray,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 3,
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: darkGray.withValues(
                                            alpha: 0.5,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          request.createdOnFormatted,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: darkGray,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _StatusBadge(
                              label: _getStatusText(),
                              icon: _getStatusIcon(),
                              color: statusColor,
                            ),
                          ],
                        ),
                        if (request.description.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            request.description,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.45,
                              color: darkGray,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (request.paymentBankName != null ||
                            request.paymentAccountNumber != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                if (request.paymentBankName != null)
                                  Expanded(
                                    child: _DetailChip(
                                      icon: Icons.account_balance_rounded,
                                      text: request.paymentBankName!,
                                    ),
                                  ),
                                if (request.paymentBankName != null &&
                                    request.paymentAccountNumber != null)
                                  Container(
                                    width: 1,
                                    height: 14,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    color: Colors.grey.withValues(alpha: 0.25),
                                  ),
                                if (request.paymentAccountNumber != null)
                                  Expanded(
                                    child: _DetailChip(
                                      icon: Icons.credit_card_rounded,
                                      text: _maskAccount(
                                        request.paymentAccountNumber!,
                                      ),
                                      monospace: true,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        if (request.closedOn != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: statusColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Closed ${request.closedOnFormatted}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _maskAccount(String account) {
    if (account.length <= 4) return account;
    return '•••• ${account.substring(account.length - 4)}';
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool monospace;
  const _DetailChip({
    required this.icon,
    required this.text,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    final darkGray = Theme.of(context).extra.darkGray;
    return Row(
      children: [
        Icon(icon, size: 14, color: darkGray),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: darkGray,
              fontFeatures: monospace
                  ? const [FontFeature.tabularFigures()]
                  : null,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
                height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).extra.darkGray,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.grey.withValues(alpha: 0.15),
    );
  }
}

class _FiltersBottomSheet extends StatefulWidget {
  final String selectedStatus;
  final String selectedPaymentMethod;
  final String selectedBankName;
  final List<PaymentMethodEntity> paymentMethods;
  final List<BankNameEntity> bankNames;
  final Function(String, String, String) onApply;

  const _FiltersBottomSheet({
    required this.selectedStatus,
    required this.selectedPaymentMethod,
    required this.selectedBankName,
    required this.paymentMethods,
    required this.bankNames,
    required this.onApply,
  });

  @override
  State<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<_FiltersBottomSheet> {
  late String _status;
  late String _paymentMethod;
  late String _bankName;

  @override
  void initState() {
    super.initState();
    _status = widget.selectedStatus;
    _paymentMethod = widget.selectedPaymentMethod;
    _bankName = widget.selectedBankName;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filters',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.grey.withValues(alpha: 0.15)),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection(
                      title: 'Status',
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: _status == 'all',
                          onSelected: (_) => setState(() => _status = 'all'),
                        ),
                        _FilterChip(
                          label: 'Declined',
                          selected: _status == 'declined',
                          onSelected: (_) =>
                              setState(() => _status = 'declined'),
                          icon: Icons.cancel_rounded,
                          color: Colors.red,
                        ),
                        _FilterChip(
                          label: 'Pending',
                          selected: _status == 'pending',
                          onSelected: (_) =>
                              setState(() => _status = 'pending'),
                          icon: Icons.schedule_rounded,
                          color: Colors.orange,
                        ),
                        _FilterChip(
                          label: 'Replied',
                          selected: _status == 'replied',
                          onSelected: (_) =>
                              setState(() => _status = 'replied'),
                          icon: Icons.reply_rounded,
                          color: Colors.blue,
                        ),
                        _FilterChip(
                          label: 'Settled',
                          selected: _status == 'settled',
                          onSelected: (_) =>
                              setState(() => _status = 'settled'),
                          icon: Icons.check_circle_rounded,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildFilterSection(
                      title: 'Payment Method',
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: _paymentMethod == 'all',
                          onSelected: (_) =>
                              setState(() => _paymentMethod = 'all'),
                        ),
                        for (final method in widget.paymentMethods)
                          _FilterChip(
                            label: method.name,
                            selected: _paymentMethod == method.id,
                            onSelected: (_) {
                              setState(() {
                                _paymentMethod = method.id;
                                if (method.name.toLowerCase().contains(
                                  'esewa',
                                )) {
                                  _bankName = 'all';
                                }
                              });
                            },
                          ),
                      ],
                    ),
                    if (widget.bankNames.isNotEmpty && !_isEsewaSelected()) ...[
                      const SizedBox(height: 24),
                      _buildFilterSection(
                        title: 'Bank Name',
                        children: [
                          _FilterChip(
                            label: 'All',
                            selected: _bankName == 'all',
                            onSelected: (_) =>
                                setState(() => _bankName = 'all'),
                          ),
                          for (final bank in widget.bankNames)
                            _FilterChip(
                              label: bank.name,
                              selected: _bankName == bank.name,
                              onSelected: (_) =>
                                  setState(() => _bankName = bank.name),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _status = 'all';
                          _paymentMethod = 'all';
                          _bankName = 'all';
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(_status, _paymentMethod, _bankName);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }

  bool _isEsewaSelected() {
    if (_paymentMethod == 'all') {
      return false;
    }

    final selectedMethod = widget.paymentMethods
        .where((m) => m.id == _paymentMethod)
        .firstOrNull;

    return selectedMethod?.name.toLowerCase().contains('esewa') ?? false;
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;
  final IconData? icon;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: selected ? chipColor : Theme.of(context).extra.darkGray,
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.grey.withValues(alpha: 0.08),
      selectedColor: chipColor.withValues(alpha: 0.12),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? chipColor : Theme.of(context).extra.darkGray,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected
              ? chipColor.withValues(alpha: 0.35)
              : Colors.grey.withValues(alpha: 0.12),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      showCheckmark: false,
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Colors.grey.withValues(alpha: 0.15);
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 80,
              height: 24,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 14,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 200,
          height: 14,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
