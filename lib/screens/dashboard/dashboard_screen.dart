import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/complaint.dart';
import '../../models/technician.dart';
import '../../providers/complaints_provider.dart';
import '../../providers/technicians_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../layout/header_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bp = _DashboardBreakpoints.fromWidth(MediaQuery.sizeOf(context).width);
    return Column(
      children: [
        HeaderBar(
          title: 'Dashboard',
          subtitle: "Welcome back! Here's what's happening today.",
          actions: ElevatedButton.icon(
            icon: const Icon(Icons.bolt, size: 16),
            label: const Text('Simulate Complaint'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () async {
              final id = 'test_${DateTime.now().millisecondsSinceEpoch}';
              final newComplaint = Complaint(
                id: id,
                ticketNo: 'TKT-SIM-${id.substring(id.length - 4)}',
                customer: Customer(
                  name: 'Jane Doe (Simulated)',
                  phone: '+1 555-0199',
                  email: 'jane.doe@example.com',
                ),
                device: Device(
                  type: 'AC',
                  brand: 'Carrier',
                  model: 'WeatherMaker',
                  serial: 'SIM12345',
                  purchaseDate: '',
                  warrantyExpiry: '',
                ),
                issue: 'Water leakage from the indoor unit',
                description: 'AC is leaking water continuously while running.',
                status: ComplaintStatus.pending,
                priority: Priority.high,
                district: 'West District',
                address: '100 Simulated Street',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              await context.read<ComplaintsProvider>().addComplaint(newComplaint);
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(bp.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _KPIGrid(bp: bp),
                SizedBox(height: bp.sectionGap),
                _ChartsRow(bp: bp),
                SizedBox(height: bp.sectionGap),
                _SecondRow(bp: bp),
                SizedBox(height: bp.sectionGap),
                const _RecentComplaintsTable(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardBreakpoints {
  final double width;
  const _DashboardBreakpoints._(this.width);

  factory _DashboardBreakpoints.fromWidth(double width) => _DashboardBreakpoints._(width);

  bool get isDesktop => width >= 1200;
  bool get isTablet => width >= 800 && width < 1200;
  bool get isPhone => width < 800;

  double get pagePadding => isPhone ? 12 : (isTablet ? 16 : 24);
  double get sectionGap => isPhone ? 16 : 24;
  double get cardGap => isPhone ? 12 : 16;
  int get kpiColumns => isDesktop ? 6 : (isTablet ? 3 : 2);
  bool get stackCharts => isPhone;
  bool get stackSecondRow => width < 1050;
  int get heatmapColumns => isPhone ? 2 : 3;
}

// ─── KPI Grid ────────────────────────────────────────────────────────────────

class _KPIGrid extends StatelessWidget {
  final _DashboardBreakpoints bp;
  const _KPIGrid({required this.bp});

  @override
  Widget build(BuildContext context) {
    final complaints = context.watch<ComplaintsProvider>().complaints;
    
    final total = complaints.length;
    final pending = complaints.where((c) => c.status == ComplaintStatus.pending).length;
    final active = complaints.where((c) => c.status == ComplaintStatus.active).length;
    final completed = complaints.where((c) => c.status == ComplaintStatus.completed).length;
    final rejected = complaints.where((c) => c.status == ComplaintStatus.rejected).length;
    
    final today = DateTime.now();
    final todayNew = complaints.where((c) => 
      c.createdAt.year == today.year && 
      c.createdAt.month == today.month && 
      c.createdAt.day == today.day).length;

    final stats = <(String, String, String, IconData, Color, Color)>[
      ('Total Complaints',    '$total',    '+$todayNew today',  Icons.layers_rounded,          AppColors.primary,          AppColors.indigo50),
      ('Pending Review',      '$pending',  '',  Icons.hourglass_empty_rounded, AppColors.warning,          AppColors.amber50),
      ('Active / In Progress','$active',   '',  Icons.timelapse_rounded,       AppColors.secondary,        AppColors.blue50),
      ('Completed',           '$completed','',  Icons.check_circle_rounded,    AppColors.success,          AppColors.green50),
      ('Rejected',            '$rejected', '',  Icons.cancel_rounded,          AppColors.danger,           AppColors.red50),
      ('Avg. Satisfaction',   '4.7 ⭐', '+0.2',      Icons.star_rounded,            const Color(0xFFF59E0B),    const Color(0xFFFFFBEB)),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = bp.kpiColumns;
        final cardWidth = ((constraints.maxWidth - ((cols - 1) * bp.cardGap)) / cols).clamp(120.0, 300.0);

        return Wrap(
          spacing: bp.cardGap,
          runSpacing: bp.cardGap,
          children: stats.asMap().entries.map((e) {
            final s = e.value;
            return SizedBox(
              width: cardWidth,
              child: KPIStatCard(
                label: s.$1, value: s.$2, badge: s.$3,
                icon: s.$4, iconColor: s.$5, iconBg: s.$6,
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: e.key * 80))
                  .slideY(begin: 0.1),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─── Charts Row ──────────────────────────────────────────────────────────────

class _ChartsRow extends StatelessWidget {
  final _DashboardBreakpoints bp;
  const _ChartsRow({required this.bp});

  @override
  Widget build(BuildContext context) {
    if (!bp.stackCharts) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _MonthlyChart()),
          SizedBox(width: bp.cardGap),
          Expanded(child: _DeviceDonut()),
        ],
      );
    }
    return Column(children: [
      _MonthlyChart(),
      SizedBox(height: bp.cardGap),
      _DeviceDonut(),
    ]);
  }
}

class _MonthlyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final complaints = context.watch<ComplaintsProvider>().complaints;
    
    // Simple monthly aggregation for the last 6 months
    final now = DateTime.now();
    final months = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i), 1));
    
    final data = months.map((m) {
      final monthComplaints = complaints.where((c) => c.createdAt.year == m.year && c.createdAt.month == m.month).length;
      final monthResolved = complaints.where((c) => c.createdAt.year == m.year && c.createdAt.month == m.month && c.status == ComplaintStatus.completed).length;
      return {
        'month': DateFormat('MMM').format(m),
        'complaints': monthComplaints,
        'resolved': monthResolved,
      };
    }).toList();

    List<FlSpot> spots(String key) => data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), (e.value[key] as int).toDouble()))
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(
              child: Text('Monthly Overview',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            _legendLine(AppColors.primary, 'New'),
            const SizedBox(width: 12),
            _legendLine(AppColors.success, 'Resolved'),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: AppColors.gray100, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                        return Text(data[idx]['month'] as String,
                            style: const TextStyle(fontSize: 11, color: AppColors.gray500));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}',
                          style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
                    ),
                  ),
                  topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  _bar(spots('complaints'), AppColors.primary),
                  _bar(spots('resolved'),   AppColors.success),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _bar(List<FlSpot> s, Color c) => LineChartBarData(
    spots: s, color: c, isCurved: true, barWidth: 2.5,
    dotData: const FlDotData(show: false),
    belowBarData: BarAreaData(show: true, color: c.withAlpha(20)),
  );

  Widget _legendLine(Color color, String label) => Row(children: [
    Container(width: 12, height: 3,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
  ]);
}

class _DeviceDonut extends StatelessWidget {
  static const _colors = <Color>[
    AppColors.primary, AppColors.secondary, AppColors.success,
    AppColors.warning, AppColors.danger, AppColors.purple500,
  ];

  @override
  Widget build(BuildContext context) {
    final complaints = context.watch<ComplaintsProvider>().complaints;
    final deviceCounts = <String, int>{};
    for (var c in complaints) {
      deviceCounts[c.device.type] = (deviceCounts[c.device.type] ?? 0) + 1;
    }
    
    final data = deviceCounts.entries
        .map((e) => {'name': e.key, 'count': e.value})
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('By Device Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: data.asMap().entries.map((e) => PieChartSectionData(
                  value: (e.value['count'] as int).toDouble(),
                  color: _colors[e.key],
                  radius: 50,
                  showTitle: false,
                )).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...data.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              Container(width: 10, height: 10,
                  decoration: BoxDecoration(color: _colors[e.key], shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(e.value['name'] as String,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray600))),
              Text('${e.value['count']}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          )),
        ],
      ),
    );
  }
}

// ─── Second Row ───────────────────────────────────────────────────────────────

class _SecondRow extends StatelessWidget {
  final _DashboardBreakpoints bp;
  const _SecondRow({required this.bp});

  @override
  Widget build(BuildContext context) {
    if (!bp.stackSecondRow) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _HeatmapCard()),
          SizedBox(width: bp.cardGap),
          Expanded(child: _WeeklyBarChart()),
          SizedBox(width: bp.cardGap),
          Expanded(child: _TechnicianSummary()),
        ],
      );
    }
    return Column(children: [
      _HeatmapCard(), SizedBox(height: bp.cardGap),
      _WeeklyBarChart(), SizedBox(height: bp.cardGap),
      _TechnicianSummary(),
    ]);
  }
}

class _HeatmapCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final complaints = context.watch<ComplaintsProvider>().complaints;
    final districtCounts = <String, int>{};
    for (var c in complaints) {
      districtCounts[c.district] = (districtCounts[c.district] ?? 0) + 1;
    }

    final maxCount = districtCounts.values.fold(0, (max, e) => e > max ? e : max);
    
    final data = districtCounts.entries
        .map((e) => {
          'name': e.key, 
          'count': e.value, 
          'intensity': maxCount > 0 ? e.value / maxCount : 0.0
        })
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    final bp = _DashboardBreakpoints.fromWidth(MediaQuery.sizeOf(context).width);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('District Heatmap',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: bp.heatmapColumns, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: bp.isPhone ? 1.35 : 1.5),
            itemCount: data.length,
            itemBuilder: (_, i) {
              final d = data[i];
              final intensity = d['intensity'] as double;
              final isLight = intensity <= 0.5;
              final bgAlpha = ((intensity * 0.7 + 0.08) * 255).round().clamp(0, 255);
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(bgAlpha),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(d['name'] as String,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: isLight ? AppColors.primary : Colors.white)),
                    Text('${d['count']}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                            color: isLight ? AppColors.primary : Colors.white)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Text('Low', style: TextStyle(fontSize: 10, color: AppColors.gray500)),
            Expanded(
              child: Container(
                height: 6, margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(colors: [
                    AppColors.primary.withAlpha(26),
                    AppColors.primary,
                  ]),
                ),
              ),
            ),
            const Text('High', style: TextStyle(fontSize: 10, color: AppColors.gray500)),
          ]),
        ],
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final complaints = context.watch<ComplaintsProvider>().complaints;
    
    // Aggregation for the last 7 days
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    
    final data = days.map((d) {
      final dayComplaints = complaints.where((c) => 
        c.createdAt.year == d.year && c.createdAt.month == d.month && c.createdAt.day == d.day).length;
      final dayResolved = complaints.where((c) => 
        c.createdAt.year == d.year && c.createdAt.month == d.month && c.createdAt.day == d.day && c.status == ComplaintStatus.completed).length;
      return {
        'day': DateFormat('E').format(d),
        'complaints': dayComplaints,
        'resolved': dayResolved,
      };
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(child: Text('This Week',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            _dot(AppColors.primary, 'New'),
            const SizedBox(width: 10),
            _dot(AppColors.success, 'Resolved'),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                barGroups: data.asMap().entries.map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                        toY: (e.value['complaints'] as int).toDouble(),
                        color: AppColors.primary, width: 8,
                        borderRadius: BorderRadius.circular(4)),
                    BarChartRodData(
                        toY: (e.value['resolved'] as int).toDouble(),
                        color: AppColors.success, width: 8,
                        borderRadius: BorderRadius.circular(4)),
                  ],
                )).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                        return Text(data[idx]['day'] as String,
                            style: const TextStyle(fontSize: 10, color: AppColors.gray500));
                      },
                    ),
                  ),
                  leftTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: AppColors.gray100, strokeWidth: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color c, String l) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(l, style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
  ]);
}

class _TechnicianSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bp = _DashboardBreakpoints.fromWidth(MediaQuery.sizeOf(context).width);
    final techs = context.watch<TechniciansProvider>().technicians;
    final available = techs.where((t) => t.status == TechnicianStatus.available).length;
    final busy      = techs.where((t) => t.status == TechnicianStatus.busy).length;
    final offline   = techs.where((t) => t.status == TechnicianStatus.offline).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(child: Text('Technicians',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            TextButton(
              onPressed: () => context.go('/app/technicians'),
              child: const Text('View all →', style: TextStyle(fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statChip('Available', available, AppColors.green50,  AppColors.green600),
              _statChip('Busy',      busy,      AppColors.amber50,  AppColors.amber600),
              _statChip('Offline',   offline,   AppColors.gray100,  AppColors.gray500),
            ],
          ),
          const SizedBox(height: 16),
          ...techs.take(4).map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              TechnicianAvatar(name: t.name, size: bp.isPhone ? 32 : 36, status: t.status),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                Text('${t.activeJobs} active jobs',
                    style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
              ])),
              _statusChip(t.status),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _statChip(String label, int count, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Column(children: [
      Text('$count', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: fg)),
      Text(label,    style: TextStyle(fontSize: 10, color: fg)),
    ]),
  );

  Widget _statusChip(TechnicianStatus status) {
    final (String label, Color bg, Color fg) = switch (status) {
      TechnicianStatus.available => ('Available', AppColors.green50,  AppColors.green600),
      TechnicianStatus.busy      => ('Busy',      AppColors.amber50,  AppColors.amber600),
      TechnicianStatus.offline   => ('Offline',   AppColors.gray100,  AppColors.gray500),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(50)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ─── Recent Complaints Table ──────────────────────────────────────────────────

class _RecentComplaintsTable extends StatelessWidget {
  const _RecentComplaintsTable();

  @override
  Widget build(BuildContext context) {
    final bp = _DashboardBreakpoints.fromWidth(MediaQuery.sizeOf(context).width);
    final complaints = [...context.watch<ComplaintsProvider>().complaints]
      ..sort((a, b) {
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
    final recentComplaints = complaints.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(child: Text('Recent Complaints',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            TextButton(
              onPressed: () => context.go('/app/complaints'),
              child: const Text('View all →', style: TextStyle(fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            '${recentComplaints.length} latest tickets',
            style: const TextStyle(fontSize: 12, color: AppColors.gray500),
          ),
          const SizedBox(height: 16),
          if (recentComplaints.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray100),
              ),
              child: const Text(
                'No recent complaints',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.gray500),
              ),
            )
          else
            Column(
              children: recentComplaints.asMap().entries.map((entry) {
                final index = entry.key;
                final c = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: index == recentComplaints.length - 1 ? 0 : 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.go('/app/complaints/${c.id}'),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(bp.isPhone ? 12 : 14),
                      decoration: BoxDecoration(
                        color: switch (c.status) {
                          ComplaintStatus.pending => AppColors.amber50,
                          ComplaintStatus.active => AppColors.blue50,
                          ComplaintStatus.completed => AppColors.green50,
                          ComplaintStatus.rejected => AppColors.red50,
                        },
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: switch (c.status) {
                            ComplaintStatus.pending => AppColors.amber100,
                            ComplaintStatus.active => AppColors.blue100,
                            ComplaintStatus.completed => AppColors.green100,
                            ComplaintStatus.rejected => AppColors.red100,
                          },
                        ),
                      ),
                      child: bp.isPhone ? _mobileItem(c) : _desktopItem(c),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _desktopItem(Complaint c) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            c.ticketNo,
            style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              TechnicianAvatar(name: c.customer.name, size: 30),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  c.customer.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(
            '${c.device.brand} ${c.device.type}',
            style: const TextStyle(fontSize: 12, color: AppColors.gray700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: Text(
            c.issue,
            style: const TextStyle(fontSize: 12, color: AppColors.gray600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        PriorityBadge(priority: c.priority),
        const SizedBox(width: 8),
        StatusBadge(status: c.status),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.gray400),
      ],
    );
  }

  Widget _mobileItem(Complaint c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                c.ticketNo,
                style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            StatusBadge(status: c.status),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            TechnicianAvatar(name: c.customer.name, size: 30),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                c.customer.name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            PriorityBadge(priority: c.priority),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${c.device.brand} ${c.device.type} • ${c.district}',
          style: const TextStyle(fontSize: 11, color: AppColors.gray500),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          c.issue,
          style: const TextStyle(fontSize: 12, color: AppColors.gray700),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}