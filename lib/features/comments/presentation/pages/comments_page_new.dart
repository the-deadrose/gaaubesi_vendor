import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_bloc.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_event.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_state.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/widget/comment_card.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/widget/empty_comments.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/widget/error_widget.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/widget/loading_indicator.dart';

@RoutePage()
class CommentsPageNew extends StatefulWidget {
  final int initialTab;
  
  const CommentsPageNew({super.key, this.initialTab = 0});
  
  @override
  State<CommentsPageNew> createState() => _CommentsPageNewState();
}

class _CommentsPageNewState extends State<CommentsPageNew>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today\'s Comments'),
            Tab(text: 'All Comments'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Refresh based on current tab
              if (_tabController.index == 0) {
                context.read<CommentsBloc>().add(const RefreshCommentsEvent(isTodays: true));
              } else {
                context.read<CommentsBloc>().add(const RefreshCommentsEvent(isTodays: false));
              }
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodaysCommentsTab(),
          _buildAllCommentsTab(),
        ],
      ),
    );
  }
  
  Widget _buildTodaysCommentsTab() {
    return BlocConsumer<CommentsBloc, CommentsState>(
      listener: (context, state) {
        if (state is CommentsError && state.isTodays) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return _buildCommentsList(
          state: state,
          comments: state is CommentsLoaded ? state.response.results : null,
          hasReachedMax: state is CommentsLoaded ? state.hasReachedMax : false,
          isLoadingMore: state is CommentsLoadingMore,
          onRefresh: () => context.read<CommentsBloc>().add(const RefreshCommentsEvent(isTodays: true)),
          onFetchMore: () => context.read<CommentsBloc>().add(const FetchMoreCommentsEvent(isTodays: true)),
          onRetry: () => context.read<CommentsBloc>().add(const FetchCommentsEvent(page: '1', isTodays: true)),
        );
      },
    );
  }
  
  Widget _buildAllCommentsTab() {
    return BlocConsumer<CommentsBloc, CommentsState>(
      listener: (context, state) {
        if (state is CommentsError && !state.isTodays) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return _buildCommentsList(
          state: state,
          comments: state is CommentsLoaded ? state.response.results : null,
          hasReachedMax: state is CommentsLoaded ? state.hasReachedMax : false,
          isLoadingMore: state is CommentsLoadingMore,
          onRefresh: () => context.read<CommentsBloc>().add(const RefreshCommentsEvent(isTodays: false)),
          onFetchMore: () => context.read<CommentsBloc>().add(const FetchMoreCommentsEvent(isTodays: false)),
          onRetry: () => context.read<CommentsBloc>().add(const FetchCommentsEvent(page: '1', isTodays: false)),
        );
      },
    );
  }
  
  Widget _buildCommentsList({
    required dynamic state,
    required List<CommentEntity>? comments,
    required bool hasReachedMax,
    required bool isLoadingMore,
    required VoidCallback onRefresh,
    required VoidCallback onFetchMore,
    required VoidCallback onRetry,
  }) {
    if (state is CommentsInitial || state is CommentsLoading) {
      return const LoadingIndicator();
    }

    if ((state is CommentsError) && 
        (state is! CommentsLoaded)) {
      return ErrorMessageWidget(
        message: state.message,
        onRetry: onRetry,
      );
    }

    if ((state is CommentsLoaded) && 
        (comments == null || comments.isEmpty)) {
      return const EmptyCommentsWidget();
    }

    if (state is CommentsLoaded) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            // Check if we've reached the end of the list
            final isAtBottom = scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent;
            
            // Load more when we're at the bottom and not already loading
            if (isAtBottom && !isLoadingMore && !hasReachedMax) {
              onFetchMore();
            }
            return false;
          },
          child: ListView.builder(
            itemCount: comments!.length + (hasReachedMax ? 0 : 1),
            itemBuilder: (context, index) {
              if (index >= comments.length) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: isLoadingMore
                        ? const CircularProgressIndicator()
                        : const Text('Load more...'),
                  ),
                );
              }

              return CommentCard(comment: comments[index]);
            },
          ),
        ),
      );
    }

    return const SizedBox();
  }
}