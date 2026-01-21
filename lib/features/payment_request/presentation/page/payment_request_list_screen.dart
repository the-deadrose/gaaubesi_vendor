// payment_request_list_screen.dart
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Requests'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showFiltersDialog,
            icon: const Icon(Icons.filter_list_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create payment request screen
          context.router.push(const PaymentRequestRoute());
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Request'),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
            return const Center(child: CircularProgressIndicator());
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPaymentRequestList(PaymentRequestListEntity paymentRequestList) {
    return Column(
      children: [
        // Stats Summary
        _buildStatsSummary(paymentRequestList),
        
        // List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _fetchPaymentRequests();
            },
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: paymentRequestList.results.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= paymentRequestList.results.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha:  0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            count: pendingCount,
            label: 'Pending',
            color: Colors.orange,
          ),
          _StatItem(
            count: approvedCount,
            label: 'Approved',
            color: Colors.green,
          ),
          _StatItem(
            count: rejectedCount,
            label: 'Rejected',
            color: Colors.red,
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
      itemCount: 10,
      itemBuilder: (context, index) {
        return _ShimmerCard();
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load payment requests',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).extra.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchPaymentRequests,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha:  0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Payment Requests',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first payment request to get started',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).extra.darkGray,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.router.push(const PaymentRequestRoute());
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Create Request'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRequestCard extends StatelessWidget {
  final PaymentRequestEntity request;

  const _PaymentRequestCard({required this.request});

  Color _getStatusColor(BuildContext context) {
    switch (request.status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Theme.of(context).extra.darkGray;
    }
  }

  IconData _getMethodIcon() {
    final method = request.paymentMethodName?.toLowerCase() ?? '';
    if (method.contains('esewa')) {
      return Icons.account_balance_wallet_rounded;
    } else if (method.contains('bank')) {
      return Icons.account_balance_rounded;
    } else {
      return Icons.payment_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navigate to detail screen
          // context.router.push(PaymentRequestDetailRoute(request: request));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha:  0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:  0.05),
                blurRadius: 8,
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
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha:  0.1),
                          borderRadius: BorderRadius.circular(8),
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
                            request.paymentMethodName ?? 'N/A',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID: ${request.id}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).extra.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(context).withValues(alpha:  0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      request.statusDisplay,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                request.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (request.paymentBankName != null)
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_rounded,
                          size: 14,
                          color: Theme.of(context).extra.darkGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          request.paymentBankName!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).extra.darkGray,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  if (request.paymentAccountNumber != null)
                    Row(
                      children: [
                        Icon(
                          Icons.credit_card_rounded,
                          size: 14,
                          color: Theme.of(context).extra.darkGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          request.paymentAccountNumber!.length > 4
                              ? '••••${request.paymentAccountNumber!.substring(request.paymentAccountNumber!.length - 4)}'
                              : request.paymentAccountNumber!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).extra.darkGray,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    request.createdOnFormatted,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).extra.darkGray,
                    ),
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green,
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
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha:  0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).extra.darkGray,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Status Filter
          Text(
            'Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
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
              ),
              _FilterChip(
                label: 'Approved',
                selected: _status == 'approved',
                onSelected: (selected) => setState(() => _status = 'approved'),
              ),
              _FilterChip(
                label: 'Rejected',
                selected: _status == 'rejected',
                onSelected: (selected) => setState(() => _status = 'rejected'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Payment Method Filter
          Text(
            'Payment Method',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
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
          
          const SizedBox(height: 24),
          
          // Bank Name Filter
          if (widget.bankNames.isNotEmpty) ...[
            Text(
              'Bank Name',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
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
            const SizedBox(height: 24),
          ],
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_status, _paymentMethod, _bankName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha:  0.1),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: selected 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).extra.darkGray,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha:  0.3),
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).extra.darkGray.withValues(alpha:  _animation.value * 0.15),
                      borderRadius: BorderRadius.circular(8),
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
                            color: Theme.of(context).extra.darkGray.withValues(alpha:  _animation.value * 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Theme.of(context).extra.darkGray.withValues(alpha:  _animation.value * 0.15),
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
                      color: Theme.of(context).extra.darkGray.withValues(alpha:  _animation.value * 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 16,
                decoration: BoxDecoration(
                  color: Theme.of(context).extra.darkGray.withValues(alpha:  _animation.value * 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 200,
                height: 16,
                decoration: BoxDecoration(
                  color: Theme.of(context).extra.darkGray.withValues(alpha:  _animation.value * 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Theme.of(context).extra.darkGray.withValues(alpha:  _animation.value * 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Theme.of(context).extra.darkGray.withValues(alpha:  _animation.value * 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}