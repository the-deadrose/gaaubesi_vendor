import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/sidebar/presentation/bloc/sidebar_bloc.dart';
import 'package:gaaubesi_vendor/features/sidebar/presentation/bloc/sidebar_event.dart';
import 'package:gaaubesi_vendor/features/sidebar/presentation/bloc/sidebar_state.dart';
import 'package:gaaubesi_vendor/features/sidebar/presentation/config/sidebar_config.dart';
import 'package:gaaubesi_vendor/features/sidebar/domain/entity/sidebar_entity.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_event.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_state.dart';

class SidebarDrawer extends StatefulWidget {
  const SidebarDrawer({Key? key}) : super(key: key);

  @override
  State<SidebarDrawer> createState() => _SidebarDrawerState();
}

class _SidebarDrawerState extends State<SidebarDrawer> {
  final Map<String, bool> _expandedItems = {};

  @override
  void initState() {
    super.initState();
    // Load cached data first for instant UI
    context.read<SidebarBloc>().add(LoadCachedSidebarDataEvent());
    // Then fetch fresh data from server
    context.read<SidebarBloc>().add(FetchSidebarDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          children: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String vendorName = 'Vendor';

                if (state is AuthAuthenticated) {
                  vendorName = state.user.fullName;
                }

                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.surface.withValues(alpha: 0.9),
                              colorScheme.surface.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/gaaubesi.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                         context.router.push(const VendorInfoRoute());
                        },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vendorName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Vendor Dashboard',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<SidebarBloc, SidebarState>(
                builder: (context, state) {
                  if (state is SidebarLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SidebarLoadedState) {
                    final items = state.items
                        .where((item) => item.hasAccess)
                        .toList();

                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          'No menu items available',
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: [
                        _DrawerSection(
                          title: 'Menu',
                          colorScheme: colorScheme,
                          children: items.map((item) {
                            final config = SidebarConfig.getConfigByName(
                              item.name,
                              context,
                            );
                            
                            final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;
                            final isExpanded = _expandedItems[item.name] ?? false;
                            
                            if (hasSubItems) {
                              return Column(
                                children: [
                                  _NavTile(
                                    icon: config.icon,
                                    title: config.name,
                                    colorScheme: colorScheme,
                                    onTap: () {
                                      setState(() {
                                        _expandedItems[item.name] = !isExpanded;
                                      });
                                    },
                                    hasSubItems: true,
                                    isExpanded: isExpanded,
                                  ),
                                  if (isExpanded)
                                    ..._buildSubItems(
                                      item.subItems!,
                                      colorScheme,
                                    ),
                                ],
                              );
                            } else {
                              return _NavTile(
                                icon: config.icon,
                                title: config.name,
                                colorScheme: colorScheme,
                                onTap: config.onTap,
                                hasSubItems: false,
                              );
                            }
                          }).toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: colorScheme.outline.withValues(
                                        alpha: 0.1,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _LogoutButton(
                                colorScheme: colorScheme,
                                onTap: () {
                                  _showLogoutDialog(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else if (state is SidebarErrorState) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: colorScheme.error,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading menu',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: Text('No data', style: theme.textTheme.bodyMedium),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurface.withValues(alpha: 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SidebarBloc>().add(ClearSidebarCacheEvent());
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: TextButton.styleFrom(
              backgroundColor: colorScheme.error.withValues(alpha: 0.1),
              foregroundColor: colorScheme.error,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSubItems(
    List<SideBarEntity> subItems,
    ColorScheme colorScheme,
  ) {
    return subItems
        .where((item) => item.hasAccess)
        .map((subItem) {
          final config = SidebarConfig.getConfigByName(
            subItem.name,
            context,
          );
          
          return Padding(
            padding: const EdgeInsets.only(left: 32, right: 16, top: 2, bottom: 2),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: config.onTap,
                borderRadius: BorderRadius.circular(8),
                splashColor: colorScheme.primary.withValues(alpha: 0.08),
                highlightColor: colorScheme.primary.withValues(alpha: 0.05),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        config.icon,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          subItem.name,
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        })
        .toList();
  }
}

class _DrawerSection extends StatelessWidget {
  final String title;
  final ColorScheme colorScheme;
  final List<Widget> children;

  const _DrawerSection({
    required this.title,
    required this.colorScheme,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 4),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool hasSubItems;
  final bool isExpanded;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.colorScheme,
    this.hasSubItems = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: colorScheme.primary.withValues(alpha: 0.05),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (hasSubItems)
                  Icon(
                    isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                    size: 20,
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _LogoutButton({required this.colorScheme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: colorScheme.error.withValues(alpha: 0.1),
        highlightColor: colorScheme.error.withValues(alpha: 0.05),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: colorScheme.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
