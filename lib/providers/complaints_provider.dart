import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../models/complaint.dart';
import '../data/mock_data.dart';
import '../router.dart';
import '../theme/app_theme.dart';

class ComplaintsProvider extends ChangeNotifier {
  List<Complaint> _complaints = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = true;

  ComplaintsProvider() {
    _listenToComplaints();
  }

  List<Complaint> get complaints => _complaints;
  bool get isLoading => _isLoading;

  void _listenToComplaints() {
    _db.collection('complaints').snapshots().listen((snapshot) async {
      if (snapshot.docs.isEmpty) {
        // Optional: Seed mock data if collection is empty
        await _seedMockData();
      } else {
        final newComplaints = snapshot.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          // Ensure the document ID is always set in the model
          if (data['id'] == null || data['id'].toString().isEmpty) {
            data['id'] = doc.id;
          }
          return Complaint.fromMap(data);
        }).toList();

        if (!_isLoading) {
          final existingIds = _complaints.map((c) => c.id).toSet();
          for (var nc in newComplaints) {
            if (!existingIds.contains(nc.id)) {
              _showNewComplaintNotification(nc);
            }
          }
        }

        _complaints = newComplaints;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _showNewComplaintNotification(Complaint complaint) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 8),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.amber50.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active, color: AppColors.warning, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔔 New Complaint Arrived!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Ticket: ${complaint.ticketNo.isEmpty ? complaint.id.substring(0, 6) : complaint.ticketNo}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${complaint.customer.name} - ${complaint.issue}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  GoRouter.of(context).go('/app/complaints/${complaint.id}');
                },
                child: const Text('VIEW'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _seedMockData() async {
    for (var complaint in MockData.complaints) {
      await _db.collection('complaints').doc(complaint.id).set(complaint.toMap());
    }
  }

  Future<void> addComplaint(Complaint complaint) async {
    await _db.collection('complaints').doc(complaint.id).set(complaint.toMap());
  }

  Future<void> deleteComplaint(String id) async {
    await _db.collection('complaints').doc(id).delete();
  }

  Complaint? getById(String id) {
    try {
      return _complaints.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> accept(String id) async {
    final c = getById(id);
    if (c != null) {
      final updatedLogs = List<LogEntry>.from(c.logs)
        ..add(LogEntry(time: DateTime.now(), action: 'Complaint accepted', by: 'Admin'));
      
      await _db.collection('complaints').doc(id).update({
        'status': ComplaintStatus.active.name,
        'updatedAt': Timestamp.now(),
        'logs': updatedLogs.map((l) => l.toMap()).toList(),
      });
    }
  }

  Future<void> reject(String id, String reason) async {
    final c = getById(id);
    if (c != null) {
      final updatedNotes = List<String>.from(c.notes)..add('Rejection reason: $reason');
      
      final newMessage = ComplaintMessage(
        senderId: 'admin',
        senderName: 'Admin',
        message: 'Your complaint has been rejected. Reason: $reason',
        senderRole: 'admin',
        time: DateTime.now(),
      );

      final updatedLogs = List<LogEntry>.from(c.logs)
        ..add(LogEntry(time: DateTime.now(), action: 'Complaint rejected: $reason', by: 'Admin'));

      await _db.collection('complaints').doc(id).update({
        'status': 'Rejected', // Use capitalized to match Customer App expectation
        'updatedAt': Timestamp.now(),
        'notes': updatedNotes,
        'messages': FieldValue.arrayUnion([newMessage.toMap()]),
        'logs': updatedLogs.map((l) => l.toMap()).toList(),
      });
    }
  }

  Future<void> assign(String id, String techId) async {
    final c = getById(id);
    if (c != null) {
      final updatedLogs = List<LogEntry>.from(c.logs)
        ..add(LogEntry(time: DateTime.now(), action: 'Assigned to technician: $techId', by: 'Admin'));

      final updates = {
        'assignedTechnicianId': techId,
        'updatedAt': Timestamp.now(),
        'logs': updatedLogs.map((l) => l.toMap()).toList(),
      };

      // If assigning, also set to active if it was pending
      if (c.status == ComplaintStatus.pending) {
        updates['status'] = ComplaintStatus.active.name;
      }

      final batch = _db.batch();

      // 1. Update the complaint document
      batch.update(_db.collection('complaints').doc(id), updates);

      // 2. Create a notification record for the technician app to listen to
      final notificationId = 'notif_${DateTime.now().millisecondsSinceEpoch}';
      batch.set(_db.collection('notifications').doc(notificationId), {
        'id': notificationId,
        'recipientId': techId,
        'type': 'new_assignment',
        'title': 'New Complaint Assigned',
        'body': 'You have been assigned a new complaint: ${c.ticketNo}',
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'data': {
          'complaintId': id,
          'ticketNo': c.ticketNo,
        },
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Update the technician's record: increment active jobs and set status to busy
      batch.update(_db.collection('technicians').doc(techId), {
        'activeJobs': FieldValue.increment(1),
        'status': 'busy',
      });

      await batch.commit();
    }
  }

  Future<void> addNote(String id, String note) async {
    final c = getById(id);
    if (c != null) {
      final updatedNotes = List<String>.from(c.notes)..add(note);
      final updatedLogs = List<LogEntry>.from(c.logs)
        ..add(LogEntry(time: DateTime.now(), action: 'Note added: $note', by: 'Admin'));

      await _db.collection('complaints').doc(id).update({
        'notes': updatedNotes,
        'updatedAt': Timestamp.now(),
        'logs': updatedLogs.map((l) => l.toMap()).toList(),
      });
    }
  }

  Future<void> addPart(String id, String part) async {
    final c = getById(id);
    if (c != null) {
      final updatedParts = List<String>.from(c.parts)..add(part);
      final updatedLogs = List<LogEntry>.from(c.logs)
        ..add(LogEntry(time: DateTime.now(), action: 'Part added: $part', by: 'Admin'));

      await _db.collection('complaints').doc(id).update({
        'parts': updatedParts,
        'updatedAt': Timestamp.now(),
        'logs': updatedLogs.map((l) => l.toMap()).toList(),
      });
    }
  }

  Future<void> updatePriority(String id, Priority priority) async {
    final c = getById(id);
    if (c != null) {
      final updatedLogs = List<LogEntry>.from(c.logs)
        ..add(LogEntry(time: DateTime.now(), action: 'Priority changed to ${priority.name}', by: 'Admin'));

      await _db.collection('complaints').doc(id).update({
        'priority': priority.name,
        'updatedAt': Timestamp.now(),
        'logs': updatedLogs.map((l) => l.toMap()).toList(),
      });
    }
  }

  Future<void> sendMessageToCustomer(String complaintId, String message, String senderId, String senderName, String senderRole) async {
    final newMessage = ComplaintMessage(
      senderId: senderId,
      senderName: senderName,
      message: message,
      senderRole: senderRole,
      time: DateTime.now(),
    );

    await _db.collection('complaints').doc(complaintId).update({
      'messages': FieldValue.arrayUnion([newMessage.toMap()]),
      'updatedAt': Timestamp.now(),
    });
  }
}
