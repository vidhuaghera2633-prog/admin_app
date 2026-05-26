import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/complaint.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaints_provider.dart';
import '../../providers/technicians_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../layout/header_bar.dart';
import 'widgets/assign_reject_modal.dart';
import 'package:intl/intl.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final String id;
  const ComplaintDetailScreen({super.key, required this.id});
  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailState();
}

class _ComplaintDetailState extends State<ComplaintDetailScreen> {
  final _noteCtrl = TextEditingController();
  final _partCtrl = TextEditingController();
  final _chatCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    _partCtrl.dispose();
    _chatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complaint = context.watch<ComplaintsProvider>().getById(widget.id);
    if (complaint == null) {
      return Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, size: 48, color: AppColors.gray300),
        const SizedBox(height: 16),
        const Text('Complaint not found'),
        TextButton(onPressed: () => context.go('/app/complaints'), child: const Text('Back to list')),
      ])));
    }
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w >= 900;
    final cp = context.read<ComplaintsProvider>();

    return Column(
      children: [
        HeaderBar(title: 'Complaint Detail', subtitle: complaint.ticketNo),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back + actions
                Row(children: [
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Back'),
                    onPressed: () => context.go('/app/complaints'),
                  ),
                  const Spacer(),
                  if (complaint.status == ComplaintStatus.pending)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Accept'),
                      onPressed: () {
                        cp.accept(complaint.id);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint accepted')));
                      },
                    ),
                  if (complaint.status == ComplaintStatus.pending || complaint.status == ComplaintStatus.active) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      onPressed: () => RejectModal.show(context, complaint.id, (r) {
                        cp.reject(complaint.id, r);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint rejected')));
                      }),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add_outlined, size: 16),
                      label: const Text('Assign Technician'),
                      onPressed: () => AssignModal.show(context, complaint.id, (id) {
                        cp.assign(complaint.id, id);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Technician assigned')));
                      }),
                    ),
                  ],
                ]),
                const SizedBox(height: 16),
                // Status banner
                _StatusBanner(complaint: complaint, onPriorityChange: (p) => cp.updatePriority(complaint.id, p)),
                const SizedBox(height: 20),
                // Main content
                if (isWide)
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(flex: 2, child: _MainContent(complaint: complaint, noteCtrl: _noteCtrl, partCtrl: _partCtrl, chatCtrl: _chatCtrl)),
                    const SizedBox(width: 20),
                    SizedBox(width: 280, child: _Sidebar(complaint: complaint)),
                  ])
                else
                  Column(children: [
                    _MainContent(complaint: complaint, noteCtrl: _noteCtrl, partCtrl: _partCtrl, chatCtrl: _chatCtrl),
                    const SizedBox(height: 20),
                    _Sidebar(complaint: complaint),
                  ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}



class _StatusBanner extends StatelessWidget {
  final Complaint complaint;
  final ValueChanged<Priority> onPriorityChange;
  const _StatusBanner({required this.complaint, required this.onPriorityChange});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (complaint.status) {
      ComplaintStatus.pending => (AppColors.amber50, AppColors.amber600, 'Pending Review'),
      ComplaintStatus.active => (AppColors.blue50, AppColors.secondary, 'Active - In Progress'),
      ComplaintStatus.completed => (AppColors.green50, AppColors.green600, 'Completed'),
      ComplaintStatus.rejected => (AppColors.red50, AppColors.red600, 'Rejected'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: fg.withOpacity(0.3))),
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: fg, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: fg.withOpacity(0.4), blurRadius: 4, spreadRadius: 1)])),
        const SizedBox(width: 10),
        Text('Status: $label', style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 14)),
        const Spacer(),
        Text('Priority: ', style: TextStyle(color: fg, fontSize: 13)),
        DropdownButtonHideUnderline(
          child: DropdownButton<Priority>(
            value: complaint.priority,
            isDense: true,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray800),
            items: Priority.values.map((p) => DropdownMenuItem(
              value: p,
              child: Text(p.name[0].toUpperCase() + p.name.substring(1)),
            )).toList(),
            onChanged: (p) { if (p != null) onPriorityChange(p); },
          ),
        ),
      ]),
    );
  }
}

class _MainContent extends StatefulWidget {
  final Complaint complaint;
  final TextEditingController noteCtrl, partCtrl, chatCtrl;
  const _MainContent({required this.complaint, required this.noteCtrl, required this.partCtrl, required this.chatCtrl});

  @override
  State<_MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<_MainContent> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tab,
            isScrollable: true,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.gray500,
            tabs: [
              const Tab(text: 'Overview'),
              Tab(text: 'Customer Chat (${widget.complaint.messages.length})'),
              Tab(text: 'Activity (${widget.complaint.logs.length})'),
              Tab(text: 'Parts (${widget.complaint.parts.length})'),
              const Tab(text: 'History'),
            ],
          ),
          const Divider(height: 1, color: AppColors.gray100),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return IndexedStack(
      index: _tab.index,
      children: [
        _OverviewTab(complaint: widget.complaint, noteCtrl: widget.noteCtrl),
        _ChatTab(complaint: widget.complaint, chatCtrl: widget.chatCtrl),
        _ActivityTab(complaint: widget.complaint),
        _PartsTab(complaint: widget.complaint, partCtrl: widget.partCtrl),
        const Center(child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('No previous service history for this device.', style: TextStyle(color: AppColors.gray500)),
        )),
      ],
    );
  }
}

class _ChatTab extends StatelessWidget {
  final Complaint complaint;
  final TextEditingController chatCtrl;
  const _ChatTab({required this.complaint, required this.chatCtrl});

  @override
  Widget build(BuildContext context) {
    final cp = context.read<ComplaintsProvider>();
    final auth = context.read<AuthProvider>();
    final adminName = auth.adminData?['name'] ?? 'Admin';
    final adminId = auth.user?.uid ?? 'admin';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Communication with Customer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        if (complaint.messages.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('No messages yet. Send a note to the customer.', style: TextStyle(color: AppColors.gray400))),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: complaint.messages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final m = complaint.messages[i];
              final isMe = m.senderRole == 'admin';
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : AppColors.gray100,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                      bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.senderName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isMe ? Colors.white70 : AppColors.gray500)),
                      const SizedBox(height: 4),
                      Text(m.message, style: TextStyle(fontSize: 14, color: isMe ? Colors.white : AppColors.gray800)),
                      const SizedBox(height: 4),
                      Text(DateFormat('hh:mm a').format(m.time), style: TextStyle(fontSize: 10, color: isMe ? Colors.white60 : AppColors.gray400)),
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(
            controller: chatCtrl,
            decoration: const InputDecoration(hintText: 'Type a message to user...', isDense: true),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) {
                cp.sendMessageToCustomer(complaint.id, v.trim(), adminId, adminName, 'admin');
                chatCtrl.clear();
              }
            },
          )),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              if (chatCtrl.text.trim().isNotEmpty) {
                cp.sendMessageToCustomer(complaint.id, chatCtrl.text.trim(), adminId, adminName, 'admin');
                chatCtrl.clear();
              }
            },
            child: const Icon(Icons.send, size: 16),
          ),
        ]),
      ],
    );
  }
}



class _OverviewTab extends StatelessWidget {
  final Complaint complaint;
  final TextEditingController noteCtrl;
  const _OverviewTab({required this.complaint, required this.noteCtrl});

  @override
  Widget build(BuildContext context) {
    final cp = context.read<ComplaintsProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Issue Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(complaint.description, style: const TextStyle(color: AppColors.gray600, height: 1.6)),
        if (complaint.attachments.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Attachments (${complaint.attachments.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: complaint.attachments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) {
                final url = complaint.attachments[i];
                final isImage = url.toLowerCase().contains('.jpg') || url.toLowerCase().contains('.png') || url.toLowerCase().contains('.jpeg') || url.startsWith('http');
                
                return Column(
                  children: [
                    Container(
                      width: 100,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.gray200),
                      ),
                      child: isImage 
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(url, fit: BoxFit.cover, 
                              errorBuilder: (_, __, ___) => const Icon(Icons.insert_drive_file, color: AppColors.gray400),
                              loadingBuilder: (_, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                          )
                        : const Icon(Icons.insert_drive_file, color: AppColors.gray400, size: 32),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 100,
                      child: Text(url.split('/').last, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 20),
        const Text('Internal Notes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (complaint.notes.isEmpty)
          const Text('No notes yet.', style: TextStyle(color: AppColors.gray400, fontSize: 13)),
        ...complaint.notes.map((n) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.amber50, borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.amber100)),
          child: Text(n, style: const TextStyle(fontSize: 13, color: AppColors.gray700)),
        )),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(
            controller: noteCtrl,
            decoration: const InputDecoration(hintText: 'Add a note...', isDense: true),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) { cp.addNote(complaint.id, v.trim()); noteCtrl.clear(); }
            },
          )),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              if (noteCtrl.text.trim().isNotEmpty) { cp.addNote(complaint.id, noteCtrl.text.trim()); noteCtrl.clear(); }
            },
            child: const Icon(Icons.send, size: 16),
          ),
        ]),
      ],
    );
  }
}

class _ActivityTab extends StatelessWidget {
  final Complaint complaint;
  const _ActivityTab({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: complaint.logs.asMap().entries.map((e) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(children: [
            Container(width: 32, height: 32, decoration: const BoxDecoration(color: AppColors.indigo100, shape: BoxShape.circle),
              child: const Icon(Icons.access_time, size: 14, color: AppColors.primary)),
            if (e.key < complaint.logs.length - 1)
              Container(width: 2, height: 40, color: AppColors.gray100),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.value.action, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('${DateFormat('dd MMM yyyy, HH:mm').format(e.value.time)} · by ${e.value.by}',
                style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
            ]),
          )),
        ],
      )).toList(),
    );
  }
}

class _PartsTab extends StatelessWidget {
  final Complaint complaint;
  final TextEditingController partCtrl;
  const _PartsTab({required this.complaint, required this.partCtrl});

  @override
  Widget build(BuildContext context) {
    final cp = context.read<ComplaintsProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (complaint.parts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No parts added yet.', style: TextStyle(color: AppColors.gray400))),
          ),
        ...complaint.parts.map((p) => ListTile(
          leading: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
          title: Text(p, style: const TextStyle(fontSize: 13)),
          contentPadding: EdgeInsets.zero,
        )),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(
            controller: partCtrl,
            decoration: const InputDecoration(hintText: 'Add a part...', isDense: true),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) { cp.addPart(complaint.id, v.trim()); partCtrl.clear(); }
            },
          )),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              if (partCtrl.text.trim().isNotEmpty) { cp.addPart(complaint.id, partCtrl.text.trim()); partCtrl.clear(); }
            },
            child: const Icon(Icons.add, size: 16),
          ),
        ]),
      ],
    );
  }
}

class _Sidebar extends StatelessWidget {
  final Complaint complaint;
  const _Sidebar({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final techs = context.watch<TechniciansProvider>().technicians;
    final assignedTech = techs.where((t) => t.id == complaint.assignedTechnicianId).firstOrNull;
    final warrantyValid = DateTime.tryParse(complaint.device.warrantyExpiry)?.isAfter(DateTime.now()) ?? false;
    final cp = context.read<ComplaintsProvider>();

    return Column(
      children: [
        // Customer card
        _card('Customer Profile', [
          Center(child: TechnicianAvatar(name: complaint.customer.name, size: 56)),
          const SizedBox(height: 10),
          Center(child: Text(complaint.customer.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
          const Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
            Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
            Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
            Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
            Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
          ])),
          const SizedBox(height: 12),
          _infoRow(Icons.phone_outlined, complaint.customer.phone),
          _infoRow(Icons.email_outlined, complaint.customer.email),
          _infoRow(Icons.location_on_outlined, complaint.address),
        ]),
        const SizedBox(height: 16),
        // Device card
        _card('Device Details', [
          _kv('Type', complaint.device.type),
          _kv('Brand & Model', '${complaint.device.brand} ${complaint.device.model}'),
          _kv('Serial No.', complaint.device.serial),
          _kv('Purchase Date', complaint.device.purchaseDate),
          _kv('Warranty Expiry', complaint.device.warrantyExpiry),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: warrantyValid ? AppColors.green50 : AppColors.red50,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: warrantyValid ? AppColors.green600.withOpacity(0.3) : AppColors.red600.withOpacity(0.3)),
            ),
            child: Text(warrantyValid ? '✓ Under Warranty' : '✗ Warranty Expired',
              style: TextStyle(fontSize: 12, color: warrantyValid ? AppColors.green600 : AppColors.red600, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 16),
        // Technician card
        _card('Assigned Technician', [
          if (assignedTech != null) ...[
            Row(children: [
              TechnicianAvatar(name: assignedTech.name, size: 44, status: assignedTech.status),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(assignedTech.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Row(children: [
                  const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 3),
                  Text('${assignedTech.rating}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  Text('${assignedTech.completedJobs} jobs', style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
                ]),
              ])),
            ]),
            const SizedBox(height: 10),
            _infoRow(Icons.phone_outlined, assignedTech.phone),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: assignedTech.skills.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(border: Border.all(color: AppColors.primary.withOpacity(0.4)), borderRadius: BorderRadius.circular(50)),
              child: Text(s, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
            )).toList()),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton(
              onPressed: () => AssignModal.show(context, complaint.id, (id) => cp.assign(complaint.id, id)),
              child: const Text('Reassign Technician'),
            )),
          ] else ...[
            const Center(child: Icon(Icons.person_search, size: 48, color: AppColors.gray300)),
            const SizedBox(height: 8),
            const Center(child: Text('No technician assigned yet.', style: TextStyle(color: AppColors.gray500, fontSize: 13))),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () => AssignModal.show(context, complaint.id, (id) => cp.assign(complaint.id, id)),
              child: const Text('Assign Now'),
            )),
          ],
        ]),
        const SizedBox(height: 16),
        // Complaint info card
        _card('Complaint Info', [
          _kv('Ticket No.', complaint.ticketNo),
          _kv('District', complaint.district),
          _kv('Submitted', DateFormat('dd MMM yyyy, HH:mm').format(complaint.createdAt)),
          _kv('Last Updated', DateFormat('dd MMM yyyy, HH:mm').format(complaint.updatedAt)),
        ]),
      ],
    );
  }

  Widget _card(String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: AppTheme.cardDecoration,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      const SizedBox(height: 14),
      const Divider(height: 1, color: AppColors.gray100),
      const SizedBox(height: 14),
      ...children,
    ]),
  );

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 110, child: Text(k, style: const TextStyle(fontSize: 12, color: AppColors.gray500))),
      Expanded(child: Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
    ]),
  );

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Icon(icon, size: 14, color: AppColors.gray400),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.gray600), overflow: TextOverflow.ellipsis)),
    ]),
  );
}
