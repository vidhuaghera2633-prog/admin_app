import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HeaderBar extends StatelessWidget {
  final String title, subtitle;
  final Widget? actions;
  const HeaderBar({super.key, required this.title, required this.subtitle, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900)),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.gray500)),
              ],
            ),
          ),
          if (actions != null) ...[
            const SizedBox(width: 8),
            actions!,
          ],
        ],
      ),
    );
  }
}
