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
                              colorScheme.primary.withValues(alpha: 0.9),
                              colorScheme.primary.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.store_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                context.router.push(const VendorInfoRoute());
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        vendorName,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: colorScheme.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Edit",
                                            style: TextStyle(
                                              color: colorScheme.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.edit_outlined,
                                            size: 12,
                                            color: colorScheme.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                    ],
                  ),
                );
              },
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _DrawerSection(
                    title: 'Main',
                    colorScheme: colorScheme,
                    children: [
                      _NavTile(
                        icon: Icons.dashboard_rounded,
                        title: 'Dashboard',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _NavTile(
                        icon: Icons.people_outline_rounded,
                        title: 'Customers',
                        colorScheme: colorScheme,
                        onTap: () {
                          context.router.push(const CustomerListRoute());
                        },
                      ),
                    ],
                  ),

                  _DrawerSection(
                    title: 'Orders',
                    colorScheme: colorScheme,
                    children: [
                      _NavTile(
                        icon: Icons.list_alt_rounded,
                        title: 'Order List',
                        colorScheme: colorScheme,
                        onTap: () {
                          context.router.push(const OrdersRoute());
                        },
                      ),
                      _NavTile(
                        icon: Icons.add_circle_outline_rounded,
                        title: 'Create Order',
                        colorScheme: colorScheme,
                        onTap: () {
                          context.router.push(const CreateOrderRoute());
                        },
                      ),
                    ],
                  ),

                  _DrawerSection(
                    title: 'Management',
                    colorScheme: colorScheme,
                    children: [
                      _NavTile(
                        icon: Icons.security_rounded,
                        title: 'Staff & Permissions',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),

                  _DrawerSection(
                    title: 'Analytics',
                    colorScheme: colorScheme,
                    children: [
                      _NavTile(
                        icon: Icons.bar_chart_rounded,
                        title: 'Delivery Report',
                        colorScheme: colorScheme,
                        onTap: () {
                          context.router.push(
                            const DeliveryReportAnalysisRoute(),
                          );
                        },
                      ),
                      _NavTile(
                        icon: Icons.show_chart_rounded,
                        title: 'Sales Report',
                        colorScheme: colorScheme,
                        onTap: () {
                          context.router.push(const SalesReportAnalysisRoute());
                        },
                      ),

                      _NavTile(
                        icon: Icons.store_mall_directory_rounded,
                        title: 'Branch Report',
                        colorScheme: colorScheme,
                        onTap: () {
                          context.router.push(BranchReportAnalysisRoute());
                        },
                      ),

                      _NavTile(
                        icon: Icons.local_shipping_rounded,
                        title: 'Pickup Order Analysis',
                        colorScheme: colorScheme,
                        onTap: () {
                          context.router.push(PickupOrderAnalysisRoute());
                        },
                      ),
                    ],
                  ),

                  _DrawerSection(
                    title: 'Utilities',
                    colorScheme: colorScheme,
                    children: [
                      _NavTile(
                        icon: Icons.confirmation_number_outlined,
                        title: 'Tickets',
                        colorScheme: colorScheme,
                        onTap: () {
                          context.router.push(TicketRoute());
                        },
                      ),
                      _NavTile(
                        icon: Icons.mail_outline_rounded,
                        title: 'Messages',
                        colorScheme: colorScheme,
                        onTap: () {
                          context.router.push(const VendorMessagesRoute());
                        },
                      ),
                      _NavTile(
                        icon: Icons.comment_outlined,
                        title: 'Comments',
                        colorScheme: colorScheme,
                        onTap: () {
                          context.router.push(CommentsRoute());
                        },
                      ),
                      _NavTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notices',
                        colorScheme: colorScheme,
                        onTap: () {
                          context.router.push(NoticeListRoute());
                        },
                      ),
                      _NavTile(
                        icon: Icons.calculate_outlined,
                        title: 'Delivery Calculator',
                        colorScheme: colorScheme,
                        onTap: () {
                          context.router.push(CalculateDeliveryChargeRoute());
                        },
                      ),
                      _NavTile(
                        icon: Icons.directions_car_rounded,
                        title: "Extra Mileage",
                        onTap: () {
                          context.router.push(ExtraMileageRoute());
                        },
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),

                  _DrawerSection(
                    title: 'Payments',
                    colorScheme: colorScheme,
                    children: [
                      _NavTile(
                        icon: Icons.attach_money_rounded,
                        title: 'COD Transfers',
                        colorScheme: colorScheme,
                        onTap: () {
                          context.router.push(const CodTransferListRoute());
                        },
                      ),
                      _NavTile(
                        icon: Icons.request_page_outlined,
                        title: 'Payment Requests',
                        colorScheme: colorScheme,
                        onTap: () {
                          context.router.push(const PaymentRequestListRoute());
                        },
                      ),
                      _NavTile(
                        icon: Icons.monetization_on_outlined,
                        title: 'Daily Transactions',
                        colorScheme: colorScheme,
                        onTap: () {
                          context.router.push(DailyTransactionRoute());
                        },
                      ),
                    ],
                  ),

                  _DrawerSection(
                    title: 'Settings',
                    colorScheme: colorScheme,
                    children: [
                      _NavTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Change Password',
                        colorScheme: colorScheme,
                        onTap: () {
                          context.router.push(const ChangePasswordRoute());
                        },
                      ),
                      _NavTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Profile',
                        colorScheme: colorScheme,
                        onTap: () {
                          context.router.push(const EditProfileRoute());
                        },
                      ),
                    ],
                  ),

                  _DrawerSection(
                    title: 'Contact',
                    colorScheme: colorScheme,
                    children: [
                      _NavTile(
                        icon: Icons.local_post_office,
                        title: "Service Stations",
                        onTap: () {
                          context.router.push(const ServiceStationRoute());
                        },
                        colorScheme: colorScheme,
                      ),
                      _NavTile(
                        icon: Icons.home_work,
                        title: "Head Office",
                        onTap: () {
                          context.router.push(const HeadOfficeContactsRoute());
                        },
                        colorScheme: colorScheme,
                      ),
                      _NavTile(
                        icon: Icons.location_on_outlined,
                        title: "Redirect Stations",
                        onTap: () {
                          context.router.push(const RedirectStationListRoute());
                        },
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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

  const _NavTile({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.colorScheme,
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
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
                color: colorScheme.primary,
              ),
              _NavBarItem(
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag_rounded,
                label: 'Orders',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
                color: colorScheme.primary,
              ),
              _NavBarItem(
                icon: Icons.apps_outlined,
                activeIcon: Icons.apps_rounded,
                label: 'Utilities',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
                color: colorScheme.primary,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: color.withValues(alpha: 0.1),
          highlightColor: color.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? color.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    color: isActive ? color : Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? color : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
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
