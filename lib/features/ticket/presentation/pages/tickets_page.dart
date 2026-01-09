import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/entity/ticket_entity.dart';
import 'package:gaaubesi_vendor/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:gaaubesi_vendor/features/ticket/presentation/bloc/ticket_events.dart';
import 'package:gaaubesi_vendor/features/ticket/presentation/bloc/tickets_state.dart';

@RoutePage()
class TicketsPage extends StatefulWidget {
  final int initialTab;

  const TicketsPage({super.key, this.initialTab = 0});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final ScrollController _pendingScrollController = ScrollController();
  final ScrollController _closedScrollController = ScrollController();
  int _currentTabIndex = 0;
  bool _isPendingAtBottom = false;
  bool _isClosedAtBottom = false;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _currentTabIndex = widget.initialTab;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });

    _tabController.addListener(_onTabChanged);
    _setupScrollListeners();
  }

  void _loadInitialData() {
    _hasLoadedOnce = true;
    if (widget.initialTab == 0) {
      context.read<TicketBloc>().add(
        const FetchPendingTicketsEvent(page: '1'),
      );
    } else {
      context.read<TicketBloc>().add(
        const FetchClosedTicketsEvent(page: '1'),
      );
    }
  }

  void _refreshCurrentTab() {
    debugPrint('[TicketsPage] Refreshing current tab: $_currentTabIndex');
    if (_currentTabIndex == 0) {
      context.read<TicketBloc>().add(
        const RefreshTicketsEvent(isPending: true),
      );
    } else {
      context.read<TicketBloc>().add(
        const RefreshTicketsEvent(isPending: false),
      );
    }
  }

  void _setupScrollListeners() {
    _pendingScrollController.addListener(() {
      if (_currentTabIndex == 0) {
        _handleScroll(_pendingScrollController, isPending: true);
      }
    });

    _closedScrollController.addListener(() {
      if (_currentTabIndex == 1) {
        _handleScroll(_closedScrollController, isPending: false);
      }
    });
  }

  void _handleScroll(ScrollController controller, {required bool isPending}) {
    if (!controller.hasClients) return;

    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    final threshold = maxScroll * 0.8;

    if (currentScroll >= threshold) {
      if (isPending && !_isPendingAtBottom) {
        _isPendingAtBottom = true;
        context.read<TicketBloc>().add(
          const FetchMoreTicketsEvent(isPending: true),
        );

        Future.delayed(const Duration(seconds: 1), () {
          _isPendingAtBottom = false;
        });
      } else if (!isPending && !_isClosedAtBottom) {
        _isClosedAtBottom = true;
        context.read<TicketBloc>().add(
          const FetchMoreTicketsEvent(isPending: false),
        );

        Future.delayed(const Duration(seconds: 1), () {
          _isClosedAtBottom = false;
        });
      }
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging &&
        _tabController.index != _currentTabIndex) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });

      final bloc = context.read<TicketBloc>();
      final currentState = bloc.state;

      if (_tabController.index == 0) {
        if (currentState is! PendingTicketsLoaded &&
            currentState is! TicketsLoading) {
          bloc.add(const FetchPendingTicketsEvent(page: '1'));
        }
      } else {
        if (currentState is! ClosedTicketsLoaded &&
            currentState is! TicketsLoading) {
          bloc.add(const FetchClosedTicketsEvent(page: '1'));
        }
      }
    }
  }

  Future<void> _onRefresh({required bool isPending}) async {
    context.read<TicketBloc>().add(RefreshTicketsEvent(isPending: isPending));
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _pendingScrollController.dispose();
    _closedScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // This is called when navigating away from this page
        // We don't need to do anything here
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.all(12.0),
            padding: const EdgeInsets.all(2.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                context.router.pop();
              },
            ),
          ),
          title: const Text(
            'Tickets',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
          centerTitle: true,
          backgroundColor: AppTheme.marianBlue,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: AppTheme.marianBlue,
                unselectedLabelColor: AppTheme.darkGray,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                dividerHeight: 0,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.pending_actions, size: 20),
                    text: 'Pending',
                    height: 46,
                  ),
                  Tab(
                    icon: Icon(Icons.task_alt, size: 20),
                    text: 'Closed',
                    height: 46,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildPendingTab(), _buildClosedTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTab() {
    return BlocConsumer<TicketBloc, TicketsState>(
      listener: (context, state) {
        if (state is TicketsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () => _onRefresh(isPending: true),
          child: _buildTicketsList(
            scrollController: _pendingScrollController,
            isPending: true,
            state: state,
          ),
        );
      },
    );
  }

  Widget _buildClosedTab() {
    return BlocConsumer<TicketBloc, TicketsState>(
      listener: (context, state) {
        if (state is TicketsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () => _onRefresh(isPending: false),
          child: _buildTicketsList(
            scrollController: _closedScrollController,
            isPending: false,
            state: state,
          ),
        );
      },
    );
  }

  Widget _buildTicketsList({
    required ScrollController scrollController,
    required bool isPending,
    required TicketsState state,
  }) {
    if (state is TicketsInitial || state is TicketsLoading) {
      return _buildLoading();
    }

    if (isPending && state is TicketsError) {
      final errorState = state;
      final errorMessage = errorState.message;
      final previousResponse = errorState.previousResponse;

      if (previousResponse != null &&
          (previousResponse.results?.isNotEmpty ?? false)) {
        return Column(
          children: [
            Expanded(
              child: _buildTickets(
                response: previousResponse,
                scrollController: scrollController,
                isPending: isPending,
                state: state,
              ),
            ),
            _buildErrorBanner(errorMessage),
          ],
        );
      }

      return _buildError(
        errorMessage,
        () => context.read<TicketBloc>().add(
          FetchPendingTicketsEvent(page: '1'),
        ),
      );
    } else if (!isPending && state is TicketsError) {
      final errorState = state;
      final errorMessage = errorState.message;
      final previousResponse = errorState.previousResponse;

      if (previousResponse != null &&
          (previousResponse.results?.isNotEmpty ?? false)) {
        return Column(
          children: [
            Expanded(
              child: _buildTickets(
                response: previousResponse,
                scrollController: scrollController,
                isPending: isPending,
                state: state,
              ),
            ),
            _buildErrorBanner(errorMessage),
          ],
        );
      }

      return _buildError(
        errorMessage,
        () => context.read<TicketBloc>().add(
          FetchClosedTicketsEvent(page: '1'),
        ),
      );
    }

    if (isPending && state is PendingTicketsLoaded) {
      return _buildTickets(
        response: state.response,
        scrollController: scrollController,
        isPending: true,
        state: state,
      );
    } else if (!isPending && state is ClosedTicketsLoaded) {
      return _buildTickets(
        response: state.response,
        scrollController: scrollController,
        isPending: false,
        state: state,
      );
    }

    return const SizedBox();
  }

  Widget _buildTickets({
    required TicketResponseEntity response,
    required ScrollController scrollController,
    required bool isPending,
    required TicketsState state,
  }) {
    final tickets = response.results ?? [];

    late final bool isLoadingMore;
    late final bool hasReachedMax;
    late final bool isRefreshing;

    if (isPending && state is PendingTicketsLoaded) {
      isLoadingMore = state.isLoadingMore;
      hasReachedMax = state.hasReachedMax;
      isRefreshing = state.isRefreshing;
    } else if (state is ClosedTicketsLoaded) {
      isLoadingMore = state.isLoadingMore;
      hasReachedMax = state.hasReachedMax;
      isRefreshing = state.isRefreshing;
    } else {
      isLoadingMore = false;
      hasReachedMax = true;
      isRefreshing = false;
    }

    if (tickets.isEmpty && !isLoadingMore && !isRefreshing) {
      return _buildEmpty(isPending: isPending);
    }

    return RefreshIndicator(
      onRefresh: () => _onRefresh(isPending: isPending),
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(12),
        itemCount:
            tickets.length +
            (isLoadingMore ? 1 : 0) +
            (hasReachedMax && tickets.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == tickets.length) {
            if (isLoadingMore) {
              return _buildLoadMoreIndicator();
            } else if (hasReachedMax && tickets.isNotEmpty) {
              return _buildEndOfList();
            }
          }

          if (index < tickets.length) {
            final ticket = tickets[index];
            return _buildTicketCard(ticket);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildTicketCard(TicketEntity ticket) {
    return InkWell(
      onTap: () {
        // Navigate to ticket detail if needed
        // context.router.push(TicketDetailRoute(ticketId: ticket.id));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ticket.isPending
                ? AppTheme.marianBlue.withValues(alpha: 0.3)
                : AppTheme.lightGray,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with ticket ID and status
            Row(
              children: [
                Text(
                  '#${ticket.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.marianBlue,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ticket.isPending
                        ? Colors.orange.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ticket.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ticket.isPending ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Subject
            Text(
              ticket.subject,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.blackBean,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              ticket.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppTheme.blackBean,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // Footer with created date and closed by
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppTheme.marianBlue.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    ticket.createdOnFormatted,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.blackBean.withValues(alpha: 0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (ticket.isClosed && ticket.closedByName != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Closed by: ${ticket.closedByName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.darkGray.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),

            // Reply (if available)
            if (ticket.reply != null && ticket.reply!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reply:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.marianBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.reply!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.blackBean,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.lightGray, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header skeleton
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Subject skeleton
              Container(
                width: double.infinity,
                height: 16,
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity * 0.8,
                height: 14,
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 16),

              // Footer skeleton
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 100,
                    height: 13,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(6),
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

  Widget _buildError(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.rojo.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.rojo.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.blackBean,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.darkGray.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
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
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty({required bool isPending}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.marianBlue.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPending ? Icons.pending_actions : Icons.task_alt,
                size: 64,
                color: AppTheme.marianBlue.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isPending ? 'No pending tickets' : 'No closed tickets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.blackBean,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPending
                  ? 'Pending tickets will appear here when created'
                  : 'Closed tickets will appear here when resolved',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.darkGray.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildEndOfList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'You\'ve reached the end',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.darkGray.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}