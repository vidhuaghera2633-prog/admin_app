import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/mock_data.dart';
import '../../models/complaint.dart';
import '../../models/technician.dart';
import '../../providers/complaints_provider.dart';
import '../../providers/technicians_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../layout/header_bar.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _dateRange = 'This Month';
  String _district = 'All Districts';
  String _format = 'CSV';
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HeaderBar(title: 'Reports & Analytics', subtitle: 'View insights and export data'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FiltersBar(dateRange: _dateRange, district: _district, format: _format,
                  onDateRange: (v) => setState(() => _dateRange = v!),
                  onDistrict: (v) => setState(() => _district = v!),
                  onFormat: (v) => setState(() => _format = v!),
                  onExport: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exporting report as $_format...'))),
                ),
                const SizedBox(height: 20),
                _KPICards(),
                const SizedBox(height: 20),
                _TabBar(current: _tab, onTap: (i) => setState(() => _tab = i)),
                const SizedBox(height: 20),
                _TabContent(tab: _tab),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FiltersBar extends StatelessWidget {
  final String dateRange, district, format;
  final ValueChanged<String?> onDateRange, onDistrict, onFormat;
  final VoidCallback onExport;

  const _FiltersBar({required this.dateRange, required this.district, required this.format,
    required this.onDateRange, required this.onDistrict, required this.onFormat, required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Wrap(
        spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.gray500),
            const SizedBox(width: 8),
            _drop(dateRange, ['Today', 'This Week', 'This Month', 'Last 3 Months', 'This Year', 'Custom Range'], onDateRange),
          ]),
          _drop(district, ['All Districts', 'Muscat', 'Seeb', 'Barka', 'Sohar', 'Nizwa'], onDistrict),
          const Spacer(),
          _drop(format, ['CSV', 'PDF', 'Excel'], onFormat),
          ElevatedButton.icon(
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Export'),
            onPressed: onExport,
          ),
        ],
      ),
    );
  }

  Widget _drop(String value, List<String> items, ValueChanged<String?> onChange) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(border: Border.all(color: AppColors.gray200), borderRadius: BorderRadius.circular(12), color: Colors.white),
        child: DropdownButton<String>(
          value: value, isDense: true,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChange,
        ),
      ),
    );
  }
}

class _KPICards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final complaints = context.watch<ComplaintsProvider>().complaints;
    final total = complaints.length;
    final completed = complaints.where((c) => c.status == ComplaintStatus.completed).length;
    final rate = total > 0 ? (completed / total * 100).toStringAsFixed(1) : '0';

    final w = MediaQuery.sizeOf(context).width;
    final isWide = w >= 900;
    final items = [
      ('Total Complaints', '$total', '', AppColors.primary, AppColors.indigo50),
      ('Completion Rate', '$rate%', '', AppColors.success, AppColors.green50),
      ('Avg. Response Time', '2.4h', '-18min', AppColors.secondary, AppColors.blue50),
      ('Avg. Satisfaction', '4.7/5', '+0.2', const Color(0xFFF59E0B), const Color(0xFFFFFBEB)),
    ];
    return Wrap(
      spacing: 16, runSpacing: 16,
      children: items.map((item) => SizedBox(
        width: isWide ? ((w - 240 - 48 - 48) / 4).clamp(180, 280) : (w - 64) / 2,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: item.$5,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: item.$4.withOpacity(0.2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.$1, style: TextStyle(fontSize: 12, color: item.$4, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(item.$2, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: item.$4)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: item.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(50)),
              child: Text(item.$3, style: TextStyle(fontSize: 11, color: item.$4, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      )).toList(),
    );
  }
}

class _TabBar extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _TabBar({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (Icons.bar_chart_rounded, 'Overview'),
      (Icons.description_outlined, 'Complaints'),
      (Icons.group_outlined, 'Technicians'),
      (Icons.timer_outlined, 'SLA Report'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: tabs.asMap().entries.map((e) {
        final isActive = current == e.key;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onTap(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isActive ? AppColors.primary : AppColors.gray200),
              ),
              child: Row(children: [
                Icon(e.value.$1, size: 16, color: isActive ? Colors.white : AppColors.gray500),
                const SizedBox(width: 8),
                Text(e.value.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.gray600)),
              ]),
            ),
          ),
        );
      }).toList()),
    );
  }
}

class _TabContent extends StatelessWidget {
  final int tab;
  const _TabContent({required this.tab});

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      0 => _OverviewTab(),
      1 => _ComplaintsTab(),
      2 => _TechniciansTab(),
      _ => _SLATab(),
    };
  }
}

class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w >= 900;
    return Wrap(
      spacing: 16, runSpacing: 16,
      children: [
        _chartCard('Monthly Trend', _MonthlyLine(), isWide, w),
        _chartCard('By District', _DistrictBar(), isWide, w),
        _chartCard('Device Type Breakdown', _DevicePie(), isWide, w),
        _chartCard('Weekly Volume', _WeeklyBar(), isWide, w),
      ],
    );
  }

  Widget _chartCard(String title, Widget chart, bool isWide, double w) => Container(
    width: isWide ? ((w - 240 - 48 - 16) / 2).clamp(300, 600) : double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: AppTheme.cardDecoration,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      chart,
    ]),
  );
}

class _MonthlyLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final complaints = context.watch<ComplaintsProvider>().complaints;
    final now = DateTime.now();
    final months = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i), 1));
    
    final data = months.map((m) {
      return {
        'month': DateFormat('MMM').format(m),
        'complaints': complaints.where((c) => c.createdAt.year == m.year && c.createdAt.month == m.month).length,
        'resolved': complaints.where((c) => c.createdAt.year == m.year && c.createdAt.month == m.month && c.status == ComplaintStatus.completed).length,
      };
    }).toList();

    return SizedBox(height: 180, child: LineChart(LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.gray100, strokeWidth: 1)),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
          getTitlesWidget: (v, _) {
            final idx = v.toInt();
            if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
            return Text(data[idx]['month'] as String, style: const TextStyle(fontSize: 10, color: AppColors.gray500));
          })),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32,
          getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 9, color: AppColors.gray500)))),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['complaints'] as int).toDouble())).toList(),
          color: AppColors.primary, isCurved: true, barWidth: 2, dotData: FlDotData(
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 3, color: AppColors.primary, strokeColor: Colors.white, strokeWidth: 1.5))),
        LineChartBarData(spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['resolved'] as int).toDouble())).toList(),
          color: AppColors.success, isCurved: true, barWidth: 2, dotData: FlDotData(
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 3, color: AppColors.success, strokeColor: Colors.white, strokeWidth: 1.5))),
      ],
    )));
  }
}

class _DistrictBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final complaints = context.watch<ComplaintsProvider>().complaints;
    final districtCounts = <String, int>{};
    for (var c in complaints) {
      districtCounts[c.district] = (districtCounts[c.district] ?? 0) + 1;
    }
    
    final data = districtCounts.entries
        .map((e) => {'name': e.key, 'count': e.value})
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    
    final displayData = data.take(6).toList();
    final colors = [AppColors.primary, AppColors.secondary, AppColors.success, AppColors.warning, AppColors.danger, AppColors.purple500];
    return SizedBox(height: 180, child: BarChart(BarChartData(
      barGroups: displayData.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [
        BarChartRodData(toY: (e.value['count'] as int).toDouble(), color: colors[e.key % colors.length], width: 24, borderRadius: BorderRadius.circular(4)),
      ])).toList(),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
          getTitlesWidget: (v, _) {
            final idx = v.toInt();
            if (idx < 0 || idx >= displayData.length) return const SizedBox.shrink();
            return Text(displayData[idx]['name'] as String,
              style: const TextStyle(fontSize: 9, color: AppColors.gray500), overflow: TextOverflow.ellipsis);
          })),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.gray100, strokeWidth: 1)),
    )));
  }
}

class _DevicePie extends StatelessWidget {
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

    final colors = [
      AppColors.primary, AppColors.secondary, AppColors.success,
      AppColors.warning, AppColors.danger, AppColors.purple500,
    ];
    final total = complaints.length;
    return Column(children: [
      if (total > 0) ...[
        SizedBox(height: 140, child: PieChart(PieChartData(
          sectionsSpace: 2, centerSpaceRadius: 36,
          sections: data.asMap().entries.map((e) => PieChartSectionData(
            value: (e.value['count'] as int).toDouble(), color: colors[e.key % colors.length], radius: 46, showTitle: false,
          )).toList(),
        ))),
        const SizedBox(height: 12),
        ...data.asMap().entries.map((e) {
          final count = e.value['count'] as int;
          final pct = (count / total * 100).toStringAsFixed(1);
          return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
            Container(width: 10, height: 10, margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(color: colors[e.key % colors.length], shape: BoxShape.circle)),
            Expanded(child: Text(e.value['name'] as String, style: const TextStyle(fontSize: 12))),
            Text('$pct%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            SizedBox(width: 80, child: LinearProgressIndicator(
              value: count / total,
              backgroundColor: AppColors.gray100, color: colors[e.key % colors.length], minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            )),
          ]));
        }),
      ] else
        const Center(child: Text('No data available')),
    ]);
  }
}

class _WeeklyBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final complaints = context.watch<ComplaintsProvider>().complaints;
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    
    final data = days.map((d) {
      return {
        'day': DateFormat('E').format(d),
        'complaints': complaints.where((c) => c.createdAt.year == d.year && c.createdAt.month == d.month && c.createdAt.day == d.day).length,
        'resolved': complaints.where((c) => c.createdAt.year == d.year && c.createdAt.month == d.month && c.createdAt.day == d.day && c.status == ComplaintStatus.completed).length,
      };
    }).toList();

    return SizedBox(height: 160, child: BarChart(BarChartData(
      barGroups: data.asMap().entries.map((e) => BarChartGroupData(x: e.key, barsSpace: 4, barRods: [
        BarChartRodData(toY: (e.value['complaints'] as int).toDouble(), color: AppColors.primary, width: 10, borderRadius: BorderRadius.circular(3)),
        BarChartRodData(toY: (e.value['resolved'] as int).toDouble(), color: AppColors.success, width: 10, borderRadius: BorderRadius.circular(3)),
      ])).toList(),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
          getTitlesWidget: (v, _) {
            final idx = v.toInt();
            if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
            return Text(data[idx]['day'] as String, style: const TextStyle(fontSize: 10, color: AppColors.gray500));
          })),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.gray100, strokeWidth: 1)),
    )));
  }
}

class _ComplaintsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w >= 900;
    return Wrap(spacing: 16, runSpacing: 16, children: [
      _card('Status Distribution', [
        ('Completed', 48.0, AppColors.success),
        ('Active', 29.0, AppColors.secondary),
        ('Pending', 18.0, AppColors.warning),
        ('Rejected', 5.0, AppColors.danger),
      ], isWide, w),
      _card('Priority Breakdown', [
        ('Critical', 7.0, AppColors.danger),
        ('High', 22.0, AppColors.orange500),
        ('Medium', 45.0, AppColors.warning),
        ('Low', 26.0, AppColors.gray400),
      ], isWide, w),
    ]);
  }

  Widget _card(String title, List<(String, double, Color)> items, bool isWide, double w) => Container(
    width: isWide ? ((w - 240 - 48 - 16) / 2).clamp(300, 600) : double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: AppTheme.cardDecoration,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      ...items.map((i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(children: [
          SizedBox(width: 90, child: Text(i.$1, style: const TextStyle(fontSize: 13))),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            LinearProgressIndicator(value: i.$2 / 100, backgroundColor: AppColors.gray100, color: i.$3, minHeight: 8,
              borderRadius: BorderRadius.circular(4)),
          ])),
          const SizedBox(width: 10),
          Text('${i.$2}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: i.$3)),
        ]),
      )),
    ]),
  );
}

class _TechniciansTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final techs = context.watch<TechniciansProvider>().technicians;
    return Column(children: [
      Container(
        decoration: AppTheme.cardDecoration,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.gray50),
            horizontalMargin: 20, columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('Technician', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Completed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Active', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Rating', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Districts', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Completion Rate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
            ],
            rows: techs.map((t) {
              final rate = t.completedJobs / (t.completedJobs + t.activeJobs + 1);
              return DataRow(cells: [
                DataCell(Row(children: [
                  TechnicianAvatar(name: t.name, size: 32),
                  const SizedBox(width: 8),
                  Text(t.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ])),
                DataCell(Text('${t.completedJobs}', style: const TextStyle(fontSize: 12))),
                DataCell(Text('${t.activeJobs}', style: const TextStyle(fontSize: 12))),
                DataCell(Row(children: [
                  const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 3),
                  Text('${t.rating}', style: const TextStyle(fontSize: 12)),
                ])),
                DataCell(Text(t.districts.take(2).join(', '), style: const TextStyle(fontSize: 12))),
                DataCell(StatusDot(status: t.status, size: 10)),
                DataCell(SizedBox(width: 120, child: Row(children: [
                  Expanded(child: LinearProgressIndicator(value: rate, backgroundColor: AppColors.gray100, color: AppColors.primary, minHeight: 6, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 8),
                  Text('${(rate * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ]))),
              ]);
            }).toList(),
          ),
        ),
      ),
    ]);
  }
}

class _SLATab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w >= 900;
    final slaData = [
      {'month': 'Sep', 'ontime': 92, 'late': 8},
      {'month': 'Oct', 'ontime': 88, 'late': 12},
      {'month': 'Nov', 'ontime': 95, 'late': 5},
      {'month': 'Dec', 'ontime': 90, 'late': 10},
      {'month': 'Jan', 'ontime': 93, 'late': 7},
      {'month': 'Feb', 'ontime': 91, 'late': 9},
    ];
    return Column(children: [
      Wrap(spacing: 16, runSpacing: 16, children: [
        _metricCard('SLA Compliance', '91.2%', 'Target: 90%', AppColors.success, AppColors.green50, isWide, w),
        _metricCard('Avg. Resolution Time', '4.2h', 'Target: 6h', AppColors.primary, AppColors.indigo50, isWide, w),
        _metricCard('Avg. First Response', '2.4h', 'Target: 4h', AppColors.secondary, AppColors.blue50, isWide, w),
      ]),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.cardDecoration,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('SLA On-Time vs. Late (Monthly)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: BarChart(BarChartData(
            barGroups: slaData.asMap().entries.map((e) => BarChartGroupData(x: e.key, barsSpace: 4, barRods: [
              BarChartRodData(toY: (e.value['ontime'] as int).toDouble(), color: AppColors.success, width: 20, borderRadius: BorderRadius.circular(4)),
              BarChartRodData(toY: (e.value['late'] as int).toDouble(), color: AppColors.danger, width: 20, borderRadius: BorderRadius.circular(4)),
            ])).toList(),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                getTitlesWidget: (v, _) => Text(slaData[v.toInt()]['month'] as String, style: const TextStyle(fontSize: 11, color: AppColors.gray500)))),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32,
                getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10, color: AppColors.gray500)))),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.gray100, strokeWidth: 1)),
          ))),
        ]),
      ),
    ]);
  }

  Widget _metricCard(String title, String value, String target, Color fg, Color bg, bool isWide, double w) => Container(
    width: isWide ? ((w - 240 - 48 - 32) / 3).clamp(180, 300) : double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: fg.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: fg)),
      const SizedBox(height: 4),
      Text(target, style: TextStyle(fontSize: 12, color: fg.withOpacity(0.7))),
    ]),
  );
}