import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
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
  int _currentTabIndex = 0;

  // Track if we're at the bottom to avoid multiple pagination calls
  bool _isTodaysAtBottom = false;
  bool _isAllAtBottom = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _currentTabIndex = widget.initialTab;

    // Initial fetch
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

  void _setupScrollListeners() {
    _todayScrollController.addListener(() {
      if (_currentTabIndex == 0) {
        _handleScroll(_todayScrollController, isToday: true);
      }
    });

    _allScrollController.addListener(() {
      if (_currentTabIndex == 1) {
        _handleScroll(_allScrollController, isToday: false);
      }
    });
  }

  void _handleScroll(ScrollController controller, {required bool isToday}) {
    if (!controller.hasClients) return;

    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    final threshold = maxScroll * 0.8; // 80% scroll threshold

    if (currentScroll >= threshold) {
      if (isToday && !_isTodaysAtBottom) {
        _isTodaysAtBottom = true;
        context.read<CommentsBloc>().add(
          const FetchMoreCommentsEvent(isTodays: true),
        );

        // Reset after 1 second to allow another pagination
        Future.delayed(const Duration(seconds: 1), () {
          _isTodaysAtBottom = false;
        });
      } else if (!isToday && !_isAllAtBottom) {
        _isAllAtBottom = true;
        context.read<CommentsBloc>().add(
          const FetchMoreCommentsEvent(isTodays: false),
        );

        // Reset after 1 second
        Future.delayed(const Duration(seconds: 1), () {
          _isAllAtBottom = false;
        });
      }
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging &&
        _tabController.index != _currentTabIndex) {
      _currentTabIndex = _tabController.index;

      // Fetch data for the new tab if not already loaded
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF21428A), // _marianBlue
                borderRadius: BorderRadius.circular(10.0),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              dividerHeight: 0,
              tabs: const [
                Tab(text: 'Today\'s comments'),
                Tab(text: 'All comments'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTodayTab(), _buildAllTab()],
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
        if (state is AllCommentsError) {
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
          onRefresh: () => _onRefresh(isToday: false),
          child: _buildCommentsList(
            scrollController: _allScrollController,
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
    // Loading state
    if (state is CommentsInitial || state is CommentsLoading) {
      return _buildLoading();
    }

    // Error state
    if ((isToday && state is TodaysCommentsError) ||
        (!isToday && state is AllCommentsError)) {
      final errorState = state as dynamic;
      final errorMessage = errorState.message;
      final previousResponse = errorState.previousResponse;

      // If we have previous data, show it with error
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

    // Loaded states
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
    }

    return const SizedBox();
  }

  Widget _buildComments({
    required CommentsResponseEntity response,
    required ScrollController scrollController,
    required bool isToday,
    required CommentsState state,
  }) {
    final comments = response.results ?? [];
    final isLoadingMore = isToday
        ? (state as TodaysCommentsLoaded).isLoadingMore
        : (state as AllCommentsLoaded).isLoadingMore;
    final hasReachedMax = isToday
        ? (state as TodaysCommentsLoaded).hasReachedMax
        : (state as AllCommentsLoaded).hasReachedMax;
    final isRefreshing = isToday
        ? (state as TodaysCommentsLoaded).isRefreshing
        : (state as AllCommentsLoaded).isRefreshing;

    if (comments.isEmpty && !isLoadingMore && !isRefreshing) {
      return _buildEmpty();
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(12),
      itemCount:
          comments.length +
          (isLoadingMore ? 1 : 0) +
          (hasReachedMax && comments.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == comments.length) {
          if (isLoadingMore) {
            return _buildLoadMoreIndicator();
          } else if (hasReachedMax && comments.isNotEmpty) {
            return _buildEndOfList();
          }
        }

        if (index < comments.length) {
          final comment = comments[index];
          return _buildCommentCard(comment);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildCommentCard(CommentEntity comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${comment.orderId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (comment.isImportant)
                  Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Comment text
            Text(
              comment.comments,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),

            const SizedBox(height: 12),

            // Metadata
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  comment.createdOnFormatted,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 12),
                Icon(Icons.store, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  comment.branchName,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // User info
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    comment.addedByName.isNotEmpty
                        ? comment.addedByName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.addedByName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      comment.addedByRole,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                // Skeleton for order ID
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
                // Skeleton for comment text
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
                // Skeleton for metadata
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
}
