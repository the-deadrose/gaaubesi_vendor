import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/todays_comments/todays_comments_bloc.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/todays_comments/todays_comments_event.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/todays_comments/todays_comments_state.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/all_comments/all_comments_bloc.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/all_comments/all_comments_event.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/all_comments/all_comments_state.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/widget/comment_card.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/widget/empty_comments.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/widget/error_widget.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/widget/loading_indicator.dart';

@RoutePage()
@injectable
class CommentsPage extends StatefulWidget {
  final int initialTab;
  
  const CommentsPage({super.key, this.initialTab = 0});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    
    // Fetch initial data for both tabs
    context.read<TodaysCommentsBloc>().add(const FetchTodaysCommentsEvent(page: '1'));
    context.read<AllCommentsBloc>().add(const FetchAllCommentsEvent(page: '1'));
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
                context.read<TodaysCommentsBloc>().add(const RefreshTodaysCommentsEvent());
              } else {
                context.read<AllCommentsBloc>().add(const RefreshAllCommentsEvent());
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
    return BlocConsumer<TodaysCommentsBloc, TodaysCommentsState>(
      listener: (context, state) {
        if (state is TodaysCommentsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return _buildTodaysCommentsList(
          state: state,
          comments: state is TodaysCommentsLoaded ? state.response.results : null,
          hasReachedMax: state is TodaysCommentsLoaded ? state.hasReachedMax : false,
          isLoadingMore: state is TodaysCommentsLoadingMore,
          onRefresh: () => context.read<TodaysCommentsBloc>().add(const RefreshTodaysCommentsEvent()),
          onFetchMore: () => context.read<TodaysCommentsBloc>().add(const FetchMoreTodaysCommentsEvent()),
          onRetry: () => context.read<TodaysCommentsBloc>().add(const FetchTodaysCommentsEvent(page: '1')),
        );
      },
    );
  }

  Widget _buildAllCommentsTab() {
    return BlocConsumer<AllCommentsBloc, AllCommentsState>(
      listener: (context, state) {
        if (state is AllCommentsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return _buildAllCommentsList(
          state: state,
          comments: state is AllCommentsLoaded ? state.response.results : null,
          hasReachedMax: state is AllCommentsLoaded ? state.hasReachedMax : false,
          isLoadingMore: state is AllCommentsLoadingMore,
          onRefresh: () => context.read<AllCommentsBloc>().add(const RefreshAllCommentsEvent()),
          onFetchMore: () => context.read<AllCommentsBloc>().add(const FetchMoreAllCommentsEvent()),
          onRetry: () => context.read<AllCommentsBloc>().add(const FetchAllCommentsEvent(page: '1')),
        );
      },
    );
  }

  Widget _buildTodaysCommentsList({
    required TodaysCommentsState state,
    required List<CommentEntity>? comments,
    required bool hasReachedMax,
    required bool isLoadingMore,
    required VoidCallback onRefresh,
    required VoidCallback onFetchMore,
    required VoidCallback onRetry,
  }) {
    if (state is TodaysCommentsInitial || state is TodaysCommentsLoading) {
      return const LoadingIndicator();
    }

    if (state is TodaysCommentsError) {
      return ErrorMessageWidget(
        message: state.message,
        onRetry: onRetry,
      );
    }

    if (state is TodaysCommentsLoaded && (comments == null || comments.isEmpty)) {
      return const EmptyCommentsWidget();
    }

    if (state is TodaysCommentsLoaded) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                !isLoadingMore &&
                !hasReachedMax) {
              onFetchMore();
            }
            return false;
          },
          child: ListView.builder(
            itemCount: comments?.length ?? 0 + (hasReachedMax ? 0 : 1),
            itemBuilder: (context, index) {
              if (index >= (comments?.length ?? 0)) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: isLoadingMore
                        ? const CircularProgressIndicator()
                        : const Text('Load more...'),
                  ),
                );
              }

              return CommentCard(comment: comments![index]);
            },
          ),
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildAllCommentsList({
    required AllCommentsState state,
    required List<CommentEntity>? comments,
    required bool hasReachedMax,
    required bool isLoadingMore,
    required VoidCallback onRefresh,
    required VoidCallback onFetchMore,
    required VoidCallback onRetry,
  }) {
    if (state is AllCommentsInitial || state is AllCommentsLoading) {
      return const LoadingIndicator();
    }

    if (state is AllCommentsError) {
      return ErrorMessageWidget(
        message: state.message,
        onRetry: onRetry,
      );
    }

    if (state is AllCommentsLoaded && (comments == null || comments.isEmpty)) {
      return const EmptyCommentsWidget();
    }

    if (state is AllCommentsLoaded) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                !isLoadingMore &&
                !hasReachedMax) {
              onFetchMore();
            }
            return false;
          },
          child: ListView.builder(
            itemCount: comments?.length ?? 0 + (hasReachedMax ? 0 : 1),
            itemBuilder: (context, index) {
              if (index >= (comments?.length ?? 0)) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: isLoadingMore
                        ? const CircularProgressIndicator()
                        : const Text('Load more...'),
                  ),
                );
              }

              return CommentCard(comment: comments![index]);
            },
          ),
        ),
      );
    }

    return const SizedBox();
  }
}