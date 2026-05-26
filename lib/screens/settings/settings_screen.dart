import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../layout/header_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _tab = 0;

  static const _tabs = [
    (Icons.business_outlined, 'Company'),
    (Icons.timer_outlined, 'Service SLAs'),
    (Icons.notifications_outlined, 'Notifications'),
    (Icons.group_outlined, 'Users & Roles'),
    (Icons.description_outlined, 'Templates'),
    (Icons.shield_outlined, 'Security'),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w >= 900;
    
    return Column(
      children: [
        const HeaderBar(title: 'Settings', subtitle: 'Manage your platform configuration'),
        Expanded(
          child: isWide
            ? Row(children: [
                _buildSidebar(isVertical: true),
                const VerticalDivider(width: 1, color: AppColors.gray100),
                Expanded(child: _buildContent()),
              ])
            : Column(children: [
                SingleChildScrollView(scrollDirection: Axis.horizontal, child: _buildSidebar(isVertical: false)),
                const Divider(height: 1, color: AppColors.gray100),
                Expanded(child: _buildContent()),
              ]),
        ),
      ],
    );
  }

  Widget _buildSidebar({required bool isVertical}) {
    Widget tabItem(int i) {
      final tab = _tabs[i];
      final isActive = _tab == i;
      return GestureDetector(
        onTap: () => setState(() => _tab = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: isVertical ? const EdgeInsets.only(bottom: 4) : const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.indigo50 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(tab.$1, size: 18, color: isActive ? AppColors.primary : AppColors.gray500),
            const SizedBox(width: 10),
            Text(tab.$2, style: TextStyle(fontSize: 13, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.primary : AppColors.gray600)),
          ]),
        ),
      );
    }

    if (isVertical) {
      return Container(
        width: 224, color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(children: List.generate(_tabs.length, tabItem)),
      );
    }
    return Row(children: List.generate(_tabs.length, tabItem));
  }

  Widget _buildContent() {
    void save() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle, color: Colors.white, size: 18),
        SizedBox(width: 8),
        Text('Settings saved!'),
      ]),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));

    return switch (_tab) {
      0 => _CompanyTab(onSave: save),
      1 => _SLATab(onSave: save),
      2 => _NotificationsTab(onSave: save),
      3 => const _UsersTab(),
      4 => const _TemplatesTab(),
      _ => _SecurityTab(onSave: save),
    };
  }
}

Widget _tf(String label, String init) => Padding(
  padding: const EdgeInsets.only(bottom: 16),
  child: TextFormField(initialValue: init, decoration: InputDecoration(labelText: label)),
);

class _CompanyTab extends StatelessWidget {
  final VoidCallback onSave;
  const _CompanyTab({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Company Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Text('TS', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)))),
              const SizedBox(width: 16),
              OutlinedButton.icon(icon: const Icon(Icons.upload_outlined, size: 16), label: const Text('Upload Logo'), onPressed: () {}),
            ]),
            const SizedBox(height: 20),
            _tf('Company Name', 'TechServe Solutions LLC'),
            LayoutBuilder(builder: (ctx, c) {
              final isWide = c.maxWidth > 500;
              return Wrap(spacing: 16, children: [
                SizedBox(width: isWide ? (c.maxWidth - 16) / 2 : c.maxWidth, child: _tf('Email', 'info@techserve.com')),
                SizedBox(width: isWide ? (c.maxWidth - 16) / 2 : c.maxWidth, child: _tf('Phone', '+968 2400 0000')),
                SizedBox(width: isWide ? (c.maxWidth - 16) / 2 : c.maxWidth, child: _tf('Tax ID', 'TXN-2024-12345')),
                SizedBox(width: isWide ? (c.maxWidth - 16) / 2 : c.maxWidth, child: _tf('Website', 'www.techserve.om')),
                SizedBox(width: isWide ? (c.maxWidth - 16) / 2 : c.maxWidth, child: _tf('Timezone', 'Asia/Muscat')),
                SizedBox(width: isWide ? (c.maxWidth - 16) / 2 : c.maxWidth, child: _tf('Currency', 'OMR')),
              ]);
            }),
            _tf('Address', 'Al Khuwair, Muscat, Sultanate of Oman'),
            ElevatedButton.icon(icon: const Icon(Icons.save_outlined, size: 16), label: const Text('Save Changes'), onPressed: onSave),
          ]),
        ),
      ]),
    );
  }
}

class _SLATab extends StatelessWidget {
  final VoidCallback onSave;
  const _SLATab({required this.onSave});

  @override
  Widget build(BuildContext context) {
    final slas = [
      ('Critical', AppColors.danger, '1', '4'),
      ('High', AppColors.orange500, '2', '8'),
      ('Medium', AppColors.warning, '4', '24'),
      ('Low', AppColors.gray400, '8', '48'),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Service Level Agreements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Define response and resolution time targets per priority level.', style: TextStyle(color: AppColors.gray500)),
        const SizedBox(height: 20),
        ...slas.map((s) => LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 500;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 8, height: 60, decoration: BoxDecoration(color: s.$2, borderRadius: BorderRadius.circular(4))),
                            const SizedBox(width: 16),
                            Expanded(child: Text(s.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(width: double.infinity, child: TextFormField(initialValue: s.$3, decoration: const InputDecoration(labelText: 'Response (h)', isDense: true))),
                        const SizedBox(height: 12),
                        SizedBox(width: double.infinity, child: TextFormField(initialValue: s.$4, decoration: const InputDecoration(labelText: 'Resolution (h)', isDense: true))),
                      ],
                    )
                  : Row(
                      children: [
                        Container(width: 8, height: 60, decoration: BoxDecoration(color: s.$2, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(width: 16),
                        Expanded(child: Text(s.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
                        const SizedBox(width: 20),
                        SizedBox(width: 120, child: TextFormField(initialValue: s.$3, decoration: const InputDecoration(labelText: 'Response (h)', isDense: true))),
                        const SizedBox(width: 16),
                        SizedBox(width: 120, child: TextFormField(initialValue: s.$4, decoration: const InputDecoration(labelText: 'Resolution (h)', isDense: true))),
                      ],
                    ),
            );
          },
        )),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: onSave, child: const Text('Save SLA Settings')),
      ]),
    );
  }
}

class _NotificationsTab extends StatefulWidget {
  final VoidCallback onSave;
  const _NotificationsTab({required this.onSave});
  @override
  State<_NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<_NotificationsTab> {
  Map<String, bool> _settings = {
    'email_new': true, 'email_assigned': true, 'email_completed': true,
    'sms_new': false, 'sms_assigned': true, 'sms_completed': false,
    'push_new': true, 'push_assigned': true, 'push_all': true, 'digest': true,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Notification Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        _section('Email Notifications', Icons.email_outlined, [
          ('New complaint submitted', 'email_new'),
          ('Complaint assigned to technician', 'email_assigned'),
          ('Complaint marked complete', 'email_completed'),
        ]),
        const SizedBox(height: 12),
        _section('SMS Notifications', Icons.sms_outlined, [
          ('New complaint submitted', 'sms_new'),
          ('Complaint assigned', 'sms_assigned'),
          ('Complaint marked complete', 'sms_completed'),
        ]),
        const SizedBox(height: 12),
        _section('In-App Notifications', Icons.notifications_outlined, [
          ('Push notifications for new complaints', 'push_new'),
          ('Push notifications on assignment', 'push_assigned'),
          ('All in-app notifications', 'push_all'),
          ('Daily digest email', 'digest'),
        ]),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: widget.onSave, child: const Text('Save Notification Settings')),
      ]),
    );
  }

  Widget _section(String title, IconData icon, List<(String, String)> items) => Container(
    padding: const EdgeInsets.all(20),
    decoration: AppTheme.cardDecoration,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 16),
      ...items.map((i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Expanded(child: Text(i.$1, style: const TextStyle(fontSize: 13))),
          CustomToggle(value: _settings[i.$2] ?? false, onChanged: (v) => setState(() => _settings[i.$2] = v)),
        ]),
      )),
    ]),
  );
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    final users = [
      ('Rahul Sharma', 'rahul.sharma@email.com', 'Super Admin', AppColors.purple500, true, '2024-02-16'),
      ('Priya Singh', 'priya.singh@email.com', 'Admin', AppColors.primary, true, '2024-02-15'),
      ('Amit Kumar', 'amit.kumar@email.com', 'Supervisor', AppColors.secondary, true, '2024-02-14'),
      ('Sunita Patel', 'sunita.patel@email.com', 'Dispatcher', AppColors.gray500, false, '2024-02-01'),
      ('Rakesh Mehta', 'rakesh.mehta@email.com', 'Technician', AppColors.success, true, '2024-02-12'),
      ('Suresh Gupta', 'suresh.gupta@email.com', 'Technician', AppColors.success, true, '2024-02-11'),
      ('Deepak Joshi', 'deepak.joshi@email.com', 'Technician', AppColors.success, false, '2024-02-10'),
      ('Neha Verma', 'neha.verma@email.com', 'Admin', AppColors.primary, true, '2024-02-09'),
      ('Kiran Rao', 'kiran.rao@email.com', 'Supervisor', AppColors.secondary, false, '2024-02-08'),
      ('Anjali Desai', 'anjali.desai@email.com', 'Dispatcher', AppColors.gray500, true, '2024-02-07'),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Users & Roles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
          ElevatedButton.icon(icon: const Icon(Icons.person_add_outlined, size: 16), label: const Text('Invite User'), onPressed: () {}),
        ]),
        const SizedBox(height: 20),
        Container(
          decoration: AppTheme.cardDecoration,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.gray50),
              horizontalMargin: 20, columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('User', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Role', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Last Login', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Actions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              ],
              rows: users.map((u) => DataRow(cells: [
                DataCell(SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    TechnicianAvatar(name: u.$1, size: 32),
                    const SizedBox(width: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Flexible(
                        child: Text(u.$1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                      ),
                      Flexible(
                        child: Text(u.$2, style: const TextStyle(fontSize: 11, color: AppColors.gray500), overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                  ]),
                )),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: u.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: u.$4.withOpacity(0.3))),
                  child: Text(u.$3, style: TextStyle(fontSize: 11, color: u.$4, fontWeight: FontWeight.w600)),
                )),
                DataCell(Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: u.$5 ? AppColors.success : AppColors.gray400, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(u.$5 ? 'active' : 'inactive', style: TextStyle(fontSize: 12, color: u.$5 ? AppColors.success : AppColors.gray400)),
                ])),
                DataCell(Text(u.$6, style: const TextStyle(fontSize: 12))),
                DataCell(Row(children: [
                  IconButton(icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.gray500), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                ])),
              ])).toList(),
            ),
          ),
        ),
      ]),
    );
  }
}

class _TemplatesTab extends StatelessWidget {
  const _TemplatesTab();

  @override
  Widget build(BuildContext context) {
    final templates = [
      ('New Complaint Confirmation', 'When customer submits complaint', ['Email', 'SMS']),
      ('Technician Assigned', 'When tech is assigned', ['Email']),
      ('Appointment Reminder', '24h before scheduled visit', ['SMS']),
      ('Complaint Completed', 'When marked as completed', ['Email', 'SMS']),
      ('Complaint Rejected', 'When rejected', ['Email']),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Message Templates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Configure automated messages sent to customers.', style: TextStyle(color: AppColors.gray500)),
        const SizedBox(height: 20),
        ...templates.map((t) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration,
          child: Row(children: [
            const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(t.$2, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
            ])),
            Wrap(spacing: 6, children: t.$3.map((c) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.indigo50, borderRadius: BorderRadius.circular(50)),
              child: Text(c, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
            )).toList()),
            const SizedBox(width: 12),
            OutlinedButton(onPressed: () {}, child: const Text('Edit', style: TextStyle(fontSize: 12))),
          ]),
        )),
      ]),
    );
  }
}

class _SecurityTab extends StatefulWidget {
  final VoidCallback onSave;
  const _SecurityTab({required this.onSave});
  @override
  State<_SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends State<_SecurityTab> {
  bool _tfa = true, _timeout = true, _ip = false, _audit = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Security Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        ...[
          ('Two-Factor Authentication', 'Require 2FA for all admin logins', _tfa, (v) => setState(() => _tfa = v)),
          ('Session Timeout', 'Auto-logout after 30 minutes', _timeout, (v) => setState(() => _timeout = v)),
          ('IP Whitelisting', 'Restrict access to specific IPs', _ip, (v) => setState(() => _ip = v)),
          ('Login Audit Log', 'Track all login attempts', _audit, (v) => setState(() => _audit = v)),
        ].map((s) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration,
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text(s.$2, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
            ])),
            CustomToggle(value: s.$3, onChanged: (v) => (s.$4 as void Function(bool))(v)),
          ]),
        )),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: widget.onSave, child: const Text('Save Security Settings')),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.red50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.danger.withOpacity(0.3)),
          ),
          child: Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Danger Zone', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.danger)),
              Text('These actions cannot be undone.', style: TextStyle(fontSize: 12, color: AppColors.danger)),
            ])),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
                title: const Text('Reset All Settings?'),
                content: const Text('This will reset all settings to their defaults. This cannot be undone.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                    onPressed: () => Navigator.pop(context), child: const Text('Reset')),
                ],
              )),
              child: const Text('Reset All Settings'),
            ),
          ]),
        ),
      ]),
    );
  }
}
class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}