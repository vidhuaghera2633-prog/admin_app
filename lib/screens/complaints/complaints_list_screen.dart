import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/complaint.dart';
import '../../providers/complaints_provider.dart';
import '../../providers/technicians_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../layout/header_bar.dart';
import 'widgets/assign_reject_modal.dart';
import 'package:intl/intl.dart';

class ComplaintsListScreen extends StatefulWidget {
  const ComplaintsListScreen({super.key});
  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
    List<Complaint> _filter(List<Complaint> all) {
      var list = all.where((c) {
        if (_search.isNotEmpty) {
          final q = _search.toLowerCase();
          if (!c.ticketNo.toLowerCase().contains(q) &&
              !c.customer.name.toLowerCase().contains(q) &&
              !c.issue.toLowerCase().contains(q) &&
              !c.district.toLowerCase().contains(q)) return false;
        }
        if (_statusFilter != null && c.status != _statusFilter) return false;
        if (_priorityFilter != null && c.priority != _priorityFilter) return false;
        if (_districtFilter != null && c.district != _districtFilter) return false;
        return true;
      }).toList();
      if (_sortCol == 'date') {
        list.sort((a, b) => _sortAsc ? a.createdAt.compareTo(b.createdAt) : b.createdAt.compareTo(a.createdAt));
      } else {
        list.sort((a, b) {
          int statusVal(ComplaintStatus s) {
            switch (s) {
              case ComplaintStatus.pending: return 1;
              case ComplaintStatus.active: return 2;
              case ComplaintStatus.rejected: return 3;
              case ComplaintStatus.completed: return 4;
            }
          }
          final comp = statusVal(a.status).compareTo(statusVal(b.status));
          if (comp != 0) return comp;
          return b.createdAt.compareTo(a.createdAt);
        });
      }
      return list;
    }
  String _search = '';
  ComplaintStatus? _statusFilter;
  Priority? _priorityFilter;
  String? _districtFilter;
  String? _sortCol;
  bool _sortAsc = true;

  @override
  Widget build(BuildContext context) {
    final all = context.watch<ComplaintsProvider>().complaints;
    final filtered = _filter(all);
    return Scaffold(
      body: Column(
        children: [
          const HeaderBar(title: 'Complaints', subtitle: 'Manage all service complaints'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Filters(
                    search: _search,
                    statusFilter: _statusFilter,
                    priorityFilter: _priorityFilter,
                    districtFilter: _districtFilter,
                    districts: all.map((c) => c.district).toSet().toList(),
                    onSearch: (v) => setState(() => _search = v),
                    onStatus: (v) => setState(() => _statusFilter = v),
                    onPriority: (v) => setState(() => _priorityFilter = v),
                    onDistrict: (v) => setState(() => _districtFilter = v),
                  ),
                  const SizedBox(height: 16),
                  _StatusChips(all: all, current: _statusFilter, onTap: (s) => setState(() => _statusFilter = s)),
                  const SizedBox(height: 16),
                  _ComplaintsTable(complaints: filtered, sortCol: _sortCol, sortAsc: _sortAsc,
                    onSort: (col) => setState(() {
                      if (_sortCol == col) { _sortAsc = !_sortAsc; } else { _sortCol = col; _sortAsc = true; }
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => _NewComplaintDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Complaint'),
      ),
    );
  }
}

class _NewComplaintDialog extends StatefulWidget {
  @override
  State<_NewComplaintDialog> createState() => _NewComplaintDialogState();
}

class _NewComplaintDialogState extends State<_NewComplaintDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _deviceCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _issueCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  Priority _priority = Priority.medium;

  @override
  void dispose() {
    _customerCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _deviceCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _issueCtrl.dispose();
    _districtCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Complaint'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customer Details', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _customerCtrl, decoration: const InputDecoration(labelText: 'Name', isDense: true), validator: (v) => v?.isEmpty ?? true ? 'Required' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', isDense: true), validator: (v) => v?.isEmpty ?? true ? 'Required' : null)),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email (Optional)', isDense: true)),
                
                const SizedBox(height: 20),
                const Text('Device & Location', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _brandCtrl, decoration: const InputDecoration(labelText: 'Brand', isDense: true))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _deviceCtrl, decoration: const InputDecoration(labelText: 'Device Type', hintText: 'AC, Fridge', isDense: true), validator: (v) => v?.isEmpty ?? true ? 'Required' : null)),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _modelCtrl, decoration: const InputDecoration(labelText: 'Model/Serial (Optional)', isDense: true)),
                const SizedBox(height: 12),
                TextFormField(controller: _districtCtrl, decoration: const InputDecoration(labelText: 'District', isDense: true), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Full Address', isDense: true), maxLines: 2),

                const SizedBox(height: 20),
                const Text('Complaint Info', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                DropdownButtonFormField<Priority>(
                  value: _priority,
                  decoration: const InputDecoration(labelText: 'Priority', isDense: true),
                  items: Priority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name[0].toUpperCase() + p.name.substring(1)))).toList(),
                  onChanged: (p) => setState(() => _priority = p ?? Priority.medium),
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _issueCtrl, decoration: const InputDecoration(labelText: 'Issue Summary', isDense: true), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Detailed Description', isDense: true), maxLines: 3),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              final provider = context.read<ComplaintsProvider>();
              final id = 'c${DateTime.now().millisecondsSinceEpoch}';
              
              final newComplaint = Complaint(
                id: id,
                ticketNo: 'TKT-${DateFormat('yyyyMMdd').format(DateTime.now())}-${id.substring(id.length - 4)}',
                customer: Customer(
                  name: _customerCtrl.text.trim(), 
                  phone: _phoneCtrl.text.trim(), 
                  email: _emailCtrl.text.trim(),
                ),
                device: Device(
                  type: _deviceCtrl.text.trim(), 
                  brand: _brandCtrl.text.trim(), 
                  model: _modelCtrl.text.trim(), 
                  serial: '', 
                  purchaseDate: '', 
                  warrantyExpiry: ''
                ),
                issue: _issueCtrl.text.trim(),
                description: _descCtrl.text.trim(),
                status: ComplaintStatus.pending,
                priority: _priority,
                district: _districtCtrl.text.trim(),
                address: _addressCtrl.text.trim(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              
              await provider.addComplaint(newComplaint);
              if (mounted) Navigator.of(context).pop();
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}


class _Filters extends StatelessWidget {
  final String search;
  final ComplaintStatus? statusFilter;
  final Priority? priorityFilter;
  final String? districtFilter;
  final List<String> districts;
  final ValueChanged<String> onSearch;
  final ValueChanged<ComplaintStatus?> onStatus;
  final ValueChanged<Priority?> onPriority;
  final ValueChanged<String?> onDistrict;

  const _Filters({required this.search, required this.statusFilter, required this.priorityFilter,
    required this.districtFilter, required this.districts, required this.onSearch,
    required this.onStatus, required this.onPriority, required this.onDistrict});

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 1100;
    return Material(
      color: Colors.transparent,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: isCompact ? 240 : 300,
                child: TextField(
                  onChanged: onSearch,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search, size: 20), hintText: 'Search complaints...', isDense: true),
                ),
              ),
              _dropdown<ComplaintStatus?>('Status', statusFilter,
                [null, ComplaintStatus.pending, ComplaintStatus.active, ComplaintStatus.completed, ComplaintStatus.rejected],
                (v) => v == null ? 'All' : v.name[0].toUpperCase() + v.name.substring(1),
                onStatus),
              _dropdown<Priority?>('Priority', priorityFilter,
                [null, Priority.critical, Priority.high, Priority.medium, Priority.low],
                (v) => v == null ? 'All' : v.name[0].toUpperCase() + v.name.substring(1),
                onPriority),
              _dropdown<String?>('District', districtFilter,
                [null, ...districts],
                (v) => v ?? 'All',
                onDistrict),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.download_outlined, size: 16),
                  label: const Text('Export'),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exporting complaints as CSV...'))),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _dropdown<T>(String hint, T value, List<T> items, String Function(T) label, ValueChanged<T> onChange) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray200),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 13)),
          isDense: true,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(label(i), style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (v) => onChange(v as T),
        ),
      ),
    );
  }
}

class _StatusChips extends StatelessWidget {
  final List<Complaint> all;
  final ComplaintStatus? current;
  final ValueChanged<ComplaintStatus?> onTap;
  const _StatusChips({required this.all, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final counts = {
      null: all.length,
      ComplaintStatus.pending: all.where((c) => c.status == ComplaintStatus.pending).length,
      ComplaintStatus.active: all.where((c) => c.status == ComplaintStatus.active).length,
      ComplaintStatus.completed: all.where((c) => c.status == ComplaintStatus.completed).length,
      ComplaintStatus.rejected: all.where((c) => c.status == ComplaintStatus.rejected).length,
    };
    final items = [
      (null, 'All', AppColors.primary),
      (ComplaintStatus.pending, 'Pending', AppColors.warning),
      (ComplaintStatus.active, 'Active', AppColors.secondary),
      (ComplaintStatus.completed, 'Completed', AppColors.success),
      (ComplaintStatus.rejected, 'Rejected', AppColors.danger),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final isActive = current == item.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onTap(item.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: isActive ? AppColors.primary : item.$3.withOpacity(0.4)),
                ),
                child: Text('${item.$2} (${counts[item.$1]})',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : item.$3)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ComplaintsTable extends StatelessWidget {
  final List<Complaint> complaints;
  final String? sortCol;
  final bool sortAsc;
  final ValueChanged<String> onSort;

  const _ComplaintsTable({required this.complaints, required this.sortCol, required this.sortAsc, required this.onSort});

  @override
  Widget build(BuildContext context) {
    if (complaints.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(60),
        decoration: AppTheme.cardDecoration,
        child: const Center(
          child: Column(children: [
            Icon(Icons.search_off, size: 48, color: AppColors.gray300),
            SizedBox(height: 16),
            Text('No complaints found', style: TextStyle(fontSize: 16, color: AppColors.gray500)),
            Text('Try adjusting your filters', style: TextStyle(fontSize: 13, color: AppColors.gray400)),
          ]),
        ),
      );
    }

    return Container(
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.gray50),
          horizontalMargin: 20, columnSpacing: 20,
          columns: [
            const DataColumn(label: Text('Ticket', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
            const DataColumn(label: Text('Customer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
            const DataColumn(label: Text('Device & Issue', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
            const DataColumn(label: Text('District', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
            const DataColumn(label: Text('Priority', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
            const DataColumn(label: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
            const DataColumn(label: Text('Assigned', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
            DataColumn(
              label: Row(children: [
                const Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                Icon(sortCol == 'date' ? (sortAsc ? Icons.arrow_upward : Icons.arrow_downward) : Icons.unfold_more, size: 14),
              ]),
              onSort: (_, __) => onSort('date'),
            ),
            const DataColumn(label: Text('Actions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
          ],
          rows: complaints.map((c) => _buildRow(context, c)).toList(),
        ),
        ),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, Complaint c) {
    final techs = context.read<TechniciansProvider>().technicians;
    final assignedTech = techs.where((t) => t.id == c.assignedTechnicianId).firstOrNull;
    final cp = context.read<ComplaintsProvider>();
    final rowColor = switch (c.status) {
      ComplaintStatus.pending => AppColors.amber50,
      ComplaintStatus.active => AppColors.blue50,
      ComplaintStatus.completed => AppColors.green50,
      ComplaintStatus.rejected => AppColors.red50,
    };

    return DataRow(
      color: WidgetStateProperty.all(rowColor),
      onSelectChanged: (_) => context.go('/app/complaints/${c.id}'),
      cells: [
        DataCell(Text(c.ticketNo.isEmpty ? 'ID: ${c.id.substring(c.id.length - 6).toUpperCase()}' : c.ticketNo,
          style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600))),
        DataCell(SizedBox(
          width: 170,
          child: Row(children: [
            TechnicianAvatar(name: c.customer.name.isEmpty ? 'Unknown' : c.customer.name, size: 32),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.customer.name.isEmpty ? 'No Name' : c.customer.name, 
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                Text(c.customer.phone.isEmpty ? 'No Phone' : c.customer.phone, 
                  style: const TextStyle(fontSize: 11, color: AppColors.gray500), overflow: TextOverflow.ellipsis),
              ]),
            ),
          ]),
        )),
        DataCell(SizedBox(width: 160, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c.device.type.isEmpty ? 'Unknown Device' : '${c.device.brand} ${c.device.type}'.trim(), 
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
          Text(c.issue.isEmpty ? 'No issue described' : c.issue, 
            style: const TextStyle(fontSize: 11, color: AppColors.gray500), overflow: TextOverflow.ellipsis),
        ]))),
        DataCell(Row(children: [
          const Icon(Icons.location_on_outlined, size: 12, color: AppColors.gray400),
          const SizedBox(width: 4),
          Text(c.district.isEmpty ? 'No District' : c.district, style: const TextStyle(fontSize: 12)),
        ])),
        DataCell(PriorityBadge(priority: c.priority)),
        DataCell(StatusBadge(status: c.status)),
        DataCell(assignedTech != null
          ? Row(children: [
              TechnicianAvatar(name: assignedTech.name, size: 24),
              const SizedBox(width: 6),
              Text(assignedTech.name.split(' ').first, style: const TextStyle(fontSize: 12)),
            ])
          : const Text('Unassigned', style: TextStyle(fontSize: 12, color: AppColors.gray400))),
        DataCell(Text(DateFormat('dd MMM yy').format(c.createdAt), style: const TextStyle(fontSize: 12))),
        DataCell(Row(children: [
          IconButton(icon: const Icon(Icons.visibility_outlined, size: 16, color: AppColors.primary),
            onPressed: () => context.go('/app/complaints/${c.id}'), tooltip: 'View', padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: 4),
          if (c.status == ComplaintStatus.pending)
            IconButton(icon: const Icon(Icons.check, size: 16, color: AppColors.success),
              onPressed: () {
                cp.accept(c.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint accepted')));
              }, tooltip: 'Accept', padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: 4),
          if (c.status == ComplaintStatus.pending || c.status == ComplaintStatus.active)
            IconButton(icon: const Icon(Icons.close, size: 16, color: AppColors.danger),
              onPressed: () => RejectModal.show(context, c.id, (r) {
                cp.reject(c.id, r);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint rejected')));
              }),
              tooltip: 'Reject', padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: 4),
          if (c.status == ComplaintStatus.pending || c.status == ComplaintStatus.active)
            IconButton(icon: const Icon(Icons.person_add_outlined, size: 16, color: AppColors.info),
              onPressed: () => AssignModal.show(context, c.id, (techId) {
                cp.assign(c.id, techId);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Technician assigned')));
              }),
              tooltip: 'Assign', padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: 4),
          IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
            onPressed: () => _confirmDelete(context, cp, c.id), tooltip: 'Delete', padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ])),
      ],
    );
  }

  void _confirmDelete(BuildContext context, ComplaintsProvider cp, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Complaint'),
        content: const Text('Are you sure you want to permanently delete this complaint record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              cp.deleteComplaint(id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
