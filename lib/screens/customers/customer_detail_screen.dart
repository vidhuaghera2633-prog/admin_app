import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/complaint.dart';
import '../../providers/users_provider.dart';
import '../../providers/complaints_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../layout/header_bar.dart';

class CustomerDetailScreen extends StatelessWidget {
  final String userId;
  const CustomerDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UsersProvider>().getById(userId);
    final allComplaints = context.watch<ComplaintsProvider>().complaints;
    final customerComplaints = allComplaints.where((c) => 
      c.userId == userId || 
      (user != null && c.customer.email == user.email && c.customer.email.isNotEmpty)
    ).toList();

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Customer not found')));
    }

    return Scaffold(
      body: Column(
        children: [
          HeaderBar(title: 'Customer Details', subtitle: user.name),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Back to Customers'),
                    onPressed: () => context.go('/app/customers'),
                  ),
                  const SizedBox(height: 20),
                  _buildProfileCard(user),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Service History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.indigo50, borderRadius: BorderRadius.circular(50)),
                        child: Text('${customerComplaints.length} Total Complaints', 
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (customerComplaints.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No complaints found for this customer')))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: customerComplaints.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) => _ComplaintHistoryItem(complaint: customerComplaints[i]),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.indigo100,
            child: Text(user.name[0].toUpperCase(), 
              style: const TextStyle(fontSize: 32, color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _infoRow(Icons.email_outlined, user.email),
                _infoRow(Icons.phone_outlined, user.phone),
                _infoRow(Icons.calendar_today_outlined, 'Joined on ${DateFormat('dd MMM yyyy').format(user.createdAt)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.gray400),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: AppColors.gray600)),
        ],
      ),
    );
  }
}

class _ComplaintHistoryItem extends StatelessWidget {
  final Complaint complaint;
  const _ComplaintHistoryItem({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/app/complaints/${complaint.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: switch (complaint.status) {
            ComplaintStatus.pending => AppColors.amber50,
            ComplaintStatus.active => AppColors.blue50,
            ComplaintStatus.completed => AppColors.green50,
            ComplaintStatus.rejected => AppColors.red50,
          },
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: switch (complaint.status) {
              ComplaintStatus.pending => AppColors.amber100,
              ComplaintStatus.active => AppColors.blue100,
              ComplaintStatus.completed => AppColors.green100,
              ComplaintStatus.rejected => AppColors.red100,
            },
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.assignment_outlined, color: AppColors.gray400),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(complaint.ticketNo.isEmpty ? 'ID: ${complaint.id.substring(0, 6)}' : complaint.ticketNo, 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(width: 8),
                      Text('• ${DateFormat('dd MMM yyyy').format(complaint.createdAt)}', 
                        style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(complaint.issue, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(complaint.device.type, style: const TextStyle(color: AppColors.gray500, fontSize: 12)),
                ],
              ),
            ),
            StatusBadge(status: complaint.status),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.gray300),
          ],
        ),
      ),
    );
  }
}
