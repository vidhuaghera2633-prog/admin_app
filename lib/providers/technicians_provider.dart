import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/technician.dart';
import '../data/mock_data.dart';

class TechniciansProvider extends ChangeNotifier {
  List<Technician> _technicians = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = true;

  TechniciansProvider() {
    _listenToTechnicians();
  }

  List<Technician> get technicians => _technicians;
  bool get isLoading => _isLoading;

  void _listenToTechnicians() {
    _db.collection('technicians').snapshots().listen((snapshot) async {
      if (snapshot.docs.isEmpty) {
        await _seedMockData();
      } else {
        _technicians = snapshot.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          if (data['id'] == null || data['id'].toString().isEmpty) {
            data['id'] = doc.id;
          }
          return Technician.fromMap(data);
        }).toList();
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _seedMockData() async {
    for (var tech in MockData.technicians) {
      await _db.collection('technicians').doc(tech.id).set(tech.toMap());
    }
  }

  Technician? getById(String id) {
    try {
      return _technicians.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(Technician tech) async {
    await _db.collection('technicians').doc(tech.id).set(tech.toMap());
  }

  Future<void> update(String id, {String? name, String? phone, String? email, List<String>? skills, List<String>? districts, TechnicianStatus? status}) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (email != null) updates['email'] = email;
    if (skills != null) updates['skills'] = skills;
    if (districts != null) updates['districts'] = districts;
    if (status != null) updates['status'] = status.name;

    if (updates.isNotEmpty) {
      await _db.collection('technicians').doc(id).update(updates);
    }
  }

  Future<void> delete(String id) async {
    await _db.collection('technicians').doc(id).delete();
  }

  void cycleStatus(String id) {
    final tech = getById(id);
    if (tech != null) {
      final nextStatus = {
        TechnicianStatus.available: TechnicianStatus.busy,
        TechnicianStatus.busy: TechnicianStatus.offline,
        TechnicianStatus.offline: TechnicianStatus.available,
      };
      update(id, status: nextStatus[tech.status]);
    }
  }
}
