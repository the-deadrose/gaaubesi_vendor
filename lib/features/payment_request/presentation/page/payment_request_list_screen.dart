import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/entity/payment_request_list_entity.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/payment_request/payment_request_bloc.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/payment_request/payment_request_event.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/payment_request/payment_request_state.dart';

@RoutePage()
class PaymentRequestListScreen extends StatefulWidget {
  const PaymentRequestListScreen({super.key});

  @override
  State<PaymentRequestListScreen> createState() => _PaymentRequestListScreenState();
}

class _PaymentRequestListScreenState extends State<PaymentRequestListScreen> {
  final _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  String _selectedStatus = 'all';
  String _selectedPaymentMethod = 'all';
  String _selectedBankName = 'all';

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
        final state = context.read<PaymentRequestBloc>().state;
        PaymentRequestListEntity? paymentRequestList;
        
        if (state is FetchPaymentRequestsSuccess) {
          paymentRequestList = state.paymentRequestList;
        }

        return _FiltersBottomSheet(
          selectedStatus: _selectedStatus,
          selectedPaymentMethod: _selectedPaymentMethod,
          selectedBankName: _selectedBankName,
          paymentMethods: paymentRequestList?.paymentMethods ?? [],
          bankNames: paymentRequestList?.bankNames ?? [],
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Payment Requests'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        
        actions: [
          _buildActionButton(
            icon: Icons.filter_list_rounded,
            onPressed: _showFiltersDialog,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.add_rounded,
            onPressed: () {
              context.router.push(const PaymentRequestRoute());
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<PaymentRequestBloc, PaymentRequestState>(
        listener: (context, state) {
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

  Widget _buildActionButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildPaymentRequestList(PaymentRequestListEntity paymentRequestList) {
    return Column(
      children: [
        // Active Filters Bar
        if (_selectedStatus != 'all' || _selectedPaymentMethod != 'all' || _selectedBankName != 'all')
          _buildActiveFilters(),

        // Stats Summary
        _buildStatsSummary(paymentRequestList),
        
        // List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _fetchPaymentRequests();
            },
            color: Theme.of(context).colorScheme.primary,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: paymentRequestList.results.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= paymentRequestList.results.length) {
                  return _buildLoadMoreIndicator();
                }
                
                final request = paymentRequestList.results[index];
                return _PaymentRequestCard(request: request);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
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
                      label: _selectedStatus.toUpperCase(),
                      onRemove: () {
                        setState(() => _selectedStatus = 'all');
                        _fetchPaymentRequests();
                      },
                    ),
                  if (_selectedPaymentMethod != 'all')
                    _buildActiveFilterChip(
                      label: 'Payment Method',
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
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ),
            child: Text(
              'Clear All',
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

  Widget _buildActiveFilterChip({required String label, required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
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
    
    final approvedCount = paymentRequestList.results
        .where((request) => request.status == 'approved')
        .length;
    
    final rejectedCount = paymentRequestList.results
        .where((request) => request.status == 'rejected')
        .length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            count: pendingCount,
            label: 'Pending',
            color: Colors.orange,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withOpacity(0.2),
          ),
          _StatItem(
            count: approvedCount,
            label: 'Approved',
            color: Colors.green,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withOpacity(0.2),
          ),
          _StatItem(
            count: rejectedCount,
            label: 'Rejected',
            color: Colors.red,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withOpacity(0.2),
          ),
          _StatItem(
            count: paymentRequestList.count,
            label: 'Total',
            color: Theme.of(context).colorScheme.primary,
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
        child: Container(
          width: 32,
          height: 32,
          padding: const EdgeInsets.all(8),
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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).extra.darkGray,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _fetchPaymentRequests,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Payment Requests',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Start by creating your first payment request',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).extra.darkGray,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.router.push(const PaymentRequestRoute());
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Create Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Creating payment request...'),
        ],
      ),
    );
  }
}

class _PaymentRequestCard extends StatelessWidget {
  final PaymentRequestEntity request;

  const _PaymentRequestCard({required this.request});

  Color _getStatusColor() {
    switch (request.status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
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
        return 'Pending Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return request.statusDisplay;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navigate to detail screen
          // context.router.push(PaymentRequestDetailRoute(request: request));
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getMethodIcon(),
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.paymentMethodName ?? 'Payment',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID: ${request.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(),
                          size: 12,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Description
              if (request.description.isNotEmpty)
                Text(
                  request.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              // Bank Details
              if (request.paymentBankName != null || request.paymentAccountNumber != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      if (request.paymentBankName != null)
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_balance_rounded,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  request.paymentBankName!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (request.paymentAccountNumber != null)
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.credit_card_rounded,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  request.paymentAccountNumber!.length > 4
                                      ? '••••${request.paymentAccountNumber!.substring(request.paymentAccountNumber!.length - 4)}'
                                      : request.paymentAccountNumber!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              
              // Footer
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        request.createdOnFormatted,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (request.closedOn != null)
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          request.closedOnFormatted,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (request.status) {
      case 'pending':
        return Icons.access_time_rounded;
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatItem({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
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
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.2),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Filter
                    _buildFilterSection(
                      title: 'Status',
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: _status == 'all',
                          onSelected: (selected) => setState(() => _status = 'all'),
                        ),
                        _FilterChip(
                          label: 'Pending',
                          selected: _status == 'pending',
                          onSelected: (selected) => setState(() => _status = 'pending'),
                          icon: Icons.access_time_rounded,
                          color: Colors.orange,
                        ),
                        _FilterChip(
                          label: 'Approved',
                          selected: _status == 'approved',
                          onSelected: (selected) => setState(() => _status = 'approved'),
                          icon: Icons.check_circle_rounded,
                          color: Colors.green,
                        ),
                        _FilterChip(
                          label: 'Rejected',
                          selected: _status == 'rejected',
                          onSelected: (selected) => setState(() => _status = 'rejected'),
                          icon: Icons.cancel_rounded,
                          color: Colors.red,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Payment Method Filter
                    _buildFilterSection(
                      title: 'Payment Method',
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: _paymentMethod == 'all',
                          onSelected: (selected) => setState(() => _paymentMethod = 'all'),
                        ),
                        for (final method in widget.paymentMethods)
                          _FilterChip(
                            label: method.name,
                            selected: _paymentMethod == method.id,
                            onSelected: (selected) => setState(() => _paymentMethod = method.id),
                          ),
                      ],
                    ),
                    
                    if (widget.bankNames.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      
                      // Bank Name Filter
                      _buildFilterSection(
                        title: 'Bank Name',
                        children: [
                          _FilterChip(
                            label: 'All',
                            selected: _bankName == 'all',
                            onSelected: (selected) => setState(() => _bankName = 'all'),
                          ),
                          for (final bank in widget.bankNames)
                            _FilterChip(
                              label: bank.name,
                              selected: _bankName == bank.name,
                              onSelected: (selected) => setState(() => _bankName = bank.name),
                            ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                  ),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(_status, _paymentMethod, _bankName);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Apply Filters'),
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

  Widget _buildFilterSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children,
        ),
      ],
    );
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
              color: selected ? chipColor : Colors.grey,
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.grey.withOpacity(0.1),
      selectedColor: chipColor.withOpacity(0.1),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        color: selected ? chipColor : Colors.grey[700],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? chipColor.withOpacity(0.3) : Colors.transparent,
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
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
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
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 200,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 80,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 100,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}