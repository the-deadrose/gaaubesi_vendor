import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/resources/domain/entity/resources_list_entity.dart';
import 'package:gaaubesi_vendor/features/resources/presentation/bloc/resources_list_bloc.dart';
import 'package:gaaubesi_vendor/features/resources/presentation/bloc/resources_list_event.dart';
import 'package:gaaubesi_vendor/features/resources/presentation/bloc/resources_list_state.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class ResourcesListScreen extends StatefulWidget {
  const ResourcesListScreen({Key? key}) : super(key: key);

  @override
  State<ResourcesListScreen> createState() => _ResourcesListScreenState();
}

class _ResourcesListScreenState extends State<ResourcesListScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    context.read<ResourcesListBloc>().add(
      const FetchResourcesListEvent(page: '1'),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<ResourcesListBloc>().add(
        const LoadMoreResourcesEvent(page: '1'),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    String urlToLaunch = url;
    debugPrint('DEBUG: Original URL: $url');

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      urlToLaunch = 'https://$url';
      debugPrint('DEBUG: Added scheme. New URL: $urlToLaunch');
    }

    final Uri uri = Uri.parse(urlToLaunch);
    debugPrint('DEBUG: Parsed URI: $uri');

    try {
      final bool canLaunch = await canLaunchUrl(uri);
      debugPrint('DEBUG: canLaunchUrl result: $canLaunch');

      if (canLaunch) {
        debugPrint('DEBUG: Attempting to launch URL...');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('DEBUG: URL launched successfully');
      } else {
        debugPrint(
          'DEBUG: canLaunchUrl returned false, trying force launch anyway...',
        );
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          debugPrint('DEBUG: Force launch succeeded');
        } catch (e) {
          debugPrint('DEBUG: Force launch also failed: $e');
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No browser app found to open: $urlToLaunch\nError: $e',
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('DEBUG: Error launching URL: $e');
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: const Text('Resources'),
        centerTitle: true,
      ),
      body: BlocBuilder<ResourcesListBloc, ResourcesListState>(
        builder: (context, state) {
          if (state is ResourcesListLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ResourcesListErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ResourcesListBloc>().add(
                        const FetchResourcesListEvent(page: '1'),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ResourcesListLoadedState) {
            final resources = state.resourcesListEntity.results;

            if (resources.isEmpty) {
              return const Center(child: Text('No resources available'));
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: resources.length,
              itemBuilder: (context, index) {
                final resource = resources[index];
                return _ResourceItemWidget(
                  resource: resource,
                  onTap: () => _launchURL(resource.view),
                );
              },
            );
          }

          return const Center(child: Text('No resources available'));
        },
      ),
    );
  }
}

class _ResourceItemWidget extends StatelessWidget {
  final ResourceItemEntity resource;
  final VoidCallback onTap;

  const _ResourceItemWidget({
    Key? key,
    required this.resource,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    resource.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              resource.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: 8),
            Divider(color: Colors.grey.withValues(alpha: 0.3), thickness: 1),
          ],
        ),
      ),
    );
  }
}
