import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'sidebar.dart';

class AdaptiveScaffold extends StatelessWidget {
  final Widget child;
  const AdaptiveScaffold({super.key, required this.child});

  static const _bottomNavItems = [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
    BottomNavigationBarItem(icon: Icon(Icons.report_problem_rounded), label: 'Complaints'),
    BottomNavigationBarItem(icon: Icon(Icons.engineering_rounded), label: 'Technicians'),
    BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Map'),
    BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
  ];

  static const _routes = [
    '/app/dashboard', '/app/complaints', '/app/technicians', '/app/map', '/app/reports',
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final route = GoRouterState.of(context).matchedLocation;

    if (w >= 900) {
      // Wide: persistent sidebar
      return Material(
        color: AppColors.background,
        child: Row(
          children: [
            Sidebar(currentRoute: route),
            Expanded(child: child),
          ],
        ),
      );
    } else if (w >= 600) {
      // Medium: drawer
      return Scaffold(
        backgroundColor: AppColors.background,
        drawer: Drawer(child: Sidebar(currentRoute: route)),
        body: Builder(builder: (ctx) => Column(
          children: [
            _MobileHeader(onMenu: () => Scaffold.of(ctx).openDrawer()),
            Expanded(child: child),
          ],
        )),
      );
    } else {
      // Mobile: drawer only
      return Scaffold(
        backgroundColor: AppColors.background,
        drawer: Drawer(
          child: Sidebar(
            currentRoute: route,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
        body: Builder(builder: (ctx) => Column(
          children: [
            _MobileHeader(onMenu: () => Scaffold.of(ctx).openDrawer()),
            Expanded(child: child),
          ],
        )),
      );
    }
  }
}

class _MobileHeader extends StatefulWidget {
  final VoidCallback? onMenu;
  const _MobileHeader({this.onMenu});

  @override
  State<_MobileHeader> createState() => _MobileHeaderState();
}

class _MobileHeaderState extends State<_MobileHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 8, left: 16, right: 16,
      ),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: widget.onMenu,
          ),
          const SizedBox(width: 4),
          const Text('TechServe Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, size: 22),
            onPressed: () {
              // TODO: Implement notification drawer or dialog
            },
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 2),
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(color: AppColors.indigo100, shape: BoxShape.circle),
            child: const Center(child: Text('AA', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700))),
          ),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _MenuItem(
              icon: Icons.calendar_month_rounded,
              label: 'Scheduling',
              onTap: () {
                Navigator.pop(context);
                context.go('/app/scheduling');
              },
            ),
            _MenuItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              onTap: () {
                Navigator.pop(context);
                context.go('/app/settings');
              },
            ),
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.indigo100,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'AA',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin User',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'admin@techserve.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<AuthProvider>().logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.gray700),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}