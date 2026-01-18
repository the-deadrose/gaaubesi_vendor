import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/entity/pending_ticket_list_entity.dart';
import 'package:gaaubesi_vendor/features/ticket/presentation/bloc/ticket_events.dart';
import 'package:gaaubesi_vendor/features/ticket/presentation/bloc/tickets_state.dart';
import 'package:intl/intl.dart';

@RoutePage()
class TicketScreen extends StatefulWidget {
  final String? subject;

  const TicketScreen({super.key, @QueryParam() this.subject});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TicketBloc _ticketBloc;
  int _currentPage = 1;
  bool _hasReachedMax = false;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;

  late TabController _tabController;
  late String _selectedCategory;
  late String _selectedStatus;
  String _selectedSubject = 'pending';

  final List<Map<String, dynamic>> _categories = [
    {
      'label': 'General Inquiry',
      'value': 'general_inqury',
      'color': AppTheme.infoBlue,
      'keywords': ['general', 'question', 'info', 'information', 'query'],
    },
    {
      'label': 'COD Request',
      'value': 'cod_request',
      'color': AppTheme.successGreen,
      'keywords': ['cod', 'cash', 'payment', 'collect'],
    },
    {
      'label': 'Orders Inquiry',
      'value': 'order_inqury',
      'color': AppTheme.warningYellow,
      'keywords': ['order', 'purchase', 'buy', 'product', 'item', 'stock'],
    },
    {
      'label': 'Return Orders',
      'value': 'return_order_inqury',
      'color': AppTheme.rojo,
      'keywords': ['return', 'refund', 'exchange', 'cancel', 'cancellation'],
    },
    {
      'label': 'Pickup Inquiry',
      'value': 'pickup_inqury',
      'color': AppTheme.powerBlue,
      'keywords': [
        'pickup',
        'collection',
        'delivery',
        'dispatch',
        'shipping',
        'courier',
      ],
    },
    {
      'label': 'CSR Inquiry',
      'value': 'csr_inqury',
      'color': Colors.purple,
      'keywords': [
        'csr',
        'customer service',
        'customer support',
        'support',
        'help',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _ticketBloc = context.read<TicketBloc>();
    _scrollController.addListener(_onScroll);

    _tabController = TabController(length: 3, vsync: this);

    _selectedCategory = widget.subject ?? '';
    _selectedStatus = 'pending';
    _selectedSubject = 'pending';
    _tabController.addListener(_handleTabChange);

    if (_ticketBloc.state is CreateTicketLoading ||
        _ticketBloc.state is CreateTicketSuccess ||
        _ticketBloc.state is CreateTicketFailure) {
      _ticketBloc.add(CreateTicketReset());
    }

    _loadInitialTickets();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;

    setState(() {
      if (_tabController.index == 0) {
        // Pending Tickets tab
        _selectedSubject = 'pending';
        _selectedCategory = '';
        _selectedStatus = 'pending';
      } else if (_tabController.index == 1) {
        // Closed Tickets tab
        _selectedSubject = 'closed';
        _selectedCategory = '';
        _selectedStatus = 'closed';
      } else {
        // Payment Tickets tab
        _selectedSubject = 'payment';
        _selectedCategory = '';
        _selectedStatus = 'pending';
      }

      _currentPage = 1;
      _hasReachedMax = false;
      _isLoadingMore = false;

      if (_selectedSubject == 'pending' || _selectedSubject == 'closed') {
        _loadTicketsForCurrentFilters();
      } else {
        _ticketBloc.add(RefreshTicketsEvent(subject: 'payment', status: 'pending'));
      }
    });
  }

  void _loadInitialTickets() {
    _loadTicketsForCurrentFilters();
  }

  void _loadTicketsForCurrentFilters() {
    // Build the subject parameter based on category and status filters
    String subject = _buildSubjectParameter();
    _ticketBloc.add(FetchTicketsEvent(page: '1', subject: subject, status: _selectedStatus));
  }

  String _buildSubjectParameter() {
    // If category is specific, use the category
    if (_selectedCategory.isNotEmpty) {
      return _selectedCategory;
    }
    
    // Otherwise, return empty string (will use status-based URL)
    return '';
  }

  void _loadMoreTickets() {
    if (_isLoadingMore || _hasReachedMax || _isRefreshing) return;

    _isLoadingMore = true;
    final nextPage = _currentPage + 1;
    String subject = _buildSubjectParameter();
    _ticketBloc.add(
      FetchTicketsEvent(page: nextPage.toString(), subject: subject, status: _selectedStatus),
    );
  }

  void _onScroll() {
    if (_isBottom && !_isLoadingMore && !_hasReachedMax && !_isRefreshing) {
      _loadMoreTickets();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _refreshTickets() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    _currentPage = 1;
    _hasReachedMax = false;
    _isLoadingMore = false;

    String subject = _buildSubjectParameter();
    _ticketBloc.add(RefreshTicketsEvent(subject: subject, status: _selectedStatus));

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isRefreshing = false;
    });
  }

  String _detectCategory(PendingTicketEntity ticket) {
    final text =
        '${ticket.subject.toLowerCase()} ${ticket.description.toLowerCase()}';

    for (int i = 1; i < _categories.length; i++) {
      final category = _categories[i];
      final keywords = category['keywords'] as List<String>;

      for (final keyword in keywords) {
        if (text.contains(keyword.toLowerCase())) {
          return category['value'] as String;
        }
      }
    }

    // Default to general inquiry if no match found
    return 'general_inqury';
  }

  Map<String, dynamic> _getCategoryInfo(String categoryValue) {
    return _categories.firstWhere(
      (c) => c['value'] == categoryValue,
      orElse: () => _categories.last,
    );
  }

  Widget _buildPaymentTicketsPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 100, color: AppTheme.powerBlue),
            const SizedBox(height: 24),
            Text(
              'Payment Tickets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.blackBean,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Payment-related tickets will appear here',
              style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
            ),
            const SizedBox(height: 8),
            Text(
              'Feature coming soon',
              style: TextStyle(fontSize: 12, color: AppTheme.powerBlue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.whiteSmoke,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              GestureDetector(
                onTap: () {
                  context.router.push(CreateTicketRoute());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.powerBlue, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 14,
                        color: AppTheme.blackBean,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Add Inquiry',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.blackBean,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Filter by Ticket Type',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              bool isSelected = _selectedCategory == category['value'];
              Color backgroundColor = isSelected
                  ? category['color'] as Color
                  : AppTheme.lightGray;
              Color textColor = isSelected ? Colors.white : AppTheme.blackBean;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category['value'] as String;
                    _currentPage = 1;
                    _hasReachedMax = false;
                    _isLoadingMore = false;
                  });

                  _loadTicketsForCurrentFilters();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? category['color'] as Color
                          : AppTheme.powerBlue,
                      width: isSelected ? 0 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (category['color'] as Color).withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Icon(Icons.check_circle, size: 14, color: Colors.white),
                      if (isSelected) const SizedBox(width: 4),
                      Text(
                        category['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: const Text('Tickets'),

        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.pending_actions), text: 'Pending'),
            Tab(icon: Icon(Icons.check_circle_outline), text: 'Closed'),
            Tab(icon: Icon(Icons.payment), text: 'Payment'),
          ],
          labelColor: AppTheme.whiteSmoke,
          unselectedLabelColor: AppTheme.darkGray,
          indicatorColor: AppTheme.marianBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
      body: Column(
        children: [
          if (_tabController.index == 0 || _tabController.index == 1) _buildCategoryChips(),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPendingTicketsContent(),
                _buildClosedTicketsContent(),
                _buildPaymentTicketsPlaceholder(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingTicketsContent() {
    return BlocConsumer<TicketBloc, TicketState>(
      listener: (context, state) {
        if (state is TicketLoaded) {
          _isLoadingMore = false;
          _isRefreshing = false;

          if (state.tickets.next == null) {
            _hasReachedMax = true;
          } else {
            final nextUrl = state.tickets.next;
            if (nextUrl != null && nextUrl.contains('page=')) {
              final match = RegExp(r'page=(\d+)').firstMatch(nextUrl);
              if (match != null) {
                _currentPage = int.tryParse(match.group(1)!) ?? _currentPage;
              }
            }
          }
        }

        if (state is TicketError) {
          _isLoadingMore = false;
          _isRefreshing = false;
        }
      },
      builder: (context, state) {
        return _buildBody(state);
      },
    );
  }

  Widget _buildClosedTicketsContent() {
    return BlocConsumer<TicketBloc, TicketState>(
      listener: (context, state) {
        if (state is TicketLoaded) {
          _isLoadingMore = false;
          _isRefreshing = false;

          if (state.tickets.next == null) {
            _hasReachedMax = true;
          } else {
            final nextUrl = state.tickets.next;
            if (nextUrl != null && nextUrl.contains('page=')) {
              final match = RegExp(r'page=(\d+)').firstMatch(nextUrl);
              if (match != null) {
                _currentPage = int.tryParse(match.group(1)!) ?? _currentPage;
              }
            }
          }
        }

        if (state is TicketError) {
          _isLoadingMore = false;
          _isRefreshing = false;
        }
      },
      builder: (context, state) {
        return _buildBody(state);
      },
    );
  }

  // In _buildBody method of TicketScreen, update it to:
  Widget _buildBody(TicketState state) {
    // Handle create ticket states by returning to initial state
    if (state is CreateTicketLoading ||
        state is CreateTicketSuccess ||
        state is CreateTicketFailure) {
      // Trigger a refresh when returning from create screen
      if (!_isRefreshing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _refreshTickets();
        });
      }
      return _buildShimmerLoading();
    }

    if (state is TicketInitial || state is TicketLoading) {
      return _buildShimmerLoading();
    }

    if (state is TicketError) {
      return _buildErrorState(state.message);
    }

    if (state is TicketEmpty) {
      return _buildEmptyState();
    }

    if (state is TicketLoaded) {
      final tickets = state.tickets.results;
      final hasReachedMax = _hasReachedMax;

      return RefreshIndicator(
        onRefresh: _refreshTickets,
        child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: tickets.length + (hasReachedMax ? 1 : 2),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index >= tickets.length) {
              if (index == tickets.length && !hasReachedMax) {
                return _buildLoadingMoreIndicator();
              } else {
                return _buildEndOfListIndicator(hasReachedMax);
              }
            }

            final ticket = tickets[index];
            return _buildTicketCard(ticket);
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTicketCard(PendingTicketEntity ticket) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        context.router.push(TicketDetailRoute(ticket: ticket));
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ticket.subject,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(ticket.status),
              ],
            ),
            const SizedBox(height: 8),

            _buildCategoryChipForTicket(ticket),
            const SizedBox(height: 8),

            Text(
              ticket.description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateOnly(ticket.createdOnFormatted),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimeOnly(ticket.createdOnFormatted),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (ticket.reply != null && ticket.reply!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade100, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.reply, size: 16, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reply: ${ticket.reply!}',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChipForTicket(PendingTicketEntity ticket) {
    final detectedCategory = _detectCategory(ticket);
    final categoryInfo = _getCategoryInfo(detectedCategory);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (categoryInfo['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (categoryInfo['color'] as Color).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(detectedCategory),
            size: 12,
            color: categoryInfo['color'] as Color,
          ),
          const SizedBox(width: 4),
          Text(
            categoryInfo['label'] as String,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: categoryInfo['color'] as Color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryValue) {
    switch (categoryValue) {
      case 'general_inqury':
        return Icons.help_outline;
      case 'cod_request':
        return Icons.payments;
      case 'order_inqury':
        return Icons.shopping_cart;
      case 'return_order_inqury':
        return Icons.assignment_return;
      case 'pickup_inqury':
        return Icons.local_shipping;
      case 'csr_inqury':
        return Icons.headset_mic;
      default:
        return Icons.category;
    }
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = AppTheme.warningYellow.withValues(alpha: 0.2);
        textColor = AppTheme.warningYellow;
        label = 'Pending';
        break;
      case 'closed':
        backgroundColor = AppTheme.successGreen.withValues(alpha: 0.2);
        textColor = AppTheme.successGreen;
        label = 'Closed';
        break;
      case 'resolved':
        backgroundColor = AppTheme.infoBlue.withValues(alpha: 0.2);
        textColor = AppTheme.infoBlue;
        label = 'Resolved';
        break;
      default:
        backgroundColor = AppTheme.powerBlue.withValues(alpha: 0.2);
        textColor = AppTheme.powerBlue;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(height: 8),
            Text(
              'Loading more tickets...',
              style: TextStyle(fontSize: 12, color: AppTheme.darkGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndOfListIndicator(bool hasReachedMax) {
    if (!hasReachedMax) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: AppTheme.successGreen,
          ),
          const SizedBox(height: 12),
          Text(
            'All tickets loaded',
            style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
          ),
          const SizedBox(height: 4),
          Text(
            'You\'ve reached the end of the list',
            style: TextStyle(fontSize: 12, color: AppTheme.powerBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildShimmerCard();
      },
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.powerBlue.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),

          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 16,
            width: 250,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 12,
                width: 80,
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 12,
                width: 100,
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppTheme.rojo),
            const SizedBox(height: 16),
            Text(
              'Failed to load tickets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.blackBean,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message.contains('404')
                    ? 'Unable to load tickets. Please check your connection and try again.'
                    : message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadInitialTickets,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.marianBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final statusText = _selectedStatus == 'pending' ? 'Pending' : 'Closed';
    final description = _selectedStatus == 'pending'
        ? 'All tickets have been processed or assigned'
        : 'No closed tickets found';
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 100, color: AppTheme.powerBlue),
            const SizedBox(height: 24),
            Text(
              'No $statusText Tickets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.blackBean,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new tickets',
              style: TextStyle(fontSize: 12, color: AppTheme.powerBlue),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: _refreshTickets,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.marianBlue),
              ),
              child: Text(
                'Refresh',
                style: TextStyle(color: AppTheme.marianBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateOnly(String formattedDateTime) {
    try {
      final parts = formattedDateTime.split(' ');
      if (parts.isNotEmpty) {
        final datePart = parts[0];
        final date = DateTime.parse(datePart);
        return DateFormat('MMM dd, yyyy').format(date);
      }
      return formattedDateTime;
    } catch (e) {
      return formattedDateTime;
    }
  }

  String _formatTimeOnly(String formattedDateTime) {
    try {
      final parts = formattedDateTime.split(' ');
      if (parts.length >= 2) {
        return parts[1];
      }
      return '';
    } catch (e) {
      return '';
    }
  }
}
