import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/notification_center.dart';

class _NavItem {
  final String label, route;
  final IconData icon;
  const _NavItem(this.label, this.route, this.icon);
}

const _navItems = [
  _NavItem('Dashboard', '/app/dashboard', Icons.dashboard_rounded),
  _NavItem('Complaints', '/app/complaints', Icons.report_problem_rounded),
  _NavItem('Technicians', '/app/technicians', Icons.engineering_rounded),
  _NavItem('Customers', '/app/customers', Icons.people_rounded),
  _NavItem('Scheduling', '/app/scheduling', Icons.calendar_month_rounded),
  _NavItem('Live Map', '/app/map', Icons.map_rounded),
  _NavItem('Reports', '/app/reports', Icons.bar_chart_rounded),
  _NavItem('Settings', '/app/settings', Icons.settings_rounded),
];

class Sidebar extends StatelessWidget {
  final String currentRoute;
  final VoidCallback? onClose;
  const Sidebar({super.key, required this.currentRoute, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.gray100)),
      ),
      child: Column(
        children: [
          // Logo header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.build_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TechServe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.gray900)),
                      Text('Admin Portal', style: TextStyle(fontSize: 11, color: AppColors.gray500)),
                    ],
                  ),
                ),
                const NotificationBell(),
                if (onClose != null) ...[
                  const SizedBox(width: 4),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: onClose, padding: EdgeInsets.zero),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.gray100),
          const SizedBox(height: 8),
          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              itemBuilder: (ctx, i) {
                final item = _navItems[i];
                final isActive = currentRoute.startsWith(item.route);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.indigo50 : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        context.go(item.route);
                        onClose?.call();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Icon(item.icon, size: 20,
                              color: isActive ? AppColors.primary : AppColors.gray500),
                            const SizedBox(width: 12),
                            Text(item.label, style: TextStyle(
                              fontSize: 14, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive ? AppColors.primary : AppColors.gray600,
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.gray100),
          // User section only
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final email = auth.user?.email ?? 'Admin User';
                final name = auth.adminData?['name'] ?? 'Admin User';
                final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: const BoxDecoration(color: AppColors.indigo100, shape: BoxShape.circle),
                      child: Center(child: Text(initial, style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w700))),
                    ),
                    const SizedBox(height: 6),
                    Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray800), textAlign: TextAlign.center),
                    Text(email, style: const TextStyle(fontSize: 10, color: AppColors.gray500), textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.gray400),
                      onPressed: () => auth.logout(),
                      tooltip: 'Logout',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}