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
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                context.router.push(const VendorInfoRoute());
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    vendorName,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "Edit",
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Icon(
                                        Icons.edit,
                                        size: 14,
                                        color: colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
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
                  // Normal Tile - Dashboard
                  _NormalTile(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    colorScheme: colorScheme,
                    onTap: () {
                      Navigator.pop(context);
                      context.router.push(const HomeRoute());
                    },
                  ),

                  _NormalTile(
                    icon: Icons.people,
                    title: 'Customers',
                    colorScheme: colorScheme,
                    onTap: () {
                      Navigator.pop(context);
                      context.router.push(const CustomerListRoute());
                    },
                  ),

                  _NormalTile(
                    icon: Icons.security_rounded,
                    title: 'Staffs and Permissions',
                    colorScheme: colorScheme,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  _ExpandableSection(
                    icon: Icons.analytics_rounded,
                    title: 'Orders',
                    colorScheme: colorScheme,
                    children: [
                      _DrawerSubItem(
                        icon: Icons.list_alt_rounded,
                        title: 'Order List',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          context.router.push(const OrdersRoute());
                        },
                      ),
                      _DrawerSubItem(
                        icon: Icons.add_rounded,
                        title: 'Create Order',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          context.router.push(const CreateOrderRoute());
                        },
                      ),
                    ],
                  ),

                  // Expandable Section - Utilities
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
                          context.router.push(TicketRoute());
                        },
                      ),
                      _DrawerSubItem(
                        icon: Icons.mail_outline_rounded,
                        title: 'Messages',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          context.router.push(const VendorMessagesRoute());
                        },
                      ),
                      _DrawerSubItem(
                        icon: Icons.comment_outlined,
                        title: 'Comments',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          context.router.push(CommentsRoute());
                        },
                      ),
                      _DrawerSubItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notices',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          context.router.push(NoticeListRoute());
                        },
                      ),
                      _DrawerSubItem(
                        icon: Icons.calculate_outlined,
                        title: 'Calculate Delivery Charge',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          context.router.push(CalculateDeliveryChargeRoute());
                        },
                      ),
                      _DrawerSubItem(
                        icon: Icons.directions_car_rounded,
                        title: "Extra Mileage",
                        onTap: () {
                          Navigator.pop(context);
                          context.router.push(ExtraMileageRoute());
                        },
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),

                  _ExpandableSection(
                    icon: Icons.analytics_rounded,
                    title: 'Payments',
                    colorScheme: colorScheme,
                    children: [
                      _DrawerSubItem(
                        icon: Icons.bar_chart_rounded,
                        title: 'COD Transfers',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          context.router.push(const CodTransferListRoute());
                        },
                      ),
                      _DrawerSubItem(
                        icon: Icons.bar_chart_rounded,
                        title: 'Payment Requests',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          context.router.push(const PaymentRequestListRoute());
                        },
                      ),
                      _DrawerSubItem(
                        icon: Icons.monetization_on_outlined,
                        title: 'Daily Transactions',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          context.router.push(DailyTransactionRoute());
                        },
                      ),
                    ],
                  ),

                  // Expandable Section - Settings
                  _ExpandableSection(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    colorScheme: colorScheme,
                    children: [
                      _DrawerSubItem(
                        icon: Icons.lock_outline_rounded,
                        title: 'Change Password',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Change Password page coming soon',
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),

                      _DrawerSubItem(
                        icon: Icons.info_outline_rounded,
                        title: 'About App',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                        
                        },
                      ),
                    ],
                  ),

                  // _NormalTile(
                  //   icon: Icons.local_gas_station_rounded,
                  //   title: 'Service Stations',
                  //   colorScheme: colorScheme,
                  //   onTap: () {
                  //    SnackBar(content: const Text('Service Stations page coming soon'));
                  //   },
                  // ),
                  _ExpandableSection(
                    icon: Icons.contact_emergency,
                    title: "Contact",
                    colorScheme: colorScheme,
                    children: [
                      _DrawerSubItem(
                        icon: Icons.local_post_office,
                        title: "Service Stations",
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Service Stations page coming soon',
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                        colorScheme: colorScheme,
                      ),
                      _DrawerSubItem(
                        icon: Icons.home_work,
                        title: "Head Office",
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Head Office page coming soon',
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                        colorScheme: colorScheme,
                      ),
                      _DrawerSubItem(
                        icon: Icons.location_history,
                        title: "Redirect Stations",
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Redirect Stations page coming soon',
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ],
              ),
            ),

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: Text('Logout', style: TextStyle(color: colorScheme.error)),
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

  const _ExpandableSection({
    required this.icon,
    required this.title,
    required this.colorScheme,
    required this.children,
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
          child: Icon(icon, color: colorScheme.primary, size: 20),
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
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: colorScheme.onSurface.withValues(alpha: 0.5),
        collapsedIconColor: colorScheme.onSurface.withValues(alpha: 0.5),
        children: children,
      ),
    );
  }
}

class _NormalTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _NormalTile({
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
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: colorScheme.primary.withValues(alpha: 0.08),
          highlightColor: colorScheme.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 14),
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
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.primary,
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

// Sub-item for expandable sections
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

// Logout Button
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

// Bottom Navigation Bar
class AppNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
                color: theme.primaryColor,
              ),
              _NavBarItem(
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag,
                label: 'Orders',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
                color: theme.primaryColor,
              ),
              _NavBarItem(
                icon: Icons.apps_outlined,
                activeIcon: Icons.apps,
                label: 'Utilities',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
                color: theme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color color;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? color : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? color : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
