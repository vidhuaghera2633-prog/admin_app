
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/scheduled_job.dart';
import '../../models/technician.dart';
import '../../providers/technicians_provider.dart';
import '../../providers/scheduled_jobs_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../layout/header_bar.dart';

// Dialog for scheduling a new job
class _ScheduleJobDialog extends StatefulWidget {
  final List<Technician> techs;
  const _ScheduleJobDialog({required this.techs});
  @override
  State<_ScheduleJobDialog> createState() => _ScheduleJobDialogState();
}

class _ScheduleJobDialogState extends State<_ScheduleJobDialog> {
  final _formKey = GlobalKey<FormState>();
  String customer = '';
  String device = '';
  String issue = '';
  String date = '';
  String time = '';
  Technician? technician;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule New Job'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => customer = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Device'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => device = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Issue'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => issue = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => date = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Time (HH:MM)'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => time = v ?? '',
              ),
              DropdownButtonFormField<Technician>(
                value: technician,
                decoration: const InputDecoration(labelText: 'Technician'),
                items: widget.techs.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t.name),
                )).toList(),
                onChanged: (t) => setState(() => technician = t),
                validator: (v) => v == null ? 'Select technician' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              final provider = context.read<ScheduledJobsProvider>();
              final newJob = ScheduledJob(
                id: 'j${DateTime.now().millisecondsSinceEpoch}',
                technicianId: technician!.id,
                complaintId: 'manual', // or get from a complaint dropdown
                date: date,
                time: time,
                duration: 1.5,
                customer: customer,
                district: technician!.districts.first,
                issue: issue,
              );
              await provider.addJob(newJob);
              if (mounted) Navigator.of(context).pop();
            }
          },
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}

enum ScheduleView { week, byTechnician, list }

class SchedulingScreen extends StatefulWidget {
  const SchedulingScreen({super.key});
  @override
  State<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  ScheduleView _view = ScheduleView.week;
  ScheduledJob? _selectedJob;

  static final _techColors = {
    't1': AppColors.primary,
    't2': AppColors.success,
    't3': AppColors.secondary,
    't4': AppColors.warning,
    't5': AppColors.purple500,
  };

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<ScheduledJobsProvider>().jobs;
    final techs = context.watch<TechniciansProvider>().technicians;
    final w = MediaQuery.sizeOf(context).width;

    return Column(
      children: [
        const HeaderBar(title: 'Scheduling', subtitle: 'Manage technician appointments'),
        // Toolbar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.white,
            child: Row(children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: AppColors.gray200), borderRadius: BorderRadius.circular(8)),
                child: const Text('19 Feb — 25 Feb 2024', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(border: Border.all(color: AppColors.primary), borderRadius: BorderRadius.circular(50)),
                child: const Text('Today', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              // View toggle
              Container(
                decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(3),
                child: Row(children: [
                  _viewTab('Week', ScheduleView.week),
                  _viewTab('By Tech', ScheduleView.byTechnician),
                  _viewTab('List', ScheduleView.list),
                ]),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Schedule Job'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => _ScheduleJobDialog(techs: techs),
                  );
                },
              ),
            ]),
          ),
        ),
        // Tech legend
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          color: Colors.white,
          child: Row(children: [
            ...techs.map((t) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: _techColors[t.id], shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      t.name.split(' ').first,
                      style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ]),
              ),
            )),
          ]),
        ),
        const Divider(height: 1, color: AppColors.gray100),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: switch (_view) {
                ScheduleView.week => _WeekView(jobs: jobs, techColors: _techColors, onJobTap: (j) => setState(() => _selectedJob = j)),
                ScheduleView.byTechnician => _TechView(jobs: jobs, techs: techs, techColors: _techColors),
                ScheduleView.list => _ListView(jobs: jobs, techs: techs, techColors: _techColors, onJobTap: (j) => setState(() => _selectedJob = j)),
              }),
              if (_selectedJob != null && w >= 900)
                _JobDetailSheet(job: _selectedJob!, techs: techs, techColors: _techColors, onClose: () => setState(() => _selectedJob = null)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _viewTab(String label, ScheduleView v) {
    final isActive = _view == v;
    return GestureDetector(
      onTap: () => setState(() => _view = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: isActive ? [const BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1))] : [],
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: isActive ? AppColors.gray900 : AppColors.gray500)),
      ),
    );
  }
}

class _WeekView extends StatelessWidget {
  final List<ScheduledJob> jobs;
  final Map<String, Color> techColors;
  final ValueChanged<ScheduledJob> onJobTap;

  const _WeekView({required this.jobs, required this.techColors, required this.onJobTap});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _dates = [19, 20, 21, 22, 23, 24, 25];
  static const _hours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17];

  String _dateStr(int date) => '2024-02-${date.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 600;
    final dayColWidth = isMobile ? 90.0 : 160.0;
    final timeColWidth = isMobile ? 44.0 : 64.0;
    final cellHeight = isMobile ? 44.0 : 60.0;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header row
            Row(children: [
              SizedBox(width: timeColWidth),
              ..._days.asMap().entries.map((e) => Container(
                width: dayColWidth,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _dates[e.key] == 20 ? AppColors.indigo50 : Colors.white,
                  border: const Border(right: BorderSide(color: AppColors.gray100)),
                ),
                child: Column(children: [
                  Text(e.value, style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
                  const SizedBox(height: 4),
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: _dates[e.key] == 20 ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text('${_dates[e.key]}', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: _dates[e.key] == 20 ? Colors.white : AppColors.gray700))),
                  ),
                ]),
              )),
            ]),
            ..._hours.map((h) => Row(children: [
              SizedBox(width: timeColWidth, child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                child: Text('${h}:00', style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
              )),
              ..._dates.asMap().entries.map((e) {
                final dayJobs = jobs.where((j) {
                  if (j.date != _dateStr(_dates[e.key])) return false;
                  final jobHour = int.tryParse(j.time.split(':')[0]) ?? 0;
                  return jobHour == h;
                }).toList();
                return Container(
                  width: dayColWidth, height: cellHeight,
                  decoration: BoxDecoration(
                    color: _dates[e.key] == 20 ? AppColors.indigo50.withOpacity(0.4) : Colors.white,
                    border: const Border(right: BorderSide(color: AppColors.gray100), bottom: BorderSide(color: AppColors.gray100)),
                  ),
                  child: Column(children: dayJobs.map((j) {
                    final color = techColors[j.technicianId] ?? AppColors.primary;
                    return GestureDetector(
                      onTap: () => onJobTap(j),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: color.withOpacity(0.4)),
                        ),
                        child: Row(children: [
                          Expanded(child: Text(j.customer.split(' ').first,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color), overflow: TextOverflow.ellipsis)),
                          const SizedBox(width: 2),
                          Icon(Icons.access_time, size: 8, color: color),
                          Text(j.time, style: TextStyle(fontSize: 8, color: color)),
                        ]),
                      ),
                    );
                  }).toList()),
                );
              }),
            ])),
          ],
        ),
      ),
    );
  }
}

class _TechView extends StatelessWidget {
  final List<ScheduledJob> jobs;
  final List<Technician> techs;
  final Map<String, Color> techColors;

  const _TechView({required this.jobs, required this.techs, required this.techColors});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: techs.map((t) {
          final techJobs = jobs.where((j) => j.technicianId == t.id).toList();
          final color = techColors[t.id] ?? AppColors.primary;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(children: [
                    TechnicianAvatar(name: t.name, size: 40, status: t.status),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(t.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text('${techJobs.length} jobs scheduled this week', style: TextStyle(fontSize: 12, color: color)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(50)),
                      child: Text(t.status.name, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ),
                if (techJobs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No jobs scheduled this week.', style: TextStyle(color: AppColors.gray400, fontSize: 13)),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 10, runSpacing: 10,
                      children: techJobs.map((j) => Container(
                        width: 200,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(j.customer, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(50)),
                            child: Text(j.time, style: const TextStyle(fontSize: 10, color: Colors.white)),
                          ),
                          const SizedBox(height: 6),
                          Text(j.issue, style: const TextStyle(fontSize: 11, color: AppColors.gray600), overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text('${j.date} · ${j.district}', style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
                        ]),
                      )).toList(),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  final List<ScheduledJob> jobs;
  final List<Technician> techs;
  final Map<String, Color> techColors;
  final ValueChanged<ScheduledJob> onJobTap;

  const _ListView({required this.jobs, required this.techs, required this.techColors, required this.onJobTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.gray50),
            horizontalMargin: 20, columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Customer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Issue', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              DataColumn(label: Text('District', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Technician', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Duration', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Actions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
            ],
            rows: jobs.map((j) {
              final tech = techs.firstWhere((t) => t.id == j.technicianId, orElse: () => techs.first);
              final color = techColors[j.technicianId] ?? AppColors.primary;
              return DataRow(cells: [
                DataCell(Text(j.date, style: const TextStyle(fontSize: 12))),
                DataCell(Text(j.time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                DataCell(Text(j.customer, style: const TextStyle(fontSize: 12))),
                DataCell(SizedBox(width: 140, child: Text(j.issue, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))),
                DataCell(Text(j.district, style: const TextStyle(fontSize: 12))),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(50)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    TechnicianAvatar(name: tech.name, size: 20),
                    const SizedBox(width: 6),
                    Text(tech.name.split(' ').first, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                  ]),
                )),
                DataCell(Text('${j.duration}h', style: const TextStyle(fontSize: 12))),
                DataCell(PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onSelected: (v) {
                    if (v == 'details') onJobTap(j);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'details', child: Text('View Details')),
                    const PopupMenuItem(value: 'reschedule', child: Text('Reschedule')),
                    const PopupMenuItem(value: 'reassign', child: Text('Reassign Technician')),
                    const PopupMenuItem(value: 'cancel', child: Text('Cancel Job', style: TextStyle(color: AppColors.danger))),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _JobDetailSheet extends StatelessWidget {
  final ScheduledJob job;
  final List<Technician> techs;
  final Map<String, Color> techColors;
  final VoidCallback onClose;

  const _JobDetailSheet({required this.job, required this.techs, required this.techColors, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final tech = techs.firstWhere((t) => t.id == job.technicianId, orElse: () => techs.first);
    final color = techColors[job.technicianId] ?? AppColors.primary;
    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: AppColors.gray100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gray100))),
            child: Row(children: [
              const Expanded(child: Text('Job Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
              IconButton(icon: const Icon(Icons.close), onPressed: onClose, padding: EdgeInsets.zero),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.indigo50, borderRadius: BorderRadius.circular(12)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(job.customer, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(job.issue, style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  _row(Icons.calendar_today_outlined, 'Date', job.date),
                  _row(Icons.access_time_outlined, 'Time', job.time),
                  _row(Icons.timer_outlined, 'Duration', '${job.duration} hours'),
                  _row(Icons.location_on_outlined, 'District', job.district),
                  const SizedBox(height: 20),
                  const Text('Assigned Technician', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      TechnicianAvatar(name: tech.name, size: 36, status: tech.status),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(tech.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(tech.phone, style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
                      ]),
                    ]),
                  ),
                  const Spacer(),
                  Column(children: [
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(
                      icon: const Icon(Icons.schedule, size: 16),
                      label: const Text('Reschedule'),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reschedule job...'))),
                    )),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.warning, side: const BorderSide(color: AppColors.warning)),
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('Reassign Technician'),
                      onPressed: () {},
                    )),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Cancel Job'),
                      onPressed: () {},
                    )),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Icon(icon, size: 16, color: AppColors.gray400),
      const SizedBox(width: 10),
      SizedBox(width: 70, child: Text(k, style: const TextStyle(fontSize: 12, color: AppColors.gray500))),
      Expanded(child: Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
    ]),
  );
}
