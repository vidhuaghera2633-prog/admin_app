import 'dart:async';
import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../theme/app_theme.dart';

class OverlayNotification {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void show({
    required BuildContext context,
    required Complaint complaint,
    required VoidCallback onView,
  }) {
    // Dismiss any active notification first
    dismiss();

    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) {
      debugPrint('No overlay found for notification, falling back to SnackBar.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔔 New Complaint: ${complaint.customer.name} - ${complaint.issue}'),
          action: SnackBarAction(
            label: 'VIEW',
            onPressed: onView,
          ),
        ),
      );
      return;
    }

    final entry = OverlayEntry(
      builder: (context) => _OverlayNotificationWidget(
        complaint: complaint,
        onView: () {
          onView();
          dismiss();
        },
        onDismiss: dismiss,
      ),
    );

    _currentEntry = entry;
    overlayState.insert(entry);

    _dismissTimer = Timer(const Duration(seconds: 8), () {
      dismiss();
    });
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (_currentEntry != null) {
      _currentEntry!.remove();
      _currentEntry = null;
    }
  }
}

class _OverlayNotificationWidget extends StatefulWidget {
  final Complaint complaint;
  final VoidCallback onView;
  final VoidCallback onDismiss;

  const _OverlayNotificationWidget({
    required this.complaint,
    required this.onView,
    required this.onDismiss,
  });

  @override
  State<_OverlayNotificationWidget> createState() => _OverlayNotificationWidgetState();
}

class _OverlayNotificationWidgetState extends State<_OverlayNotificationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 600;

    return Positioned(
      top: 24 + MediaQuery.of(context).padding.top,
      right: isMobile ? 16 : 24,
      left: isMobile ? 16 : null,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: isMobile ? double.infinity : 400,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Ultra-sleek premium dark glassmorphism
                color: const Color(0xFF0F172A).withOpacity(0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated Notification Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '🔔 New Complaint!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            // Dismiss Button
                            InkWell(
                              onTap: () {
                                _controller.reverse().then((_) => widget.onDismiss());
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white.withOpacity(0.5),
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Ticket ID
                        Text(
                          widget.complaint.ticketNo.isEmpty
                              ? 'TKT-${widget.complaint.id.substring(widget.complaint.id.length - 6).toUpperCase()}'
                              : widget.complaint.ticketNo,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Customer name and Issue
                        RichText(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: const TextStyle(fontSize: 13, height: 1.4),
                            children: [
                              TextSpan(
                                text: '${widget.complaint.customer.name}: ',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: widget.complaint.issue,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white.withOpacity(0.6),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () {
                                _controller.reverse().then((_) => widget.onDismiss());
                              },
                              child: const Text('DISMISS'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: widget.onView,
                              child: const Text('VIEW DETAILS'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
