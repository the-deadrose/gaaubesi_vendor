import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'dart:async';
import 'package:gaaubesi_vendor/configure/theme/theme.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_bloc.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_event.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_state.dart';

// Global RouteObserver for tracking route lifecycle
final RouteObserver<PageRoute> commentsRouteObserver =
    RouteObserver<PageRoute>();

@RoutePage()
class CommentsPage extends StatefulWidget {
  final int initialTab;

  const CommentsPage({super.key, this.initialTab = 0});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin,
        RouteAware {
  late TabController _tabController;
  final ScrollController _todayScrollController = ScrollController();
  final ScrollController _allScrollController = ScrollController();
  final ScrollController _filterScrollController = ScrollController();
  int _currentTabIndex = 0;
  bool _isTodaysAtBottom = false;
  bool _isAllAtBottom = false;
  bool _isFilterAtBottom = false;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'all';
  bool _isFiltering = false;
  int _currentFilterPage = 1;
  bool _hasSearched = false;
  bool _isFilterExpanded = false;
  Timer? _debounceTimer;
  final TextEditingController _replyController = TextEditingController();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    commentsRouteObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    debugPrint('[CommentsPage] didPopNext - User navigated back to this page');
    if (_hasLoadedOnce) {
      _refreshCurrentTab();
    }
  }

  @override
  void didPush() {
    debugPrint('[CommentsPage] didPush - Route pushed');
  }

  @override
  void didPop() {
    debugPrint('[CommentsPage] didPop - Route popped');
  }

  @override
  void didPushNext() {
    debugPrint('[CommentsPage] didPushNext - User navigated away from this page');
  }

  @override
  void didUpdateWidget(CommentsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasLoadedOnce && widget.initialTab != oldWidget.initialTab) {
      _currentTabIndex = widget.initialTab;
      _tabController.animateTo(widget.initialTab);
      _refreshCurrentTab();
    }
  }

  void _loadInitialData() {
    _hasLoadedOnce = true;
    if (widget.initialTab == 0) {
      context.read<CommentsBloc>().add(
        const FetchCommentsEvent(page: '1', isTodays: true),
      );
    } else {
      context.read<CommentsBloc>().add(
        const FetchCommentsEvent(page: '1', isTodays: false),
      );
    }
  }

  void _refreshCurrentTab() {
    debugPrint('[CommentsPage] Refreshing current tab: $_currentTabIndex');
    if (_currentTabIndex == 0) {
      context.read<CommentsBloc>().add(
        const RefreshCommentsEvent(isTodays: true),
      );
    } else {
      context.read<CommentsBloc>().add(
        const RefreshCommentsEvent(isTodays: false),
      );
    }
  }

  void _applyCurrentFilter() {
    if (!_isFiltering) {
      setState(() {
        _isFiltering = true;
        _hasSearched = true;
      });
    } else {
      setState(() {
        _hasSearched = true;
      });
    }

    _debounceTimer?.cancel();

    String? statusValue;
    if (_statusFilter != 'all') {
      statusValue = _statusFilter == 'pending' ? 'Pending' : 'Closed';
    }

    if (_currentTabIndex == 0) {
      context.read<CommentsBloc>().add(
        const FetchCommentsEvent(page: '1', isTodays: true),
      );
    } else {
      context.read<CommentsBloc>().add(
        FilterCommentsEvent(
          page: '1',
          status: statusValue,
          startDate: _startDate != null ? _formatDate(_startDate!) : null,
          endDate: _endDate != null ? _formatDate(_endDate!) : null,
          searchId: _searchController.text.isNotEmpty
              ? _searchController.text
              : null,
        ),
      );
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _startDate = null;
      _endDate = null;
      _statusFilter = 'all';
      _isFiltering = false;
      _hasSearched = false;
      _currentFilterPage = 1;
    });

    _debounceTimer?.cancel();

    context.read<CommentsBloc>().add(
      FetchCommentsEvent(page: '1', isTodays: _currentTabIndex == 0),
    );
  }

  int get _activeFilterCount {
    int count = 0;
    if (_searchController.text.isNotEmpty) count++;
    if (_startDate != null) count++;
    if (_endDate != null) count++;
    if (_statusFilter != 'all') count++;
    return count;
  }

  void _setupScrollListeners() {
    _todayScrollController.addListener(() {
      if (_currentTabIndex == 0) {
        _handleScroll(_todayScrollController, isToday: true);
      }
    });

    _allScrollController.addListener(() {
      if (_currentTabIndex == 1 && !_isFiltering) {
        _handleScroll(_allScrollController, isToday: false);
      }
    });

    _filterScrollController.addListener(() {
      if (_currentTabIndex == 1 && _isFiltering) {
        _handleFilterScroll();
      }
    });
  }

  void _handleScroll(ScrollController controller, {required bool isToday}) {
    if (!controller.hasClients) return;

    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    final threshold = maxScroll * 0.8;

    if (currentScroll >= threshold) {
      if (isToday && !_isTodaysAtBottom) {
        _isTodaysAtBottom = true;
        context.read<CommentsBloc>().add(
          const FetchMoreCommentsEvent(isTodays: true),
        );

        Future.delayed(const Duration(seconds: 1), () {
          _isTodaysAtBottom = false;
        });
      } else if (!isToday && !_isAllAtBottom) {
        _isAllAtBottom = true;
        context.read<CommentsBloc>().add(
          const FetchMoreCommentsEvent(isTodays: false),
        );

        Future.delayed(const Duration(seconds: 1), () {
          _isAllAtBottom = false;
        });
      }
    }
  }

  void _handleFilterScroll() {
    if (!_filterScrollController.hasClients) return;

    final maxScroll = _filterScrollController.position.maxScrollExtent;
    final currentScroll = _filterScrollController.position.pixels;
    final threshold = maxScroll * 0.8;

    if (currentScroll >= threshold) {
      if (!_isFilterAtBottom) {
        _isFilterAtBottom = true;
        _currentFilterPage++;

        context.read<CommentsBloc>().add(
          FilterCommentsEvent(
            page: _currentFilterPage.toString(),
            status: _statusFilter != 'all' ? _statusFilter : null,
            startDate: _startDate != null ? _formatDate(_startDate!) : null,
            endDate: _endDate != null ? _formatDate(_endDate!) : null,
            searchId: _searchController.text.isNotEmpty
                ? _searchController.text
                : null,
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          _isFilterAtBottom = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging &&
        _tabController.index != _currentTabIndex) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });

      final bloc = context.read<CommentsBloc>();
      final currentState = bloc.state;

      if (_tabController.index == 0) {
        if (currentState is! TodaysCommentsLoaded &&
            currentState is! CommentsLoading) {
          bloc.add(const FetchCommentsEvent(page: '1', isTodays: true));
        }
      } else {
        if (currentState is! AllCommentsLoaded &&
            currentState is! CommentsLoading) {
          bloc.add(const FetchCommentsEvent(page: '1', isTodays: false));
        }
      }
    }
  }

  Future<void> _onRefresh({required bool isToday}) async {
    context.read<CommentsBloc>().add(RefreshCommentsEvent(isTodays: isToday));
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    commentsRouteObserver.unsubscribe(this);
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _todayScrollController.dispose();
    _allScrollController.dispose();
    _filterScrollController.dispose();
    _searchController.dispose();
    _replyController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: AppTheme.whiteSmoke,
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.router.pop(),
          ),
          title: const Text(
            'Comments',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              letterSpacing: 0.2,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppTheme.marianBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _refreshCurrentTab,
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            _buildFilterSection(),
            const SizedBox(height: 12),
            _buildTabBar(),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildTodayTab(), _buildAllTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: AppTheme.powerBlue.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.marianBlue.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.marianBlue,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: AppTheme.marianBlue.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.darkGray,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        dividerHeight: 0,
        indicatorSize: TabBarIndicatorSize.tab,
        splashBorderRadius: BorderRadius.circular(10.0),
        tabs: const [
          Tab(
            icon: Icon(Icons.today_rounded, size: 18),
            iconMargin: EdgeInsets.only(bottom: 2),
            text: "Today's",
            height: 48,
          ),
          Tab(
            icon: Icon(Icons.forum_rounded, size: 18),
            iconMargin: EdgeInsets.only(bottom: 2),
            text: 'All',
            height: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    return BlocConsumer<CommentsBloc, CommentsState>(
      listener: (context, state) {
        if (state is TodaysCommentsError) {
          _showSnack(state.message, isError: true);
        } else if (state is TodaysCommentsLoaded && _isFiltering) {
          setState(() {});
        } else if (state is CommentReplySuccess) {
          _showSnack('Comment replied and closed successfully');
          _onRefresh(isToday: true);
        } else if (state is CommentReplyError) {
          _showSnack('Failed to reply: ${state.message}', isError: true);
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
          color: AppTheme.marianBlue,
          onRefresh: () => _onRefresh(isToday: true),
          child: _buildCommentsList(
            scrollController: _todayScrollController,
            isToday: true,
            state: state,
          ),
        );
      },
    );
  }

  Widget _buildAllTab() {
    return BlocConsumer<CommentsBloc, CommentsState>(
      listener: (context, state) {
        if (state is FilteredCommentsLoaded) {
          if (!_isFiltering) {
            setState(() {
              _isFiltering = true;
            });
          }
        } else if (state is AllCommentsLoaded) {
          if (_isFiltering &&
              _searchController.text.isEmpty &&
              _startDate == null &&
              _endDate == null &&
              _statusFilter == 'all') {
            setState(() {
              _isFiltering = false;
            });
          }
        } else if (state is AllCommentsError) {
          _showSnack(state.message, isError: true);
        } else if (state is CommentReplySuccess) {
          _showSnack('Comment replied and closed successfully');
          _onRefresh(isToday: false);
        } else if (state is CommentReplyError) {
          _showSnack('Failed to reply: ${state.message}', isError: true);
        }
      },
      builder: (context, state) {
        final scrollController = _isFiltering
            ? _filterScrollController
            : _allScrollController;

        return RefreshIndicator(
          color: AppTheme.marianBlue,
          onRefresh: () => _onRefresh(isToday: false),
          child: _buildCommentsList(
            scrollController: scrollController,
            isToday: false,
            state: state,
          ),
        );
      },
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppTheme.rojo : AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildCommentsList({
    required ScrollController scrollController,
    required bool isToday,
    required CommentsState state,
  }) {
    if (state is CommentsInitial || state is CommentsLoading) {
      return _buildLoading();
    }

    if (isToday && state is TodaysCommentsError) {
      final errorState = state;
      final errorMessage = errorState.message;
      final previousResponse = errorState.previousResponse;

      if (previousResponse != null &&
          (previousResponse.results?.isNotEmpty ?? false)) {
        return Column(
          children: [
            Expanded(
              child: _buildComments(
                response: previousResponse,
                scrollController: scrollController,
                isToday: isToday,
                state: state,
              ),
            ),
            _buildErrorBanner(errorMessage),
          ],
        );
      }

      return _buildError(
        errorMessage,
        () => context.read<CommentsBloc>().add(
          FetchCommentsEvent(page: '1', isTodays: isToday),
        ),
      );
    } else if (!isToday && state is AllCommentsError) {
      final errorState = state;
      final errorMessage = errorState.message;
      final previousResponse = errorState.previousResponse;

      if (previousResponse != null &&
          (previousResponse.results?.isNotEmpty ?? false)) {
        return Column(
          children: [
            Expanded(
              child: _buildComments(
                response: previousResponse,
                scrollController: scrollController,
                isToday: isToday,
                state: state,
              ),
            ),
            _buildErrorBanner(errorMessage),
          ],
        );
      }

      return _buildError(
        errorMessage,
        () => context.read<CommentsBloc>().add(
          FetchCommentsEvent(page: '1', isTodays: isToday),
        ),
      );
    }

    if (isToday && state is TodaysCommentsLoaded) {
      return _buildComments(
        response: state.response,
        scrollController: scrollController,
        isToday: true,
        state: state,
      );
    } else if (!isToday && state is AllCommentsLoaded) {
      return _buildComments(
        response: state.response,
        scrollController: scrollController,
        isToday: false,
        state: state,
      );
    } else if (!isToday && state is FilteredCommentsLoaded) {
      return _buildComments(
        response: state.response,
        scrollController: scrollController,
        isToday: false,
        state: state,
        isFiltered: true,
      );
    }

    return const SizedBox();
  }

  Widget _buildComments({
    required CommentsResponseEntity response,
    required ScrollController scrollController,
    required bool isToday,
    required CommentsState state,
    bool isFiltered = false,
  }) {
    final comments = response.results ?? [];

    late final bool isLoadingMore;
    late final bool hasReachedMax;
    late final bool isRefreshing;

    if (isFiltered && state is FilteredCommentsLoaded) {
      isLoadingMore = state.isLoadingMore;
      hasReachedMax = state.hasReachedMax;
      isRefreshing = false;
    } else if (isToday && state is TodaysCommentsLoaded) {
      isLoadingMore = state.isLoadingMore;
      hasReachedMax = state.hasReachedMax;
      isRefreshing = state.isRefreshing;
    } else if (state is AllCommentsLoaded) {
      isLoadingMore = state.isLoadingMore;
      hasReachedMax = state.hasReachedMax;
      isRefreshing = state.isRefreshing;
    } else {
      isLoadingMore = false;
      hasReachedMax = true;
      isRefreshing = false;
    }

    if (comments.isEmpty && !isLoadingMore && !isRefreshing) {
      return _buildEmpty();
    }

    final shouldApplyLocalFilters =
        (!isFiltered && _currentTabIndex == 0) ||
        (!isFiltered && _isFiltering && _currentTabIndex == 0);

    final filteredComments = shouldApplyLocalFilters
        ? _applyFilters(comments)
        : comments;

    if (filteredComments.isEmpty &&
        comments.isNotEmpty &&
        shouldApplyLocalFilters) {
      return _buildNoResultsFound();
    }

    return RefreshIndicator(
      color: AppTheme.marianBlue,
      onRefresh: () => _onRefresh(isToday: isToday),
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount:
            filteredComments.length +
            (isLoadingMore ? 1 : 0) +
            (hasReachedMax && filteredComments.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredComments.length) {
            if (isLoadingMore) {
              return _buildLoadMoreIndicator();
            } else if (hasReachedMax && filteredComments.isNotEmpty) {
              return _buildEndOfList();
            }
          }

          if (index < filteredComments.length) {
            final comment = filteredComments[index];
            return _buildEnhancedCommentCard(comment);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEnhancedCommentCard(CommentEntity comment) {
    final bool isImportant = comment.isImportant;
    final bool canReply = comment.canReply;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            final orderIdInt = int.tryParse(comment.orderId);
            if (orderIdInt != null) {
              context.router.push(OrderDetailRoute(orderId: orderIdInt));
            }
          },
          splashColor: AppTheme.marianBlue.withValues(alpha: 0.06),
          highlightColor: AppTheme.marianBlue.withValues(alpha: 0.03),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isImportant
                    ? AppTheme.rojo.withValues(alpha: 0.35)
                    : AppTheme.powerBlue.withValues(alpha: 0.25),
                width: isImportant ? 1.2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.marianBlue.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Priority accent stripe
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isImportant
                            ? [
                                AppTheme.rojo,
                                AppTheme.rojo.withValues(alpha: 0.6),
                              ]
                            : [
                                AppTheme.marianBlue,
                                AppTheme.marianBlue.withValues(alpha: 0.7),
                              ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row: avatar + order id + status + chevron
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildOrderAvatar(comment.orderId, isImportant),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Order #${comment.orderId}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.blackBean,
                                              letterSpacing: 0.2,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isImportant) ...[
                                          const SizedBox(width: 6),
                                          _buildImportantBadge(),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.schedule_rounded,
                                          size: 12,
                                          color: AppTheme.darkGray
                                              .withValues(alpha: 0.7),
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            comment.createdOnFormatted,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              color: AppTheme.darkGray,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildStatusPill(canReply),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Comment body
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.whiteSmoke,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppTheme.powerBlue
                                    .withValues(alpha: 0.18),
                              ),
                            ),
                            child: Text(
                              comment.comments,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: AppTheme.blackBean,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Footer: branch + actions
                          Row(
                            children: [
                              Icon(
                                Icons.storefront_rounded,
                                size: 15,
                                color: AppTheme.marianBlue
                                    .withValues(alpha: 0.75),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  comment.branchName,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.blackBean,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (canReply) ...[
                                const SizedBox(width: 8),
                                _buildReplyButton(comment),
                              ] else
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                  color: AppTheme.darkGray
                                      .withValues(alpha: 0.6),
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
      ),
    );
  }

  Widget _buildOrderAvatar(String orderId, bool isImportant) {
    final Color base =
        isImportant ? AppTheme.rojo : AppTheme.marianBlue;
    final String initials = orderId.length >= 2
        ? orderId.substring(orderId.length - 2)
        : orderId;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            base.withValues(alpha: 0.15),
            base.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: base.withValues(alpha: 0.25)),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: base,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(bool isPending) {
    final Color color =
        isPending ? AppTheme.warningYellow : AppTheme.successGreen;
    final String label = isPending ? 'Pending' : 'Closed';
    final IconData icon = isPending
        ? Icons.hourglass_empty_rounded
        : Icons.check_circle_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.rojo.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.priority_high_rounded,
            size: 10,
            color: AppTheme.rojo,
          ),
          const SizedBox(width: 2),
          Text(
            'URGENT',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppTheme.rojo,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyButton(CommentEntity comment) {
    return Material(
      color: AppTheme.marianBlue,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => _showCloseCommentDialog(comment),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.reply_rounded, size: 14, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'Reply',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const _ShimmerCommentCard();
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
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.rojo.withValues(alpha: 0.12),
                    AppTheme.rojo.withValues(alpha: 0.02),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.rojo.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    Icons.cloud_off_rounded,
                    size: 34,
                    color: AppTheme.rojo,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.blackBean,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.marianBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.rojo.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.rojo.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppTheme.rojo, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.blackBean,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.marianBlue.withValues(alpha: 0.12),
                          AppTheme.marianBlue.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.marianBlue.withValues(alpha: 0.12),
                        ),
                        child: Icon(
                          Icons.forum_outlined,
                          size: 38,
                          color: AppTheme.marianBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No comments yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.blackBean,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "You're all caught up!\nNew comments will appear here.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.marianBlue,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Loading more...',
              style: TextStyle(
                fontSize: 12.5,
                color: AppTheme.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndOfList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 1,
              color: AppTheme.powerBlue.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.check_circle_outline_rounded,
              size: 14,
              color: AppTheme.darkGray,
            ),
            const SizedBox(width: 6),
            Text(
              "You've reached the end",
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.darkGray,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 30,
              height: 1,
              color: AppTheme.powerBlue.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final int activeCount = _activeFilterCount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: _isFilterExpanded
              ? AppTheme.marianBlue.withValues(alpha: 0.25)
              : AppTheme.powerBlue.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.marianBlue.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isFilterExpanded = !_isFilterExpanded;
                });
              },
              borderRadius: BorderRadius.circular(14.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.marianBlue.withValues(alpha: 0.15),
                            AppTheme.marianBlue.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: AppTheme.marianBlue,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.blackBean,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (activeCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.rojo,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$activeCount',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (_hasSearched && !_isFilterExpanded)
                      TextButton(
                        onPressed: _clearFilters,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          minimumSize: const Size(0, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: AppTheme.rojo,
                        ),
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    AnimatedRotation(
                      turns: _isFilterExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: AppTheme.marianBlue,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _isFilterExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          color: AppTheme.powerBlue.withValues(alpha: 0.25),
                          height: 8,
                        ),
                        const SizedBox(height: 10),
                        if (_currentTabIndex != 0) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateSelector(
                                  label: 'Start Date',
                                  date: _startDate,
                                  onTap: () =>
                                      _selectDate(context, isStartDate: true),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildDateSelector(
                                  label: 'End Date',
                                  date: _endDate,
                                  onTap: () =>
                                      _selectDate(context, isStartDate: false),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],

                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 48,
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: AppTheme.blackBean,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search by Order ID',
                                    hintStyle: TextStyle(
                                      color: AppTheme.darkGray,
                                      fontSize: 13,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      color: AppTheme.marianBlue,
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor: AppTheme.whiteSmoke,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: AppTheme.powerBlue
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: AppTheme.powerBlue
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: AppTheme.marianBlue,
                                        width: 1.5,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.whiteSmoke,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppTheme.powerBlue
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _statusFilter,
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppTheme.marianBlue,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: AppTheme.blackBean,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'all',
                                        child: Text(
                                          'All Status',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'pending',
                                        child: Text(
                                          'Pending',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'closed',
                                        child: Text(
                                          'Closed',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _statusFilter = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: OutlinedButton.icon(
                                  onPressed:
                                      _hasSearched ? _clearFilters : null,
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('Clear'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _hasSearched
                                        ? AppTheme.rojo
                                        : AppTheme.darkGray,
                                    side: BorderSide(
                                      color: _hasSearched
                                          ? AppTheme.rojo
                                              .withValues(alpha: 0.6)
                                          : AppTheme.powerBlue
                                              .withValues(alpha: 0.4),
                                      width: 1.2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 44,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _currentFilterPage = 1;
                                    _isFilterAtBottom = false;
                                    _applyCurrentFilter();
                                  },
                                  icon: const Icon(
                                    Icons.search_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('Apply Filters'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.marianBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                    textStyle: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final bool hasDate = date != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.whiteSmoke,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasDate
                  ? AppTheme.marianBlue.withValues(alpha: 0.45)
                  : AppTheme.powerBlue.withValues(alpha: 0.3),
              width: hasDate ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: hasDate ? AppTheme.marianBlue : AppTheme.darkGray,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hasDate
                          ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                          : 'Select',
                      style: TextStyle(
                        fontSize: 13,
                        color: hasDate
                            ? AppTheme.blackBean
                            : AppTheme.darkGray,
                        fontWeight: hasDate
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.marianBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.blackBean,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  List<CommentEntity> _applyFilters(List<CommentEntity> comments) {
    List<CommentEntity> filteredComments = List.from(comments);

    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filteredComments = filteredComments.where((comment) {
        return comment.comments.toLowerCase().contains(searchTerm) ||
            comment.orderId.toString().contains(searchTerm) ||
            comment.branchName.toLowerCase().contains(searchTerm);
      }).toList();
    }

    if (_statusFilter != 'all') {}

    if (_startDate != null) {
      filteredComments = filteredComments.where((comment) {
        return true;
      }).toList();
    }

    if (_endDate != null) {
      filteredComments = filteredComments.where((comment) {
        return true;
      }).toList();
    }

    return filteredComments;
  }

  Widget _buildNoResultsFound() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.darkGray.withValues(alpha: 0.12),
                          AppTheme.darkGray.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.lightGray,
                        ),
                        child: Icon(
                          Icons.search_off_rounded,
                          size: 34,
                          color: AppTheme.darkGray,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No results found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.blackBean,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Try adjusting your filters or\nsearch terms',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.darkGray,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _startDate = null;
                        _endDate = null;
                        _statusFilter = 'all';
                        _isFiltering = false;
                        _hasSearched = false;
                        _currentFilterPage = 1;
                      });
                      context.read<CommentsBloc>().add(
                        const FetchCommentsEvent(page: '1', isTodays: false),
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Reset Filters'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.marianBlue,
                      side: BorderSide(
                        color: AppTheme.marianBlue.withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCloseCommentDialog(CommentEntity comment) {
    _replyController.clear();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                final int charCount = _replyController.text.length;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.marianBlue.withValues(alpha: 0.06),
                            AppTheme.marianBlue.withValues(alpha: 0.02),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.marianBlue,
                                  AppTheme.marianBlue.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.marianBlue
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.reply_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Reply to Comment',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.blackBean,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Closes this comment when sent',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppTheme.darkGray,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                            ),
                            color: AppTheme.darkGray,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Original comment preview
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.whiteSmoke,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppTheme.powerBlue
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.receipt_long_rounded,
                                      size: 14,
                                      color: AppTheme.marianBlue,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Order #${comment.orderId}',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.marianBlue,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  comment.comments,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.blackBean,
                                    height: 1.5,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Your reply',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.blackBean,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              Text(
                                '$charCount/500',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.darkGray,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _replyController,
                            maxLines: 4,
                            maxLength: 500,
                            onChanged: (_) => setDialogState(() {}),
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppTheme.blackBean,
                              height: 1.4,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Type your reply message...',
                              hintStyle: TextStyle(
                                color: AppTheme.darkGray.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: AppTheme.whiteSmoke,
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: AppTheme.powerBlue
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: AppTheme.powerBlue
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppTheme.marianBlue,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.darkGray,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _closeComment(
                                    comment.id.toString(),
                                    _replyController.text,
                                  );
                                },
                                icon: const Icon(
                                  Icons.send_rounded,
                                  size: 15,
                                ),
                                label: const Text('Send Reply'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.marianBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _closeComment(String commentId, String reply) {
    if (reply.isNotEmpty) {
      context.read<CommentsBloc>().add(
        ReplyToCommentEvent(commentId: commentId, comment: reply),
      );
    } else {
      _showSnack('Comment closed');
    }
  }
}

class _ShimmerCommentCard extends StatefulWidget {
  const _ShimmerCommentCard();

  @override
  State<_ShimmerCommentCard> createState() => _ShimmerCommentCardState();
}

class _ShimmerCommentCardState extends State<_ShimmerCommentCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.powerBlue.withValues(alpha: 0.2),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.powerBlue.withValues(alpha: 0.2),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _shimmerBox(40, 40, radius: 12),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _shimmerBox(110, 12),
                                  const SizedBox(height: 6),
                                  _shimmerBox(80, 10),
                                ],
                              ),
                            ),
                            _shimmerBox(58, 20, radius: 10),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _shimmerBox(double.infinity, 50, radius: 10),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _shimmerBox(14, 14, radius: 4),
                            const SizedBox(width: 6),
                            _shimmerBox(120, 10),
                            const Spacer(),
                            _shimmerBox(60, 24, radius: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _shimmerBox(double width, double height, {double radius = 4}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          Container(
            width: width,
            height: height,
            color: AppTheme.lightGray,
          ),
          Positioned.fill(
            child: FractionalTranslation(
              translation: Offset(-1.0 + _controller.value * 2.0, 0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppTheme.lightGray.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.6),
                      AppTheme.lightGray.withValues(alpha: 0),
                    ],
                    stops: const [0.3, 0.5, 0.7],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
