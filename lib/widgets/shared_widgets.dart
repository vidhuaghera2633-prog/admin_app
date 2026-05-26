import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/complaint.dart';
import '../models/technician.dart';

class StatusBadge extends StatelessWidget {
  final ComplaintStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg, border) = switch (status) {
      ComplaintStatus.pending => ('Pending', AppColors.amber50, AppColors.amber600, AppColors.amber600),
      ComplaintStatus.active => ('Active', AppColors.blue50, AppColors.secondary, AppColors.secondary),
      ComplaintStatus.completed => ('Completed', AppColors.green50, AppColors.green600, AppColors.green600),
      ComplaintStatus.rejected => ('Rejected', AppColors.red50, AppColors.red600, AppColors.red600),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(status),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: border.withValues(alpha: 0.4)),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final Priority priority;
  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      Priority.low => ('Low', AppColors.gray500),
      Priority.medium => ('Medium', AppColors.warning),
      Priority.high => ('High', AppColors.orange500),
      Priority.critical => ('Critical', AppColors.danger),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class StatusDot extends StatelessWidget {
  final TechnicianStatus status;
  final double size;
  const StatusDot({super.key, required this.status, this.size = 10});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TechnicianStatus.available => AppColors.success,
      TechnicianStatus.busy => AppColors.warning,
      TechnicianStatus.offline => AppColors.gray400,
    };
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4, spreadRadius: 1)]),
    );
  }
}

class TechnicianAvatar extends StatelessWidget {
  final String name;
  final double size;
  final TechnicianStatus? status;
  const TechnicianAvatar({super.key, required this.name, this.size = 40, this.status});

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '??';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.length >= 2 
        ? trimmed.substring(0, 2).toUpperCase() 
        : trimmed.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size, height: size,
          decoration: const BoxDecoration(color: AppColors.indigo100, shape: BoxShape.circle),
          child: Center(
            child: Text(initials, style: TextStyle(
              color: AppColors.primary, fontSize: size * 0.35, fontWeight: FontWeight.w700)),
          ),
        ),
        if (status != null)
          Positioned(
            bottom: 0, right: 0,
            child: StatusDot(status: status!, size: size * 0.28),
          ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  const SectionHeader({super.key, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gray900)),
              if (subtitle != null)
                Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppColors.gray500)),
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class CustomToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const CustomToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 44, height: 24,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.gray200,
          borderRadius: BorderRadius.circular(50),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18, height: 18,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x26000000), blurRadius: 4, offset: Offset(0, 1))]),
          ),
        ),
      ),
    );
  }
}

class AppLoadingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;
  const AppLoadingButton({super.key, required this.label, this.onPressed, this.isLoading = false, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
      ),
    );
  }
}

class KPIStatCard extends StatelessWidget {
  final String label, value, badge;
  final IconData icon;
  final Color iconColor, iconBg;
  const KPIStatCard({super.key, required this.label, required this.value, required this.badge, required this.icon, required this.iconColor, required this.iconBg});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 170;
        return Container(
          padding: EdgeInsets.all(isCompact ? 14 : 20),
          decoration: AppTheme.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: isCompact ? 40 : 44,
                    height: isCompact ? 40 : 44,
                    decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: iconColor, size: isCompact ? 20 : 22),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(50)),
                          child: Text(badge, style: const TextStyle(fontSize: 11, color: AppColors.green600, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isCompact ? 12 : 16),
              Text(value, style: TextStyle(fontSize: isCompact ? 24 : 28, fontWeight: FontWeight.w800, color: AppColors.gray900)),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppColors.gray500),
              ),
            ],
          ),
        );
      },
    );
  }
}
// Orange color alias used in reports
