import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/configure/theme/theme.dart';
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

  static const _radiusCard = 16.0;
  static const _radiusPill = 999.0;

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

    final categoryValues = _categories
        .map((c) => c['value'] as String)
        .toList();
    _selectedCategory =
        (widget.subject != null && categoryValues.contains(widget.subject))
        ? widget.subject!
        : '';
    _selectedStatus = 'pending';
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
        _selectedCategory = '';
        _selectedStatus = 'pending';
      } else if (_tabController.index == 1) {
        _selectedCategory = '';
        _selectedStatus = 'closed';
      } else {
        _selectedCategory = '';
        _selectedStatus = 'pending';
      }

      _currentPage = 1;
      _hasReachedMax = false;
      _isLoadingMore = false;

      _loadTicketsForCurrentFilters();
    });
  }

  void _loadInitialTickets() {
    _loadTicketsForCurrentFilters();
  }

  void _loadTicketsForCurrentFilters() {
    final subject = _selectedCategory.isNotEmpty ? _selectedCategory : '';
    _ticketBloc.add(
      FetchTicketsEvent(page: '1', subject: subject, status: _selectedStatus),
    );
  }

  void _loadMoreTickets() {
    if (_isLoadingMore || _hasReachedMax || _isRefreshing) return;

    _isLoadingMore = true;
    final nextPage = _currentPage + 1;
    final subject = _selectedCategory.isNotEmpty ? _selectedCategory : '';
    _ticketBloc.add(
      FetchTicketsEvent(
        page: nextPage.toString(),
        subject: subject,
        status: _selectedStatus,
      ),
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

    final subject = _selectedCategory.isNotEmpty ? _selectedCategory : '';
    _ticketBloc.add(
      RefreshTicketsEvent(subject: subject, status: _selectedStatus),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
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

    return 'general_inqury';
  }

  Map<String, dynamic> _getCategoryInfo(String categoryValue) {
    return _categories.firstWhere(
      (c) => c['value'] == categoryValue,
      orElse: () => _categories.last,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteSmoke,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSegmentedTabs(),
          if (_tabController.index == 0 || _tabController.index == 1)
            _buildFiltersBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPendingTicketsContent(),
                _buildClosedTicketsContent(),
                _buildPaymentTicketsPlaceholder(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index != 2
          ? _buildNewInquiryFab()
          : null,
    );
  }

  // ───────────────────────────────────────────────────────────
  // App bar
  // ───────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.marianBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 56,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppTheme.marianBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      title: const Text(
        'My Tickets',
        style: TextStyle(
          fontSize: 17,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // Segmented pill tabs
  // ───────────────────────────────────────────────────────────
  Widget _buildSegmentedTabs() {
    final tabs = [
      ('Pending', Icons.pending_actions_rounded),
      ('Closed', Icons.task_alt_rounded),
      ('Payment', Icons.account_balance_wallet_rounded),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.whiteSmoke,
          borderRadius: BorderRadius.circular(_radiusPill),
        ),
        padding: const EdgeInsets.all(4),
        child: AnimatedBuilder(
          animation: _tabController.animation ?? _tabController,
          builder: (context, _) {
            final currentIndex = _tabController.index;
            return Row(
              children: List.generate(tabs.length, (i) {
                final selected = currentIndex == i;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _tabController.animateTo(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(_radiusPill),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppTheme.blackBean.withValues(
                                    alpha: 0.06,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            tabs[i].$2,
                            size: 16,
                            color: selected
                                ? AppTheme.marianBlue
                                : AppTheme.darkGray,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tabs[i].$1,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: selected
                                  ? AppTheme.marianBlue
                                  : AppTheme.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // Filters bar (horizontal scroll)
  // ───────────────────────────────────────────────────────────
  Widget _buildFiltersBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by type',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGray,
                    letterSpacing: 0.3,
                  ),
                ),
                if (_selectedCategory.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = '';
                        _currentPage = 1;
                        _hasReachedMax = false;
                        _isLoadingMore = false;
                      });
                      _loadTicketsForCurrentFilters();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: AppTheme.rojo,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.rojo,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category['value'];
                final color = category['color'] as Color;
                return _FilterChip(
                  label: category['label'] as String,
                  icon: _getCategoryIcon(category['value'] as String),
                  color: color,
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedCategory = category['value'] as String;
                      _currentPage = 1;
                      _hasReachedMax = false;
                      _isLoadingMore = false;
                    });
                    _loadTicketsForCurrentFilters();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // FAB — primary CTA in thumb zone
  // ───────────────────────────────────────────────────────────
  Widget _buildNewInquiryFab() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radiusPill),
        boxShadow: [
          BoxShadow(
            color: AppTheme.marianBlue.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => context.router.push(CreateTicketRoute()),
        backgroundColor: AppTheme.marianBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusPill),
        ),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'New Inquiry',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // Tab content (bloc consumers)
  // ───────────────────────────────────────────────────────────
  Widget _buildPendingTicketsContent() {
    return BlocConsumer<TicketBloc, TicketState>(
      listener: _ticketStateListener,
      builder: (context, state) => _buildBody(state),
    );
  }

  Widget _buildClosedTicketsContent() {
    return BlocConsumer<TicketBloc, TicketState>(
      listener: _ticketStateListener,
      builder: (context, state) => _buildBody(state),
    );
  }

  void _ticketStateListener(BuildContext context, TicketState state) {
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
  }

  Widget _buildBody(TicketState state) {
    if (state is CreateTicketLoading ||
        state is CreateTicketSuccess ||
        state is CreateTicketFailure) {
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
        color: AppTheme.marianBlue,
        backgroundColor: Colors.white,
        onRefresh: _refreshTickets,
        child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
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

            return _buildTicketCard(tickets[index]);
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ───────────────────────────────────────────────────────────
  // Premium ticket card
  // ───────────────────────────────────────────────────────────
  Widget _buildTicketCard(PendingTicketEntity ticket) {
    final detectedCategory = _detectCategory(ticket);
    final categoryInfo = _getCategoryInfo(detectedCategory);
    final categoryColor = categoryInfo['color'] as Color;
    final hasReply = ticket.reply != null && ticket.reply!.isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(_radiusCard),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.router.push(TicketDetailRoute(ticket: ticket)),
        splashColor: categoryColor.withValues(alpha: 0.06),
        highlightColor: categoryColor.withValues(alpha: 0.04),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radiusCard),
            border: Border.all(
              color: AppTheme.blackBean.withValues(alpha: 0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.blackBean.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: categoryColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.whiteSmoke,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '#${ticket.id}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.darkGray,
                                  letterSpacing: 0.2,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildCategoryPill(
                                categoryInfo,
                                detectedCategory,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(ticket.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          ticket.subject,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.blackBean,
                            height: 1.3,
                            letterSpacing: -0.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ticket.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.darkGray,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hasReply) ...[
                          const SizedBox(height: 12),
                          _buildReplyPreview(ticket.reply!),
                        ],
                        const SizedBox(height: 12),
                        Container(
                          height: 1,
                          color: AppTheme.lightGray,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: AppTheme.darkGray,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatRelative(ticket.createdOnFormatted),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.darkGray,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'View details',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.marianBlue,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: AppTheme.marianBlue,
                            ),
                          ],
                        ),
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

  Widget _buildCategoryPill(
    Map<String, dynamic> categoryInfo,
    String categoryValue,
  ) {
    final color = categoryInfo['color'] as Color;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(_radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getCategoryIcon(categoryValue), size: 11, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                categoryInfo['label'] as String,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview(String reply) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppTheme.marianBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.marianBlue.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.marianBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              size: 12,
              color: AppTheme.marianBlue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latest reply from support',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.marianBlue,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reply,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppTheme.blackBean.withValues(alpha: 0.85),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryValue) {
    switch (categoryValue) {
      case 'general_inqury':
        return Icons.help_outline_rounded;
      case 'cod_request':
        return Icons.payments_rounded;
      case 'order_inqury':
        return Icons.shopping_bag_rounded;
      case 'return_order_inqury':
        return Icons.assignment_return_rounded;
      case 'pickup_inqury':
        return Icons.local_shipping_rounded;
      case 'csr_inqury':
        return Icons.headset_mic_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        color = AppTheme.warningYellow;
        label = 'Pending';
        break;
      case 'closed':
        color = AppTheme.successGreen;
        label = 'Closed';
        break;
      case 'resolved':
        color = AppTheme.infoBlue;
        label = 'Resolved';
        break;
      default:
        color = AppTheme.powerBlue;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(_radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // Loading more / end-of-list / shimmer
  // ───────────────────────────────────────────────────────────
  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.marianBlue,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Loading more',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkGray,
              ),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 18,
              color: AppTheme.successGreen,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "You're all caught up",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.blackBean,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'No more tickets to load',
            style: TextStyle(fontSize: 12, color: AppTheme.darkGray),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: 5,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const _ShimmerCard(),
    );
  }

  // ───────────────────────────────────────────────────────────
  // Error / Empty / Payment placeholder
  // ───────────────────────────────────────────────────────────
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppTheme.rojo.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: AppTheme.rojo,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.blackBean,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                message.contains('404')
                    ? "We couldn't load your tickets. Check your connection and try again."
                    : message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.darkGray,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadInitialTickets,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.marianBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_radiusPill),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final statusText = _selectedStatus == 'pending' ? 'pending' : 'closed';
    final title = _selectedStatus == 'pending'
        ? 'No pending tickets'
        : 'No closed tickets';
    final description = _selectedStatus == 'pending'
        ? "You're all caught up. Tap below to start a new inquiry."
        : 'Resolved tickets will appear here once closed.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppTheme.marianBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _selectedStatus == 'pending'
                    ? Icons.inbox_rounded
                    : Icons.task_alt_rounded,
                size: 44,
                color: AppTheme.marianBlue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.blackBean,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.darkGray,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedStatus == 'pending')
              ElevatedButton.icon(
                onPressed: () => context.router.push(CreateTicketRoute()),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Create your first ticket'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.marianBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_radiusPill),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _refreshTickets,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('Refresh $statusText tickets'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.marianBlue,
                  side: BorderSide(color: AppTheme.marianBlue),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_radiusPill),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTicketsPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 44,
                color: AppTheme.successGreen,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Tickets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.blackBean,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Your COD requests and payment-related tickets will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.darkGray,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppTheme.warningYellow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(_radiusPill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: 14,
                    color: AppTheme.warningYellow,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Coming soon',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.warningYellow,
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

  // ───────────────────────────────────────────────────────────
  // Date helpers
  // ───────────────────────────────────────────────────────────
  String _formatRelative(String formattedDateTime) {
    try {
      final parts = formattedDateTime.split(' ');
      if (parts.isEmpty) return formattedDateTime;
      final date = DateTime.parse(parts[0]);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays >= 30) {
        return DateFormat('MMM dd, yyyy').format(date);
      } else if (diff.inDays >= 1) {
        return '${diff.inDays}d ago';
      } else if (diff.inHours >= 1) {
        return '${diff.inHours}h ago';
      } else if (diff.inMinutes >= 1) {
        return '${diff.inMinutes}m ago';
      }
      return 'Just now';
    } catch (_) {
      return formattedDateTime;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Filter chip
// ─────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? color : Colors.white;
    final fg = selected ? Colors.white : AppTheme.blackBean;
    final border = selected ? color : AppTheme.lightGray;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border, width: 1),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: selected ? Colors.white : color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shimmer card (loading skeleton)
// ─────────────────────────────────────────────────────────────
class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.blackBean.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _bar(width: 40, height: 14),
              const SizedBox(width: 8),
              _bar(width: 90, height: 14),
              const Spacer(),
              _bar(width: 60, height: 16),
            ],
          ),
          const SizedBox(height: 14),
          _bar(width: double.infinity, height: 14),
          const SizedBox(height: 8),
          _bar(width: 220, height: 14),
          const SizedBox(height: 12),
          _bar(width: double.infinity, height: 10),
          const SizedBox(height: 6),
          _bar(width: 180, height: 10),
          const SizedBox(height: 16),
          Container(height: 1, color: AppTheme.lightGray),
          const SizedBox(height: 12),
          Row(
            children: [
              _bar(width: 80, height: 10),
              const Spacer(),
              _bar(width: 60, height: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
