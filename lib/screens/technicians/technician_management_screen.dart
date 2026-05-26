import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/technician.dart';
import '../../providers/technicians_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../layout/header_bar.dart';

const _allSkills = ['AC Repair', 'Refrigerator', 'Washing Machine', 'Dryer', 'Dishwasher', 'TV Repair',
  'Small Appliances', 'Smart Home', 'Home Theater', 'Freezer', 'Ice Maker'];
const _allDistricts = ['Muscat', 'Seeb', 'Barka', 'Sohar', 'Nizwa', 'Ibri', 'Sur', 'Salalah', 'Rustaq', 'Nakhal', 'Liwa', 'Shinas', 'Qurum'];

class TechnicianManagementScreen extends StatefulWidget {
  const TechnicianManagementScreen({super.key});
  @override
  State<TechnicianManagementScreen> createState() => _TechnicianManagementState();
}

class _TechnicianManagementState extends State<TechnicianManagementScreen> {
  String? _selectedId;
  String _search = '';
  TechnicianStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final techs = context.watch<TechniciansProvider>().technicians;
    final filtered = techs.where((t) {
      if (_search.isNotEmpty && !t.name.toLowerCase().contains(_search.toLowerCase())) return false;
      if (_statusFilter != null && t.status != _statusFilter) return false;
      return true;
    }).toList();
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w >= 900;
    final selected = _selectedId != null ? techs.firstWhere((t) => t.id == _selectedId, orElse: () => techs.first) : null;

    return Column(
      children: [
        const HeaderBar(title: 'Technician Management', subtitle: 'Manage your field service team'),
        Expanded(
          child: isWide
            ? Row(children: [
                SizedBox(width: 340, child: _TechList(techs: filtered, selectedId: _selectedId, search: _search, statusFilter: _statusFilter,
                  onSearch: (v) => setState(() => _search = v), onStatus: (v) => setState(() => _statusFilter = v),
                  onSelect: (id) => setState(() => _selectedId = id),
                  onAddNew: () => _showForm(context, null),
                )),
                const VerticalDivider(width: 1, color: AppColors.gray100),
                Expanded(child: selected != null ? _TechDetail(tech: selected) : _EmptyDetail()),
              ])
            : _TechList(techs: filtered, selectedId: _selectedId, search: _search, statusFilter: _statusFilter,
                onSearch: (v) => setState(() => _search = v), onStatus: (v) => setState(() => _statusFilter = v),
                onSelect: (id) => setState(() => _selectedId = id),
                onAddNew: () => _showForm(context, null),
              ),
        ),
      ],
    );
  }

  void _showForm(BuildContext context, Technician? tech) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => TechnicianFormSheet(technician: tech),
    );
  }
}

class _TechList extends StatelessWidget {
  final List<Technician> techs;
  final String? selectedId, search;
  final TechnicianStatus? statusFilter;
  final ValueChanged<String> onSearch;
  final ValueChanged<TechnicianStatus?> onStatus;
  final ValueChanged<String> onSelect;
  final VoidCallback onAddNew;

  const _TechList({required this.techs, required this.selectedId, required this.search, required this.statusFilter,
    required this.onSearch, required this.onStatus, required this.onSelect, required this.onAddNew});

  @override
  Widget build(BuildContext context) {
    final allTechs = context.watch<TechniciansProvider>().technicians;
    final counts = {
      null: allTechs.length,
      TechnicianStatus.available: allTechs.where((t) => t.status == TechnicianStatus.available).length,
      TechnicianStatus.busy: allTechs.where((t) => t.status == TechnicianStatus.busy).length,
      TechnicianStatus.offline: allTechs.where((t) => t.status == TechnicianStatus.offline).length,
    };
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(children: [
                Expanded(child: TextField(
                  onChanged: onSearch,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search, size: 20), hintText: 'Search...', isDense: true),
                )),
                const SizedBox(width: 8),
                ElevatedButton.icon(icon: const Icon(Icons.add, size: 16), label: const Text('Add'), onPressed: onAddNew),
              ]),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  ...[null, TechnicianStatus.available, TechnicianStatus.busy, TechnicianStatus.offline].map((s) {
                    final isActive = statusFilter == s;
                    final label = s == null ? 'All' : s.name[0].toUpperCase() + s.name.substring(1);
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => onStatus(s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primary : AppColors.gray100,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text('$label (${counts[s]})', style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : AppColors.gray600)),
                        ),
                      ),
                    );
                  }),
                ]),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.gray100),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: techs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) => _TechCard(tech: techs[i], isSelected: techs[i].id == selectedId, onTap: () => onSelect(techs[i].id)),
          ),
        ),
      ],
    );
  }
}

class _TechCard extends StatelessWidget {
  final Technician tech;
  final bool isSelected;
  final VoidCallback onTap;
  const _TechCard({required this.tech, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tp = context.read<TechniciansProvider>();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.gray100, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withAlpha((0.15 * 255).round()), blurRadius: 8, offset: const Offset(0, 2))] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              TechnicianAvatar(name: tech.name, size: 44, status: tech.status),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tech.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Row(children: [
                  const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 2),
                  Text('${tech.rating}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  Text('${tech.completedJobs} jobs', style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
                ]),
              ])),
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.gray500),
                  onPressed: () => showModalBottomSheet(
                    context: context, isScrollControlled: true,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (_) => TechnicianFormSheet(technician: tech),
                  ),
                  padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                  onPressed: () {
                    showDialog(context: context, builder: (_) => AlertDialog(
                      title: const Text('Delete Technician'),
                      content: Text('Remove ${tech.name}?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                          onPressed: () { tp.delete(tech.id); Navigator.pop(context); },
                          child: const Text('Delete'),
                        ),
                      ],
                    ));
                  },
                  padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                ),
              ]),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.phone_outlined, size: 12, color: AppColors.gray400),
              const SizedBox(width: 4),
              Text(tech.phone, style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 12, color: AppColors.gray400),
              const SizedBox(width: 4),
              Expanded(child: Text(tech.districts.take(2).join(', '), style: const TextStyle(fontSize: 11, color: AppColors.gray500), overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 8),
            Wrap(spacing: 4, runSpacing: 4, children: [
              ...tech.skills.take(3).map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.indigo50, borderRadius: BorderRadius.circular(50)),
                child: Text(s, style: const TextStyle(fontSize: 10, color: AppColors.primary)),
              )),
              if (tech.skills.length > 3) Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(50)),
                child: Text('+${tech.skills.length - 3}', style: const TextStyle(fontSize: 10, color: AppColors.gray500)),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.engineering, size: 64, color: AppColors.gray200),
      SizedBox(height: 16),
      Text('Select a technician to view details', style: TextStyle(color: AppColors.gray500)),
    ]),
  );
}

class _TechDetail extends StatelessWidget {
  final Technician tech;
  const _TechDetail({required this.tech});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            TechnicianAvatar(name: tech.name, size: 64, status: tech.status),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tech.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              Row(children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < tech.rating.round() ? const Color(0xFFF59E0B) : AppColors.gray200))),
              Text('Joined ${tech.joinDate.year}', style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
            ])),
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () => showModalBottomSheet(
                context: context, isScrollControlled: true,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (_) => TechnicianFormSheet(technician: tech),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          // Stats
          Row(children: [
            Expanded(child: _stat('${tech.completedJobs}', 'Total Jobs', AppColors.indigo50, AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: _stat('${tech.activeJobs}', 'Active Jobs', AppColors.blue50, AppColors.secondary)),
            const SizedBox(width: 12),
            Expanded(child: _stat('${tech.rating}', 'Rating', const Color(0xFFFFFBEB), const Color(0xFFF59E0B))),
          ]),
          const SizedBox(height: 20),
          // Contact
          const Text('Contact', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _row(Icons.phone_outlined, tech.phone),
          _row(Icons.email_outlined, tech.email),
          const SizedBox(height: 16),
          // Skills
          const Text('Skills', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: tech.skills.map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.indigo50, borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AppColors.indigo200)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.build_outlined, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(s, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
            ]),
          )).toList()),
          const SizedBox(height: 16),
          // Districts
          const Text('Coverage Districts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: tech.districts.map((d) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(50)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.location_on_outlined, size: 12, color: AppColors.green600),
              const SizedBox(width: 4),
              Text(d, style: const TextStyle(fontSize: 12, color: AppColors.green600)),
            ]),
          )).toList()),
          const SizedBox(height: 16),
          // Availability
          const Text('Availability', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...tech.availability.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              SizedBox(width: 100, child: Text(a.day, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
              Expanded(child: Wrap(spacing: 6, children: a.slots.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(6)),
                child: Text(s, style: const TextStyle(fontSize: 11, color: AppColors.gray600)),
              )).toList())),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color bg, Color fg) => Container(
    padding: const EdgeInsets.all(16), alignment: Alignment.center,
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: fg)),
      Text(label, style: TextStyle(fontSize: 11, color: fg)),
    ]),
  );

  Widget _row(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Icon(icon, size: 14, color: AppColors.gray400),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
    ]),
  );
}

class TechnicianFormSheet extends StatefulWidget {
  final Technician? technician;
  const TechnicianFormSheet({super.key, this.technician});
  @override
  State<TechnicianFormSheet> createState() => _TechnicianFormSheetState();
}

class _TechnicianFormSheetState extends State<TechnicianFormSheet> {
  late TextEditingController _name, _phone, _email;
  late List<String> _selectedSkills, _selectedDistricts;
  late TechnicianStatus _status;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.technician?.name ?? '');
    _phone = TextEditingController(text: widget.technician?.phone ?? '');
    _email = TextEditingController(text: widget.technician?.email ?? '');
    _selectedSkills = List.from(widget.technician?.skills ?? []);
    _selectedDistricts = List.from(widget.technician?.districts ?? []);
    _status = widget.technician?.status ?? TechnicianStatus.available;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.technician != null;
    return DraggableScrollableSheet(
      initialChildSize: 0.9, maxChildSize: 0.95, minChildSize: 0.5,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.gray100))),
            child: Row(children: [
              Expanded(child: Text(isEdit ? 'Edit Technician' : 'Add New Technician',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          Expanded(child: ListView(controller: ctrl, padding: const EdgeInsets.all(20), children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Full Name *')),
            const SizedBox(height: 16),
            TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 16),
            TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            DropdownButtonFormField<TechnicianStatus>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: TechnicianStatus.values.map((s) => DropdownMenuItem(
                value: s,
                child: Text(s.name[0].toUpperCase() + s.name.substring(1)),
              )).toList(),
              onChanged: (v) { if (v != null) setState(() => _status = v); },
            ),
            const SizedBox(height: 20),
            const Text('Skills', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _allSkills.map((s) {
              final selected = _selectedSkills.contains(s);
              return GestureDetector(
                onTap: () => setState(() { if (selected) _selectedSkills.remove(s); else _selectedSkills.add(s); }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: selected ? AppColors.primary : AppColors.gray300),
                  ),
                  child: Text(s, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.gray600, fontWeight: FontWeight.w500)),
                ),
              );
            }).toList()),
            const SizedBox(height: 20),
            const Text('Districts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _allDistricts.map((d) {
              final selected = _selectedDistricts.contains(d);
              return GestureDetector(
                onTap: () => setState(() { if (selected) _selectedDistricts.remove(d); else _selectedDistricts.add(d); }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.success : Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: selected ? AppColors.success : AppColors.gray300),
                  ),
                  child: Text(d, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.gray600, fontWeight: FontWeight.w500)),
                ),
              );
            }).toList()),
            const SizedBox(height: 80),
          ])),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.gray100))),
            child: Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: _name.text.trim().isEmpty ? null : () {
                  final tp = context.read<TechniciansProvider>();
                  if (isEdit) {
                    tp.update(widget.technician!.id, name: _name.text, phone: _phone.text, email: _email.text,
                      skills: _selectedSkills, districts: _selectedDistricts, status: _status);
                  } else {
                    tp.add(Technician(
                      id: 'tech_${DateTime.now().millisecondsSinceEpoch}',
                      name: _name.text, phone: _phone.text, email: _email.text,
                      skills: _selectedSkills, districts: _selectedDistricts,
                      status: _status, rating: 5.0, completedJobs: 0, activeJobs: 0,
                      availability: [], joinDate: DateTime.now(),
                    ));
                  }
                  Navigator.pop(context);
                },
                child: Text(isEdit ? 'Save Changes' : 'Add Technician'),
              )),
            ]),
          ),
        ],
      ),
    );
  }
}
