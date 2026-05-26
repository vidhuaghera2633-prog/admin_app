import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/complaints_provider.dart';
import '../models/complaint.dart';
import '../theme/app_theme.dart';

class NotificationBell extends StatelessWidget {
  final Color iconColor;
  const NotificationBell({super.key, this.iconColor = AppColors.gray500});

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplaintsProvider>(
      builder: (context, complaintsProvider, _) {
        final unreadCount = complaintsProvider.unreadCount;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                unreadCount > 0
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                size: 22,
                color: unreadCount > 0 ? AppColors.warning : iconColor,
              ),
              onPressed: () {
                _showNotificationCenter(context);
              },
              tooltip: 'Notifications Center',
            ),
            if (unreadCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showNotificationCenter(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => const _NotificationCenterDialog(),
    );
  }
}

class _NotificationCenterDialog extends StatelessWidget {
  const _NotificationCenterDialog();

  @override
  Widget build(BuildContext context) {
    final isLightOuter = Theme.of(context).brightness == Brightness.light;
    final bgColorOuter = isLightOuter ? Colors.white : Color(0xFF0F172A).withOpacity(0.95);
    final borderColorOuter = isLightOuter ? AppColors.gray100.withOpacity(0.9) : AppColors.primary.withOpacity(0.4);
    final boxShadowOuter = isLightOuter
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ];

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 80, right: 24, left: 24),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 360,
            constraints: const BoxConstraints(maxHeight: 500),
            decoration: BoxDecoration(
              color: bgColorOuter,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: borderColorOuter,
                width: 1.5,
              ),
              boxShadow: boxShadowOuter,
            ),
              child: Consumer<ComplaintsProvider>(
              builder: (context, complaintsProvider, _) {
                final unreadIds = complaintsProvider.unreadComplaintIds;
                final allComplaints = complaintsProvider.complaints;

                // Show the most recently created complaints first.
                final combined = allComplaints.toList()
                  ..sort((a, b) {
                    final created = b.createdAt.compareTo(a.createdAt);
                    if (created != 0) return created;
                    return b.createdAt.compareTo(a.createdAt);
                  });

                final visibleNotifications = combined.take(10).toList();

                final isLight = isLightOuter;
                final titleColor = isLight ? AppColors.gray900 : Colors.white;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Notifications',
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (visibleNotifications.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                complaintsProvider.markAllAsRead();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Mark all as read',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Divider(color: isLight ? AppColors.gray100 : Colors.white12, height: 1),
                    // Notification List
                    Flexible(
                      child: visibleNotifications.isEmpty
                          ? _EmptyNotificationsPlaceholder(isLight: isLight)
                          : ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: visibleNotifications.length,
                                separatorBuilder: (_, __) =>
                                  Divider(color: isLight ? AppColors.gray100 : Colors.white10, height: 1),
                              itemBuilder: (context, index) {
                                final complaint = visibleNotifications[index];
                                final isUnread = unreadIds.contains(complaint.id);
                                return _NotificationItem(
                                  complaint: complaint,
                                  onTap: () {
                                    if (isUnread) complaintsProvider.markAsRead(complaint.id);
                                    Navigator.pop(context);
                                    GoRouter.of(context)
                                        .go('/app/complaints/${complaint.id}');
                                  },
                                );
                              },
                            ),
                    ),
                    Divider(color: isLight ? AppColors.gray100 : Colors.white12, height: 1),
                    // Footer
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          GoRouter.of(context).go('/app/complaints');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: isLight ? AppColors.gray700 : Colors.white70,
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('View All Complaints'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onTap;

  const _NotificationItem({required this.complaint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(complaint.createdAt);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final titleColor = isLight ? AppColors.gray900 : Colors.white;
    final timeColor = isLight ? AppColors.gray600 : Colors.white.withOpacity(0.4);
    final subtitleColor = isLight ? AppColors.gray700 : Colors.white.withOpacity(0.7);
    final lastMessage = complaint.messages.isNotEmpty ? complaint.messages.last : null;
    final hasChat = lastMessage != null;
    final chatLabel = hasChat
        ? (lastMessage.senderRole == 'admin' ? 'You' : lastMessage.senderName)
        : null;
    final chatSnippet = hasChat ? lastMessage.message : complaint.issue;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6, right: 10),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          complaint.customer.name,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: timeColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    complaint.ticketNo.isEmpty
                        ? 'Ticket: TKT-${complaint.id.substring(complaint.id.length - 6).toUpperCase()}'
                        : 'Ticket: ${complaint.ticketNo}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasChat ? '$chatLabel: $chatSnippet' : complaint.issue,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

class _EmptyNotificationsPlaceholder extends StatelessWidget {
  final bool isLight;
  const _EmptyNotificationsPlaceholder({this.isLight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLight ? AppColors.primary.withOpacity(0.08) : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'All Caught Up!',
            style: TextStyle(
              color: isLight ? AppColors.gray900 : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No new complaint alerts at the moment.',
            style: TextStyle(
              color: isLight ? AppColors.gray600 : Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
