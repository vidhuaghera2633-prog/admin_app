import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/technician.dart';
import '../../../providers/technicians_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/shared_widgets.dart';

class AssignModal extends StatelessWidget {
  final String complaintId;
  final void Function(String techId) onAssign;
  const AssignModal({super.key, required this.complaintId, required this.onAssign});

  static Future<void> show(BuildContext context, String complaintId, void Function(String) onAssign) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => AssignModal(complaintId: complaintId, onAssign: onAssign),
    );
  }

  @override
  Widget build(BuildContext context) {
    final techs = context.watch<TechniciansProvider>().technicians;
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxHeight: 560),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(child: Text('Assign Technician', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: techs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final t = techs[i];
                return InkWell(
                  onTap: () {
                    onAssign(t.id);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gray200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      TechnicianAvatar(name: t.name, size: 44, status: t.status),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(t.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(t.skills.take(2).join(', '), style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                          const SizedBox(height: 2),
                          Text(t.districts.take(2).join(', '), style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
                        ]),
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        _statusBadge(t.status),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 2),
                          Text('${t.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                      ]),
                    ]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(TechnicianStatus status) {
    final (label, color) = switch (status) {
      TechnicianStatus.available => ('Available', AppColors.success),
      TechnicianStatus.busy => ('Busy', AppColors.warning),
      TechnicianStatus.offline => ('Offline', AppColors.gray400),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class RejectModal extends StatefulWidget {
  final String complaintId;
  final void Function(String reason) onReject;
  const RejectModal({super.key, required this.complaintId, required this.onReject});

  static Future<void> show(BuildContext context, String complaintId, void Function(String) onReject) {
    return showDialog(
      context: context,
      builder: (_) => RejectModal(complaintId: complaintId, onReject: onReject),
    );
  }

  @override
  State<RejectModal> createState() => _RejectModalState();
}

class _RejectModalState extends State<RejectModal> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Expanded(child: Text('Reject Complaint', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 16),
            const Text('Please provide a reason for rejection:',
              style: TextStyle(color: AppColors.gray600, fontSize: 14)),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Enter rejection reason...', labelText: 'Reason'),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                onPressed: _ctrl.text.trim().isNotEmpty ? () {
                  widget.onReject(_ctrl.text.trim());
                  Navigator.pop(context);
                } : null,
                child: const Text('Confirm Reject'),
              )),
            ]),
          ],
        ),
      ),
    );
  }
}
