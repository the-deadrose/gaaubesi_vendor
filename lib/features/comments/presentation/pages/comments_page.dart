import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'dart:async';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_bloc.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_event.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_state.dart';

@RoutePage()
class CommentsPage extends StatefulWidget {
  final int initialTab;

  const CommentsPage({super.key, this.initialTab = 0});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
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
      if (widget.initialTab == 0) {
        context.read<CommentsBloc>().add(
          const FetchCommentsEvent(page: '1', isTodays: true),
        );
      } else {
        context.read<CommentsBloc>().add(
          const FetchCommentsEvent(page: '1', isTodays: false),
        );
      }
    });

    _tabController.addListener(_onTabChanged);
    _setupScrollListeners();
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
    return Scaffold(
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
          'Comments',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.marianBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          const SizedBox(height: 8),
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
                  icon: Icon(Icons.today, size: 20),
                  text: 'Today\'s',
                  height: 46,
                ),
                Tab(icon: Icon(Icons.list, size: 20), text: 'All', height: 46),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildTodayTab(), _buildAllTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    return BlocConsumer<CommentsBloc, CommentsState>(
      listener: (context, state) {
        if (state is TodaysCommentsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is TodaysCommentsLoaded && _isFiltering) {
          setState(() {});
        } else if (state is CommentReplySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comment replied and closed successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          _onRefresh(isToday: true);
        } else if (state is CommentReplyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reply: ${state.message}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is CommentReplySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comment replied and closed successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          _onRefresh(isToday: false);
        } else if (state is CommentReplyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reply: ${state.message}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        final scrollController = _isFiltering
            ? _filterScrollController
            : _allScrollController;

        return RefreshIndicator(
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
      onRefresh: () => _onRefresh(isToday: isToday),
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(12),
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
    return InkWell(
      onTap: () {
        final orderIdInt = int.tryParse(comment.orderId);
        if (orderIdInt != null) {
          context.router.push(OrderDetailRoute(orderId: orderIdInt));
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: comment.isImportant
                ? AppTheme.rojo.withValues(alpha: 0.4)
                : Colors.transparent,
            width: comment.isImportant ? 1.5 : 0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.marianBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.document_scanner,
                          size: 16,
                          color: AppTheme.marianBlue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          comment.orderId,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.marianBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  Text(
                    comment.createdOnFormatted,
                    style: TextStyle(fontSize: 12, color: AppTheme.darkGray),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                comment.comments,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: AppTheme.blackBean,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Icon(Icons.store, size: 16, color: AppTheme.marianBlue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      comment.branchName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.blackBean,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (comment.canReply) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _showCloseCommentDialog(comment);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.reply, size: 14),
                          const SizedBox(width: 4),
                          const Text(
                            'Mark as Closed',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 8),
              if (comment.isImportant)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.rojo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.priority_high, size: 14, color: AppTheme.rojo),
                      SizedBox(width: 4),
                      Text(
                        'Important',
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
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  height: 20,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 16,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: 200,
                  height: 16,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 16,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    SizedBox(
                      width: 60,
                      height: 16,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
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

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.comment_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No comments yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Comments will appear here when added',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
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
        child: Text(
          'No more comments',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.lightGray, width: 1),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.marianBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.filter_list,
                      color: AppTheme.marianBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.blackBean,
                    ),
                  ),
                  const Spacer(),
                  if (_hasSearched)
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.rojo.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.rojo,
                        ),
                      ),
                    ),
                  AnimatedRotation(
                    turns: _isFilterExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.expand_more,
                      color: AppTheme.marianBlue,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 16),
            padding: _isFilterExpanded
                ? const EdgeInsets.symmetric(horizontal: 16.0)
                : EdgeInsets.zero,
            height: _isFilterExpanded ? null : 0,
            child: _isFilterExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            const SizedBox(width: 12),
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
                        const SizedBox(height: 16),
                      ],

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search by Order ID...',
                                hintStyle: TextStyle(
                                  color: AppTheme.darkGray.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppTheme.marianBlue,
                                ),
                                filled: true,
                                fillColor: AppTheme.lightGray,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppTheme.powerBlue.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppTheme.marianBlue,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.lightGray,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.powerBlue.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _statusFilter,
                                  isExpanded: true,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppTheme.marianBlue,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
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
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _currentFilterPage = 1;
                                _isFilterAtBottom = false;
                                _applyCurrentFilter();
                              },
                              icon: const Icon(Icons.search, size: 18),
                              label: const Text('Apply Filters'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.marianBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _hasSearched ? _clearFilters : null,
                              icon: const Icon(Icons.clear, size: 18),
                              label: const Text('Clear All'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _hasSearched
                                    ? AppTheme.rojo
                                    : AppTheme.darkGray,
                                side: BorderSide(
                                  color: _hasSearched
                                      ? AppTheme.rojo
                                      : AppTheme.darkGray.withValues(
                                          alpha: 0.5,
                                        ),
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : null,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null
                ? AppTheme.marianBlue.withValues(alpha: 0.5)
                : AppTheme.powerBlue.withValues(alpha: 0.3),
            width: date != null ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: date != null ? AppTheme.marianBlue : AppTheme.darkGray,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      color: date != null
                          ? AppTheme.blackBean
                          : AppTheme.darkGray,
                      fontWeight: date != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off, size: 50, color: AppTheme.darkGray),
            ),
            const SizedBox(height: 24),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.blackBean,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your filters or search terms',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.darkGray,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
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
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.marianBlue,
                side: const BorderSide(color: AppTheme.marianBlue, width: 1.5),
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

  void _showCloseCommentDialog(CommentEntity comment) {
    _replyController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.comment, color: AppTheme.marianBlue, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Close Comment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${comment.orderId}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.marianBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                comment.comments,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.blackBean,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              const Text(
                'Add a reply (optional):',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _replyController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Type your reply...',
                  hintStyle: TextStyle(
                    color: AppTheme.darkGray.withValues(alpha: 0.6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.powerBlue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.marianBlue),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _closeComment(comment.id.toString(), _replyController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.marianBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Close'),
            ),
          ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment closed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
