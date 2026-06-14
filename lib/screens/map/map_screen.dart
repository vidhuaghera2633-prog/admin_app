import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/technician.dart';
import '../../providers/map_provider.dart';
import '../../providers/technicians_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../layout/header_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  bool _mapCreated = false;
  bool _showApiKeyWarning = false;

  // Oman center
  static const _initialCamera = CameraPosition(
    target: LatLng(23.5880, 58.3829),
    zoom: 8.5,
  );

  @override
  void initState() {
    super.initState();
    // Show API key warning on Android after a delay if map doesn't load
    if (!kIsWeb) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && !_mapCreated) {
          setState(() => _showApiKeyWarning = true);
        }
      });
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w >= 900;

    return Column(
      children: [
        const HeaderBar(
          title: 'Live Map',
          subtitle: 'Real-time technician & customer locations',
        ),
        Expanded(
          child: isWide
              ? Row(children: [
                  Expanded(flex: 3, child: _buildMap()),
                  const VerticalDivider(width: 1, color: AppColors.gray100),
                  SizedBox(width: 320, child: _buildSidePanel()),
                ])
              : Column(children: [
                  Expanded(flex: 2, child: _buildMap()),
                  const Divider(height: 1, color: AppColors.gray100),
                  Expanded(child: _buildSidePanel()),
                ]),
        ),
      ],
    );
  }

  // ─── Map ────────────────────────────────────────────────────────────────────

  Widget _buildMap() {
    return Consumer<MapProvider>(
      builder: (context, map, _) {
        if (map.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final markers = <Marker>{};

        // Technician markers
        for (final tl in map.techLocations) {
          final isSelected = map.selectedTechId == tl.technicianId;
          markers.add(Marker(
            markerId: MarkerId('tech_${tl.technicianId}'),
            position: tl.position,
            icon: isSelected
                ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
                : _techHue(tl.technicianId),
            infoWindow: InfoWindow(
              title: tl.name,
              snippet: _statusLabel(tl.status),
            ),
            onTap: () {
              map.selectTechnician(tl.technicianId);
              _animateTo(tl.position);
            },
            zIndex: isSelected ? 2 : 1,
          ));
        }

        // Customer markers
        for (final cl in map.customerLocations) {
          final isSelected = map.selectedCustomerId == cl.complaintId;
          markers.add(Marker(
            markerId: MarkerId('cust_${cl.complaintId}'),
            position: cl.position,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                isSelected ? BitmapDescriptor.hueGreen : _priorityHue(cl.priority)),
            infoWindow: InfoWindow(
              title: cl.customerName,
              snippet: cl.issue,
            ),
            onTap: () {
              map.selectCustomer(cl.complaintId);
              _animateTo(cl.position);
            },
            zIndex: isSelected ? 2 : 0,
          ));
        }

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _initialCamera,
              markers: markers,
              polylines: map.routes,
              onMapCreated: (c) {
                _mapController = c;
                setState(() => _mapCreated = true);
                debugPrint('GoogleMap created with ${markers.length} markers');
              },
              onTap: (_) {
                map.selectTechnician(null);
                map.selectCustomer(null);
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              // Ensure map renders on mobile
              compassEnabled: true,
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: true,
              zoomGesturesEnabled: true,
            ),

            // API Key Warning Overlay (Android)
            if (_showApiKeyWarning && !kIsWeb)
              Positioned.fill(
                child: Container(
                  color: AppColors.background,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 48, color: AppColors.warning),
                          const SizedBox(height: 16),
                          const Text(
                            'Google Maps API Key Required',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'To display the map on Android, add your Google Maps API key to:',
                            style: TextStyle(fontSize: 13, color: AppColors.gray600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.gray50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'android/local.properties',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '1. Get API key from Google Cloud Console\n'
                            '2. Enable "Maps SDK for Android"\n'
                            '3. Add: MAPS_API_KEY=your_key_here',
                            style: TextStyle(fontSize: 12, color: AppColors.gray600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => setState(() => _showApiKeyWarning = false),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Dismiss'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gray100,
                              foregroundColor: AppColors.gray700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Top controls
            Positioned(
              top: 12, left: 12, right: 12,
              child: _MapControls(),
            ),

            // Bottom legend
            Positioned(
              bottom: 16, left: 12,
              child: _MapLegend(),
            ),

            // Zoom controls
            Positioned(
              bottom: 80, right: 12,
              child: _ZoomControls(controller: _mapController),
            ),

            // Fit all button
            Positioned(
              bottom: 16, right: 12,
              child: FloatingActionButton.small(
                heroTag: 'fit_all',
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                onPressed: _fitAll,
                tooltip: 'Fit all markers',
                child: const Icon(Icons.fit_screen_outlined, size: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  void _animateTo(LatLng pos) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: pos, zoom: 13),
      ),
    );
  }

  void _fitAll() {
    final map = context.read<MapProvider>();
    if (map.techLocations.isEmpty && map.customerLocations.isEmpty) return;

    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final t in map.techLocations) {
      minLat = minLat < t.position.latitude ? minLat : t.position.latitude;
      maxLat = maxLat > t.position.latitude ? maxLat : t.position.latitude;
      minLng = minLng < t.position.longitude ? minLng : t.position.longitude;
      maxLng = maxLng > t.position.longitude ? maxLng : t.position.longitude;
    }
    for (final c in map.customerLocations) {
      minLat = minLat < c.position.latitude ? minLat : c.position.latitude;
      maxLat = maxLat > c.position.latitude ? maxLat : c.position.latitude;
      minLng = minLng < c.position.longitude ? minLng : c.position.longitude;
      maxLng = maxLng > c.position.longitude ? maxLng : c.position.longitude;
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.1, minLng - 0.1),
          northeast: LatLng(maxLat + 0.1, maxLng + 0.1),
        ),
        60,
      ),
    );
  }

  BitmapDescriptor _techHue(String id) {
    const hues = {
      't1': BitmapDescriptor.hueViolet,
      't2': BitmapDescriptor.hueGreen,
      't3': BitmapDescriptor.hueAzure,
      't4': BitmapDescriptor.hueYellow,
      't5': BitmapDescriptor.hueMagenta,
    };
    return BitmapDescriptor.defaultMarkerWithHue(hues[id] ?? BitmapDescriptor.hueRed);
  }

  double _priorityHue(String priority) {
    return switch (priority) {
      'critical' => BitmapDescriptor.hueRed,
      'high'     => BitmapDescriptor.hueOrange,
      'medium'   => BitmapDescriptor.hueYellow,
      _          => BitmapDescriptor.hueCyan,
    };
  }

  String _statusLabel(TechnicianStatus s) => switch (s) {
    TechnicianStatus.available => '🟢 Available',
    TechnicianStatus.busy      => '🟡 Busy',
    TechnicianStatus.offline   => '⚫ Offline',
  };

  // ─── Side Panel ─────────────────────────────────────────────────────────────

  Widget _buildSidePanel() {
    return Consumer<MapProvider>(
      builder: (context, map, _) {
        // Show detail if something selected
        if (map.selectedTechId != null && map.selectedTech != null) {
          return _TechDetail(tl: map.selectedTech!, onClose: () => map.selectTechnician(null), map: map);
        }
        if (map.selectedCustomerId != null && map.selectedCustomer != null) {
          return _CustomerDetail(cl: map.selectedCustomer!, onClose: () => map.selectCustomer(null));
        }
        return _PanelList(map: map, onTapTech: (id) {
          map.selectTechnician(id);
          final tl = map.techLocations.where((t) => t.technicianId == id).firstOrNull;
          if (tl != null) _animateTo(tl.position);
        }, onTapCustomer: (id) {
          map.selectCustomer(id);
          final cl = map.customerLocations.where((c) => c.complaintId == id).firstOrNull;
          if (cl != null) _animateTo(cl.position);
        });
      },
    );
  }
}

// ─── Map Controls (toggle routes / clusters) ─────────────────────────────────

class _MapControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, map, _) => Row(
        children: [
          _chip(
            icon: Icons.route_outlined,
            label: 'Routes',
            active: map.showRoutes,
            onTap: map.toggleRoutes,
          ),
          const SizedBox(width: 8),
          _chip(
            icon: Icons.layers_outlined,
            label: 'Clusters',
            active: map.showClusters,
            onTap: map.toggleClusters,
          ),
          const Spacer(),
          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
            ),
            child: Row(children: [
              _PulsingDot(),
              const SizedBox(width: 6),
              const Text('Live', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _chip({required IconData icon, required String label, required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: active ? Colors.white : AppColors.gray500),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.gray600)),
        ]),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
  );
}

// ─── Map Legend ───────────────────────────────────────────────────────────────

class _MapLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Legend', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gray700)),
        const SizedBox(height: 6),
        _row(Icons.person_pin_circle, AppColors.primary, 'Technician'),
        _row(Icons.location_pin, AppColors.danger, 'Customer (Critical)'),
        _row(Icons.location_pin, AppColors.orange500, 'Customer (High)'),
        _row(Icons.location_pin, AppColors.warning, 'Customer (Medium/Low)'),
        _row(Icons.route, AppColors.primary.withOpacity(0.6), 'Route'),
      ]),
    );
  }

  Widget _row(IconData icon, Color color, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Row(children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.gray600)),
    ]),
  );
}

// ─── Zoom Controls ────────────────────────────────────────────────────────────

class _ZoomControls extends StatelessWidget {
  final GoogleMapController? controller;
  const _ZoomControls({this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _btn(Icons.add, () => controller?.animateCamera(CameraUpdate.zoomIn())),
      const SizedBox(height: 4),
      _btn(Icons.remove, () => controller?.animateCamera(CameraUpdate.zoomOut())),
    ]);
  }

  Widget _btn(IconData icon, VoidCallback onTap) => Material(
    elevation: 2, borderRadius: BorderRadius.circular(8), color: Colors.white,
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: SizedBox(width: 36, height: 36, child: Icon(icon, size: 18, color: AppColors.gray700)),
    ),
  );
}

// ─── Side Panel List ──────────────────────────────────────────────────────────

class _PanelList extends StatefulWidget {
  final MapProvider map;
  final ValueChanged<String> onTapTech;
  final ValueChanged<String> onTapCustomer;
  const _PanelList({required this.map, required this.onTapTech, required this.onTapCustomer});

  @override
  State<_PanelList> createState() => _PanelListState();
}

class _PanelListState extends State<_PanelList> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final techs = context.watch<TechniciansProvider>().technicians;
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tab,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.gray500,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Technicians (${widget.map.techLocations.length})'),
              Tab(text: 'Customers (${widget.map.customerLocations.length})'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              // Technicians list
              ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: widget.map.techLocations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final tl = widget.map.techLocations[i];
                  final tech = techs.where((t) => t.id == tl.technicianId).firstOrNull;
                  final color = widget.map.techColor(tl.technicianId);
                  return _TechCard(
                    tl: tl, tech: tech, color: color,
                    onTap: () => widget.onTapTech(tl.technicianId),
                  );
                },
              ),
              // Customers list
              ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: widget.map.customerLocations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final cl = widget.map.customerLocations[i];
                  return _CustomerCard(cl: cl, onTap: () => widget.onTapCustomer(cl.complaintId));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Technician Card ──────────────────────────────────────────────────────────

class _TechCard extends StatelessWidget {
  final TechnicianLocation tl;
  final dynamic tech;
  final Color color;
  final VoidCallback onTap;
  const _TechCard({required this.tl, required this.tech, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            Stack(children: [
              TechnicianAvatar(name: tl.name, size: 40, status: tl.status),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                ),
              ),
            ]),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tl.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray900)),
              const SizedBox(height: 2),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 11, color: AppColors.gray400),
                const SizedBox(width: 2),
                Text(
                  '${tl.position.latitude.toStringAsFixed(4)}, ${tl.position.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 10, color: AppColors.gray500),
                ),
              ]),
            ])),
            const SizedBox(width: 8),
            _statusChip(tl.status),
          ]),
        ),
      ),
    );
  }

  Widget _statusChip(TechnicianStatus s) {
    final (Color bg, Color fg, String label) = switch (s) {
      TechnicianStatus.available => (AppColors.green50, AppColors.green600, 'Available'),
      TechnicianStatus.busy      => (AppColors.amber50, AppColors.amber600, 'Busy'),
      TechnicianStatus.offline   => (AppColors.gray100, AppColors.gray500, 'Offline'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(50)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ─── Customer Card ────────────────────────────────────────────────────────────

class _CustomerCard extends StatelessWidget {
  final CustomerLocation cl;
  final VoidCallback onTap;
  const _CustomerCard({required this.cl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final priorityColor = switch (cl.priority) {
      'critical' => AppColors.danger,
      'high'     => AppColors.orange500,
      'medium'   => AppColors.warning,
      _          => AppColors.gray400,
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: priorityColor.withOpacity(0.3)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: priorityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.location_pin, color: priorityColor, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cl.customerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(cl.issue, style: const TextStyle(fontSize: 11, color: AppColors.gray500), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(cl.ticketNo, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ])),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: priorityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(50)),
                child: Text(cl.priority[0].toUpperCase() + cl.priority.substring(1),
                    style: TextStyle(fontSize: 10, color: priorityColor, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 4),
              Text(cl.district, style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ─── Technician Detail Panel ──────────────────────────────────────────────────

class _TechDetail extends StatelessWidget {
  final TechnicianLocation tl;
  final VoidCallback onClose;
  final MapProvider map;
  const _TechDetail({required this.tl, required this.onClose, required this.map});

  @override
  Widget build(BuildContext context) {
    final tech = context.read<TechniciansProvider>().technicians
        .where((t) => t.id == tl.technicianId).firstOrNull;
    final color = map.techColor(tl.technicianId);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              border: Border(bottom: BorderSide(color: color.withOpacity(0.2))),
            ),
            child: Row(children: [
              TechnicianAvatar(name: tl.name, size: 44, status: tl.status),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tl.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text(tech?.skills.take(2).join(', ') ?? '', style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
              ])),
              IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onClose, padding: EdgeInsets.zero),
            ]),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Live location
                _section('Live Location', Icons.my_location, color),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(10)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _infoRow(Icons.location_on_outlined, 'Coordinates',
                        '${tl.position.latitude.toStringAsFixed(5)}, ${tl.position.longitude.toStringAsFixed(5)}'),
                    const SizedBox(height: 8),
                    _infoRow(Icons.navigation_outlined, 'Heading', '${tl.heading.toStringAsFixed(0)}°'),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.circle, size: 8, color: AppColors.success),
                      const SizedBox(width: 6),
                      const Text('Updating every 3 seconds', style: TextStyle(fontSize: 11, color: AppColors.gray500)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),
                _section('Technician Info', Icons.engineering_outlined, color),
                const SizedBox(height: 8),
                if (tech != null) ...[
                  _infoRow(Icons.phone_outlined, 'Phone', tech.phone),
                  const SizedBox(height: 8),
                  _infoRow(Icons.star_outlined, 'Rating', '${tech.rating} ⭐'),
                  const SizedBox(height: 8),
                  _infoRow(Icons.work_outline, 'Active Jobs', '${tech.activeJobs}'),
                  const SizedBox(height: 8),
                  _infoRow(Icons.map_outlined, 'Districts', tech.districts.join(', ')),
                  const SizedBox(height: 12),
                  Wrap(spacing: 6, runSpacing: 6, children: tech.skills.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(s, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                  )).toList()),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, IconData icon, Color color) => Row(children: [
    Icon(icon, size: 15, color: color),
    const SizedBox(width: 6),
    Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
  ]);

  Widget _infoRow(IconData icon, String label, String value) => Row(children: [
    Icon(icon, size: 14, color: AppColors.gray400),
    const SizedBox(width: 8),
    SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray500))),
    Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
  ]);
}

// ─── Customer Detail Panel ────────────────────────────────────────────────────

class _CustomerDetail extends StatelessWidget {
  final CustomerLocation cl;
  final VoidCallback onClose;
  const _CustomerDetail({required this.cl, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final priorityColor = switch (cl.priority) {
      'critical' => AppColors.danger,
      'high'     => AppColors.orange500,
      'medium'   => AppColors.warning,
      _          => AppColors.gray400,
    };

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.07),
              border: Border(bottom: BorderSide(color: priorityColor.withOpacity(0.2))),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: priorityColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.location_pin, color: priorityColor, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(cl.customerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text(cl.ticketNo, style: TextStyle(fontSize: 12, color: priorityColor, fontWeight: FontWeight.w600)),
              ])),
              IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onClose, padding: EdgeInsets.zero),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _section('Location', Icons.location_on_outlined, priorityColor),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(10)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _infoRow(Icons.map_outlined, 'District', cl.district),
                    const SizedBox(height: 8),
                    _infoRow(Icons.my_location, 'Coordinates',
                        '${cl.position.latitude.toStringAsFixed(5)}, ${cl.position.longitude.toStringAsFixed(5)}'),
                  ]),
                ),
                const SizedBox(height: 16),
                _section('Complaint', Icons.build_circle_outlined, priorityColor),
                const SizedBox(height: 8),
                _infoRow(Icons.report_outlined, 'Issue', cl.issue),
                const SizedBox(height: 8),
                _infoRow(Icons.flag_outlined, 'Priority', cl.priority[0].toUpperCase() + cl.priority.substring(1)),
                const SizedBox(height: 8),
                _infoRow(Icons.info_outline, 'Status', cl.status[0].toUpperCase() + cl.status.substring(1)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, IconData icon, Color color) => Row(children: [
    Icon(icon, size: 15, color: color),
    const SizedBox(width: 6),
    Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
  ]);

  Widget _infoRow(IconData icon, String label, String value) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 14, color: AppColors.gray400),
    const SizedBox(width: 8),
    SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray500))),
    Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
  ]);
}