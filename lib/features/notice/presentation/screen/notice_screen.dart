import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/notice/domain/entity/notice_list_entity.dart';
import 'package:gaaubesi_vendor/features/notice/presentation/bloc/notice_bloc.dart';
import 'package:gaaubesi_vendor/features/notice/presentation/bloc/notice_event.dart';
import 'package:gaaubesi_vendor/features/notice/presentation/bloc/notice_state.dart';

@RoutePage()
class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({super.key});

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialLoad = true;
  bool _isLoadingMore = false;
  late AnimationController _shimmerController;
  late Animation<Color?> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerAnimation = ColorTween(
      begin: Colors.grey.shade300,
      end: Colors.grey.shade100,
    ).animate(_shimmerController);

    _fetchInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _fetchInitialData() {
    context.read<NoticeBloc>().add(FetchNoticeList());
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll * 0.8 && !_isLoadingMore) {
      _isLoadingMore = true;
      context.read<NoticeBloc>().add(FetchNoticeList());
    }
  }

  Future<void> _refreshData() async {
    _isInitialLoad = true;
    _isLoadingMore = false;
    _fetchInitialData();
  }

  void _navigateToDetailScreen(BuildContext context, Notice notice) {
    context.router.push(NoticeDetailRoute(notice: notice));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Notices'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: BlocConsumer<NoticeBloc, NoticeState>(
        listener: (context, state) {
          if (state is NoticeListLoaded ||
              state is NoticeListPaginated ||
              state is NoticeListSearchLoaded) {
            _isInitialLoad = false;
            _isLoadingMore = false;
          }

          if (state is NoticeListError || state is NoticeListPaginationError) {
            _isLoadingMore = false;
          }
        },
        builder: (context, state) {
          return _buildContent(state, context);
        },
      ),
    );
  }

  Widget _buildContent(NoticeState state, BuildContext context) {
    if (_isInitialLoad && state is! NoticeListLoaded) {
      return _buildShimmerLoading();
    }

    if (state is NoticeListError) {
      return _buildErrorState(state.message);
    }

    if (state is NoticeListLoaded || state is NoticeListPaginated) {
      final notices = (state is NoticeListLoaded)
          ? state.noticeListResponse.notices
          : (state as NoticeListPaginated).noticeListResponse.notices;

      if (notices.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: notices.length + (_hasNextPage(state) ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == notices.length && _hasNextPage(state)) {
              return _buildLoadMoreIndicator();
            }
            return _buildNoticeCard(notices[index], context);
          },
        ),
      );
    }

    if (state is NoticeListPaginating) {
      return _buildShimmerLoading();
    }

    return _buildShimmerLoading();
  }

  Widget _buildShimmerLoading() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: 6, // Show 6 shimmer items
          itemBuilder: (context, index) {
            return _buildShimmerNoticeCard();
          },
        );
      },
    );
  }

  Widget _buildShimmerNoticeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status dot shimmer
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _shimmerAnimation.value,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Title shimmer
                    Expanded(
                      child: Container(
                        height: 18,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _shimmerAnimation.value,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Popup badge shimmer (optional)
                    Container(
                      width: 50,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _shimmerAnimation.value,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Content preview shimmer - first line
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _shimmerAnimation.value,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                // Content preview shimmer - second line (shorter)
                Container(
                  height: 14,
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    color: _shimmerAnimation.value,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Created by shimmer
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: _shimmerAnimation.value,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Spacer(),
                    // Date shimmer
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: _shimmerAnimation.value,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Divider shimmer
                Container(
                  height: 1,
                  color: _shimmerAnimation.value,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasNextPage(NoticeState state) {
    if (state is NoticeListLoaded) {
      return state.noticeListResponse.next != null;
    }
    if (state is NoticeListPaginated) {
      return state.noticeListResponse.next != null;
    }
    return false;
  }

  Widget _buildNoticeCard(Notice notice, BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _navigateToDetailScreen(context, notice),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusDot(notice),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notice.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                notice.isRead ? FontWeight.w500 : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (notice.isPopup) _buildPopupBadge(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildContentPreview(notice.content),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        notice.createdByName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        notice.createdOnFormatted,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey.shade300,
                    thickness: 1,
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentPreview(String htmlContent) {
    final plainText = htmlContent
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return Text(
      plainText.length > 150 ? '${plainText.substring(0, 150)}...' : plainText,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: Colors.grey, fontSize: 14),
    );
  }

  Widget _buildStatusDot(Notice notice) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: notice.isRead ? Colors.grey : Colors.blue,
      ),
    );
  }

  Widget _buildPopupBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'POPUP',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading more...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              const Text(
                'No notices available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You will see notices here once available',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchInitialData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }
}