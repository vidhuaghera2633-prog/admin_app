import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scheduled_job.dart';
import '../data/mock_data.dart';

class ScheduledJobsProvider extends ChangeNotifier {
  List<ScheduledJob> _jobs = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = true;

  ScheduledJobsProvider() {
    _listenToJobs();
  }

  List<ScheduledJob> get jobs => _jobs;
  bool get isLoading => _isLoading;

  void _listenToJobs() {
    _db.collection('scheduled_jobs').snapshots().listen((snapshot) async {
      if (snapshot.docs.isEmpty) {
        await _seedMockData();
      } else {
        _jobs = snapshot.docs.map((doc) => ScheduledJob.fromMap(doc.data())).toList();
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _seedMockData() async {
    for (var job in MockData.scheduledJobs) {
      await _db.collection('scheduled_jobs').doc(job.id).set(job.toMap());
    }
  }

  Future<void> addJob(ScheduledJob job) async {
    await _db.collection('scheduled_jobs').doc(job.id).set(job.toMap());
  }

  Future<void> deleteJob(String id) async {
    await _db.collection('scheduled_jobs').doc(id).delete();
  }
}
