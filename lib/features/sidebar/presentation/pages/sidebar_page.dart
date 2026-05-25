import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaaubesi_vendor/configure/theme/theme.dart';
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: Column(
          children: [
            _ProfileHeader(
              onTap: () => context.router.push(const VendorInfoRoute()),
            ),
            Expanded(
              child: BlocBuilder<SidebarBloc, SidebarState>(
                builder: (context, state) {
                  if (state is SidebarLoadingState) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                        strokeWidth: 2.5,
                      ),
                    );
                  } else if (state is SidebarLoadedState) {
                    final items = state.items
                        .where((item) => item.hasAccess)
                        .where(
                          (item) => ![
                            'Orders',
                            'Tickets',
                            'Messages',
                          ].contains(item.name),
                        )
                        .toList();

                    if (items.isEmpty) {
                      return _EmptyState(theme: theme);
                    }

                    return ListView(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _DrawerSection(
                          title: 'Menu',
                          colorScheme: colorScheme,
                          children: items.map((item) {
                            final config = SidebarConfig.getConfigByName(
                              item.name,
                              context,
                            );
                            final hasSubItems =
                                item.subItems != null &&
                                item.subItems!.isNotEmpty;
                            final isExpanded =
                                _expandedItems[item.name] ?? false;

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
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeInOutCubic,
                                    alignment: Alignment.topCenter,
                                    child: AnimatedOpacity(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      opacity: isExpanded ? 1 : 0,
                                      child: isExpanded
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                                bottom: 4,
                                              ),
                                              child: Column(
                                                children: _buildSubItems(
                                                  item.subItems!,
                                                  colorScheme,
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
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
                      ],
                    );
                  } else if (state is SidebarErrorState) {
                    return _ErrorState(theme: theme);
                  } else {
                    return Center(
                      child: Text('No data', style: theme.textTheme.bodyMedium),
                    );
                  }
                },
              ),
            ),
            _FooterBar(onLogout: () => _showLogoutDialog(context)),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.error.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.error.withValues(alpha: 0.15),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: colorScheme.error,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Log out of your account?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You will need to sign in again to access your vendor dashboard.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        backgroundColor: colorScheme.onSurface.withValues(
                          alpha: 0.06,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<SidebarBloc>().add(
                          ClearSidebarCacheEvent(),
                        );
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: colorScheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSubItems(
    List<SideBarEntity> subItems,
    ColorScheme colorScheme,
  ) {
    final visibleItems = subItems.where((item) => item.hasAccess).toList();

    return List.generate(visibleItems.length, (index) {
      final subItem = visibleItems[index];
      final config = SidebarConfig.getConfigByName(subItem.name, context);
      final isLast = index == visibleItems.length - 1;

      return _SubNavTile(
        icon: config.icon,
        title: subItem.name,
        colorScheme: colorScheme,
        onTap: config.onTap,
        isLast: isLast,
      );
    });
  }
}

// ─────────────────────────────────────────────
//  PROFILE HEADER
// ─────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final VoidCallback onTap;

  const _ProfileHeader({required this.onTap});

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'V';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String vendorName = 'Vendor';
        String role = 'Vendor Dashboard';

        if (state is AuthAuthenticated) {
          vendorName = state.user.fullName;
          if (state.user.role.isNotEmpty) {
            role = state.user.role;
          }
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                Color.lerp(colorScheme.primary, Colors.black, 0.25) ??
                    colorScheme.primary,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative glow circles
              Positioned(
                top: -40,
                right: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.rojo.withValues(alpha: 0.12),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: onTap,
                          borderRadius: BorderRadius.circular(16),
                          splashColor: Colors.white.withValues(alpha: 0.1),
                          highlightColor: Colors.white.withValues(alpha: 0.05),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white,
                                            Colors.white.withValues(
                                              alpha: 0.85,
                                            ),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.15,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _initials(vendorName),
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            color: AppTheme.successGreen,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome back,',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        vendorName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          role,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  size: 22,
                                ),
                              ],
                            ),
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
    );
  }
}

// ─────────────────────────────────────────────
//  FOOTER BAR (logout + version)
// ─────────────────────────────────────────────
class _FooterBar extends StatelessWidget {
  final VoidCallback onLogout;

  const _FooterBar({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(12),
              splashColor: colorScheme.error.withValues(alpha: 0.1),
              highlightColor: colorScheme.error.withValues(alpha: 0.05),
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: colorScheme.error,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: colorScheme.error.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/gaaubesi.svg', width: 14, height: 14),
              const SizedBox(width: 6),
              Text(
                'Gaaubesi Vendor  •  v1.0.8',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SECTION LABEL
// ─────────────────────────────────────────────
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 12,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
        ...children,
        const SizedBox(height: 4),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  NAV TILE
// ─────────────────────────────────────────────
class _NavTile extends StatefulWidget {
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
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    final active = widget.isExpanded;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(12),
          splashColor: cs.primary.withValues(alpha: 0.1),
          highlightColor: cs.primary.withValues(alpha: 0.04),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? cs.primary.withValues(alpha: 0.06)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: active || _pressed
                          ? [
                              cs.primary,
                              Color.lerp(cs.primary, Colors.black, 0.18) ??
                                  cs.primary,
                            ]
                          : [
                              cs.primary.withValues(alpha: 0.1),
                              cs.primary.withValues(alpha: 0.06),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: active ? 0.0 : 0.12),
                      width: 1,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    widget.icon,
                    color: active || _pressed ? Colors.white : cs.primary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: active ? 1 : 0.88),
                      fontSize: 14.5,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                if (widget.hasSubItems)
                  AnimatedRotation(
                    turns: active ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOutCubic,
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: cs.onSurface.withValues(
                        alpha: active ? 0.7 : 0.35,
                      ),
                      size: 22,
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

// ─────────────────────────────────────────────
//  SUB NAV TILE (with tree-guide line)
// ─────────────────────────────────────────────
class _SubNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool isLast;

  const _SubNavTile({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.colorScheme,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;

    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tree guide line
            SizedBox(
              width: 20,
              child: CustomPaint(
                painter: _BranchPainter(
                  color: cs.primary.withValues(alpha: 0.2),
                  isLast: isLast,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(10),
                    splashColor: cs.primary.withValues(alpha: 0.08),
                    highlightColor: cs.primary.withValues(alpha: 0.05),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Icon(
                              icon,
                              size: 15,
                              color: cs.primary.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.78),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchPainter extends CustomPainter {
  final Color color;
  final bool isLast;

  _BranchPainter({required this.color, required this.isLast});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final midY = size.height / 2;

    // Vertical line
    canvas.drawLine(
      Offset(0, 0),
      Offset(0, isLast ? midY : size.height),
      paint,
    );

    // Horizontal branch into the item
    final path = Path()
      ..moveTo(0, midY)
      ..quadraticBezierTo(0, midY, size.width * 0.9, midY);
    canvas.drawPath(path, paint);

    // Terminal dot
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 1.0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.9, midY), 2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _BranchPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isLast != isLast;
}

// ─────────────────────────────────────────────
//  EMPTY / ERROR STATES
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final ThemeData theme;

  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.08),
              ),
              child: Icon(
                Icons.inbox_rounded,
                color: cs.primary.withValues(alpha: 0.6),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No menu items available',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Check back later or contact support',
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final ThemeData theme;

  const _ErrorState({required this.theme});

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.error.withValues(alpha: 0.08),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: cs.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading menu',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Please try again in a moment',
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
