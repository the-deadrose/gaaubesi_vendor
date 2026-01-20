import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_event.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with vendor info
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String vendorName = 'Vendor';

                if (state is AuthAuthenticated) {
                  vendorName = state.user.fullName;
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.store_rounded,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Vendor info
                      Expanded(
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
                            const SizedBox(height: 2),
                            Text(
                              'Vendor Dashboard',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Menu Section
                  _ExpandableSection(
                    icon: Icons.dashboard_rounded,
                    title: 'Menu',
                    colorScheme: colorScheme,
                    initiallyExpanded: true,
                    children: [
                     
                      _DrawerSubItem(
                        icon: Icons.support_agent_rounded,
                        title: 'Contact Support',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          context.router.push(const ContactRoute());
                        },
                      ),
                      _DrawerSubItem(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Comments',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          context.router.push(const CommentRoute());
                        },
                      ),
                    ],
                  ),

                  // Utilities Section
                  _ExpandableSection(
                    icon: Icons.build_rounded,
                    title: 'Utilities',
                    colorScheme: colorScheme,
                    children: [
                      _DrawerSubItem(
                        icon: Icons.confirmation_number_outlined,
                        title: 'Tickets',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Tickets coming soon'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                      _DrawerSubItem(
                        icon: Icons.mail_outline_rounded,
                        title: 'Messages',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Messages coming soon'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                      _DrawerSubItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notices',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Notices coming soon'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                     
                      _DrawerSubItem(
                        icon: Icons.alt_route_rounded,
                        title: 'Redirected Orders',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          context.router.push(const RedirectedOrdersRoute());
                        },
                      ),
                    
                    ],
                  ),

                  // Settings Section
                  _ExpandableSection(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    colorScheme: colorScheme,
                    children: [
                      _DrawerSubItem(
                        icon: Icons.tune_rounded,
                        title: 'Preferences',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Settings page coming soon'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                      _DrawerSubItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Help page coming soon'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Logout button at bottom
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: _LogoutButton(
                colorScheme: colorScheme,
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: Text(
              'Logout',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final ColorScheme colorScheme;
  final List<Widget> children;
  final bool initiallyExpanded;

  const _ExpandableSection({
    required this.icon,
    required this.title,
    required this.colorScheme,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: colorScheme.primary.withValues(alpha: 0.08),
        highlightColor: colorScheme.primary.withValues(alpha: 0.04),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: colorScheme.onSurface.withValues(alpha: 0.5),
        collapsedIconColor: colorScheme.onSurface.withValues(alpha: 0.5),
        children: children,
      ),
    );
  }
}

class _DrawerSubItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _DrawerSubItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: colorScheme.primary.withValues(alpha: 0.08),
          highlightColor: colorScheme.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
}

class _LogoutButton extends StatelessWidget {
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _LogoutButton({
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: colorScheme.error.withValues(alpha: 0.08),
        highlightColor: colorScheme.error.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: colorScheme.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Logout',
                style: TextStyle(
                  color: colorScheme.error,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
