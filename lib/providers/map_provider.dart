import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart' show StreamZip;
import '../models/technician.dart';
import '../models/complaint.dart';

class TechnicianLocation {
  final String technicianId;
  final String name;
  final LatLng position;
  final TechnicianStatus status;
  final double heading; // direction 0-360

  const TechnicianLocation({
    required this.technicianId,
    required this.name,
    required this.position,
    required this.status,
    this.heading = 0,
  });

  TechnicianLocation copyWith({LatLng? position, double? heading, TechnicianStatus? status}) {
    return TechnicianLocation(
      technicianId: technicianId,
      name: name,
      position: position ?? this.position,
      status: status ?? this.status,
      heading: heading ?? this.heading,
    );
  }
}

class CustomerLocation {
  final String complaintId;
  final String ticketNo;
  final String customerName;
  final LatLng position;
  final String issue;
  final String district;
  final String status;
  final String priority;

  const CustomerLocation({
    required this.complaintId,
    required this.ticketNo,
    required this.customerName,
    required this.position,
    required this.issue,
    required this.district,
    required this.status,
    required this.priority,
  });
}

class MapProvider extends ChangeNotifier {
  final _rand = Random();
  Timer? _simulationTimer;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Oman coordinates — center of each district
  static const Map<String, LatLng> _districtCoords = {
    'Muscat':  LatLng(23.5880, 58.3829),
    'Seeb':    LatLng(23.6830, 58.1890),
    'Barka':   LatLng(23.7040, 57.8880),
    'Sohar':   LatLng(24.3473, 56.7454),
    'Nizwa':   LatLng(22.9333, 57.5333),
    'Ibri':    LatLng(23.2253, 56.5156),
    'Sur':     LatLng(22.5654, 59.5289),
    'Salalah': LatLng(17.0151, 54.0924),
    'Rustaq':  LatLng(23.3917, 57.4269),
    'Nakhal':  LatLng(23.3680, 57.8380),
    'Qurum':   LatLng(23.5955, 58.3708),
  };

  // Technician starting positions
  static final Map<String, LatLng> _techStartPositions = {
    't1': const LatLng(23.6020, 58.2100),
    't2': const LatLng(22.9500, 57.5200),
    't3': const LatLng(23.7100, 57.8900),
    't4': const LatLng(24.3600, 56.7500),
    't5': const LatLng(23.5900, 58.3700),
  };

  List<TechnicianLocation> _techLocations = [];
  List<CustomerLocation> _customerLocations = [];
  List<Technician> _technicians = [];
  List<Complaint> _complaints = [];
  
  String? _selectedTechId;
  String? _selectedCustomerId;
  bool _showClusters = true;
  bool _showRoutes = true;
  Set<Polyline> _routes = {};
  bool _isLoading = true;

  List<TechnicianLocation> get techLocations => _techLocations;
  List<CustomerLocation> get customerLocations => _customerLocations;
  String? get selectedTechId => _selectedTechId;
  String? get selectedCustomerId => _selectedCustomerId;
  bool get showClusters => _showClusters;
  bool get showRoutes => _showRoutes;
  Set<Polyline> get routes => _routes;
  bool get isLoading => _isLoading;

  MapProvider() {
    _listenToData();
  }

  void _listenToData() {
    StreamZip([
      _db.collection('technicians').snapshots(),
      _db.collection('complaints').snapshots(),
    ]).listen((results) {
      final techSnapshot = results[0] as QuerySnapshot<Map<String, dynamic>>;
      final complaintSnapshot = results[1] as QuerySnapshot<Map<String, dynamic>>;

      _technicians = techSnapshot.docs.map((doc) => Technician.fromMap(doc.data())).toList();
      _complaints = complaintSnapshot.docs.map((doc) => Complaint.fromMap(doc.data())).toList();

      _updateLocations();
    });
  }

  void _updateLocations() {
    _techLocations = _technicians.map((t) {
      final existing = _techLocations.where((tl) => tl.technicianId == t.id).firstOrNull;
      if (existing != null) {
        return existing.copyWith(status: t.status);
      }
      
      final base = _techStartPositions[t.id] ??
          _districtCoords[t.districts.first] ??
          const LatLng(23.5880, 58.3829);
          
      return TechnicianLocation(
        technicianId: t.id,
        name: t.name,
        position: base,
        status: t.status,
        heading: _rand.nextDouble() * 360,
      );
    }).toList();

    _customerLocations = _complaints.map((c) {
      final base = _districtCoords[c.district] ??
          const LatLng(23.5880, 58.3829);
      
      final offset = LatLng(
        base.latitude + (_rand.nextDouble() - 0.5) * 0.04,
        base.longitude + (_rand.nextDouble() - 0.5) * 0.04,
      );
      
      return CustomerLocation(
        complaintId: c.id,
        ticketNo: c.ticketNo,
        customerName: c.customer.name,
        position: offset,
        issue: c.issue,
        district: c.district,
        status: c.status.name,
        priority: c.priority.name,
      );
    }).toList();

    _isLoading = false;
    _buildRoutes();
    notifyListeners();
    
    if (_simulationTimer == null) {
      _startSimulation();
    }
  }

  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      bool changed = false;
      _techLocations = _techLocations.map<TechnicianLocation>((tl) {
        final tech = _technicians.where((t) => t.id == tl.technicianId).firstOrNull;
        if (tech == null || tech.status == TechnicianStatus.offline) return tl;

        final speed = tech.status == TechnicianStatus.busy ? 0.0008 : 0.0003;
        final angle = (tl.heading + (_rand.nextDouble() - 0.5) * 30) % 360;
        final rad = angle * pi / 180;
        final newLat = tl.position.latitude + cos(rad) * speed;
        final newLng = tl.position.longitude + sin(rad) * speed;

        changed = true;
        return tl.copyWith(
          position: LatLng(newLat, newLng),
          heading: angle,
        );
      }).toList();

      if (changed) {
        _buildRoutes();
        notifyListeners();
      }
    });
  }

  void _buildRoutes() {
    if (!_showRoutes) { _routes = {}; return; }

    final polylines = <Polyline>{};
    // Note: scheduledJobs simulation simplified for now to use active complaints
    for (final complaint in _complaints.where((c) => c.status == ComplaintStatus.active && c.assignedTechnicianId != null)) {
      final techLoc = _techLocations.where((t) => t.technicianId == complaint.assignedTechnicianId).firstOrNull;
      final custLoc = _customerLocations.where((c) => c.complaintId == complaint.id).firstOrNull;
      if (techLoc == null || custLoc == null) continue;

      final color = _techColor(complaint.assignedTechnicianId!);
      polylines.add(Polyline(
        polylineId: PolylineId('route_${complaint.id}'),
        points: _buildRoutePoints(techLoc.position, custLoc.position),
        color: color.withOpacity(0.7),
        width: 3,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ));
    }
    _routes = polylines;
  }

  // Simulate a curved route with intermediate waypoints
  List<LatLng> _buildRoutePoints(LatLng from, LatLng to) {
    final points = <LatLng>[from];
    const steps = 8;
    for (int i = 1; i < steps; i++) {
      final t = i / steps;
      // Add slight curve using perpendicular offset
      final midLat = from.latitude + (to.latitude - from.latitude) * t;
      final midLng = from.longitude + (to.longitude - from.longitude) * t;
      final curve = sin(t * pi) * 0.005 * (_rand.nextDouble() - 0.5);
      points.add(LatLng(midLat + curve, midLng + curve));
    }
    points.add(to);
    return points;
  }

  Color _techColor(String techId) {
    const colors = {
      't1': Color(0xFF6366F1),
      't2': Color(0xFF22C55E),
      't3': Color(0xFF3B82F6),
      't4': Color(0xFFF59E0B),
      't5': Color(0xFF8B5CF6),
    };
    return colors[techId] ?? const Color(0xFF6366F1);
  }

  Color techColor(String techId) => _techColor(techId);

  void selectTechnician(String? id) {
    _selectedTechId = id;
    _selectedCustomerId = null;
    notifyListeners();
  }

  void selectCustomer(String? id) {
    _selectedCustomerId = id;
    _selectedTechId = null;
    notifyListeners();
  }

  void toggleClusters() {
    _showClusters = !_showClusters;
    notifyListeners();
  }

  void toggleRoutes() {
    _showRoutes = !_showRoutes;
    _buildRoutes();
    notifyListeners();
  }

  TechnicianLocation? get selectedTech =>
      _selectedTechId == null ? null
      : _techLocations.where((t) => t.technicianId == _selectedTechId).firstOrNull;

  CustomerLocation? get selectedCustomer =>
      _selectedCustomerId == null ? null
      : _customerLocations.where((c) => c.complaintId == _selectedCustomerId).firstOrNull;

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}