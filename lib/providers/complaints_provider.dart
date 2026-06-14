import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../core/utils/js_helper.dart' as js_helper;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../models/complaint.dart';
import '../data/mock_data.dart';
import '../router.dart';
import '../widgets/overlay_notification.dart';


class ComplaintsProvider extends ChangeNotifier {
  List<Complaint> _complaints = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = true;
  final Set<String> _unreadComplaintIds = {};
  final Map<String, int> _lastMessageCounts = {};

  ComplaintsProvider() {
    _listenToComplaints();
    if (kIsWeb) {
      js_helper.requestNotificationPermission();
    }
  }

  Set<String> get unreadComplaintIds => _unreadComplaintIds;
  int get unreadCount => _unreadComplaintIds.length;

  void markAllAsRead() {
    _unreadComplaintIds.clear();
    notifyListeners();
  }

  void markAsRead(String id) {
    if (_unreadComplaintIds.remove(id)) {
      notifyListeners();
    }
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

          for (var nc in newComplaints) {
            final previousMessageCount = _lastMessageCounts[nc.id];
            final currentMessageCount = nc.messages.length;
            final hasNewCustomerMessage = previousMessageCount != null &&
                currentMessageCount > previousMessageCount &&
                nc.messages.isNotEmpty &&
                nc.messages.last.senderRole != 'admin';

            if (hasNewCustomerMessage) {
              _showCustomerChatNotification(nc, nc.messages.last);
            }
          }
        }

        _complaints = newComplaints;
        for (final complaint in newComplaints) {
          _lastMessageCounts[complaint.id] = complaint.messages.length;
        }
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _playChime() {
    if (kIsWeb) {
      js_helper.playNotificationSound();
    }
  }

  void _showNewComplaintNotification(Complaint complaint) {
    _unreadComplaintIds.add(complaint.id);
    _playChime();
    notifyListeners();

    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    OverlayNotification.show(
      context: context,
      complaint: complaint,
      onView: () {
        markAsRead(complaint.id);
        GoRouter.of(context).go('/app/complaints/${complaint.id}');
      },
    );

    // Also show a browser native notification when running on web
    if (kIsWeb) {
      js_helper.showBrowserNotification(
        'New complaint: ${complaint.ticketNo.isEmpty ? complaint.issue : complaint.ticketNo}',
        complaint.issue,
        '/app/complaints/${complaint.id}',
      );
    }
  }

  void _showCustomerChatNotification(Complaint complaint, ComplaintMessage message) {
    _unreadComplaintIds.add(complaint.id);
    _playChime();
    notifyListeners();

    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      OverlayNotification.show(
        context: context,
        complaint: complaint,
        onView: () {
          markAsRead(complaint.id);
          GoRouter.of(context).go('/app/complaints/${complaint.id}');
        },
      );
    }

    if (kIsWeb) {
      js_helper.showBrowserNotification(
        'New customer message: ${complaint.ticketNo.isEmpty ? complaint.issue : complaint.ticketNo}',
        message.message,
        '/app/complaints/${complaint.id}',
      );
    }
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
        'status': ComplaintStatus.rejected.name,
        'updatedAt': Timestamp.now(),
        'notes': updatedNotes,
        'messages': FieldValue.arrayUnion([newMessage.toMap()]),
        'logs': updatedLogs.map((l) => l.toMap()).toList(),
      });

      // Mark as unread for admin UI and play notification
      _unreadComplaintIds.add(id);
      _playChime();
      notifyListeners();

      // Show browser native notification if available
      if (kIsWeb) {
        js_helper.showBrowserNotification(
          'Complaint rejected: ${c.ticketNo.isEmpty ? c.issue : c.ticketNo}',
          'Reason: $reason',
          '/app/complaints/$id',
        );
      }
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
