import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UsersProvider extends ChangeNotifier {
  List<UserModel> _users = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = true;

  UsersProvider() {
    _listenToUsers();
  }

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;

  void _listenToUsers() {
    // Listening to 'users_id' collection which stores registered customers
    _db.collection('users_id').snapshots().listen((snapshot) {
      _users = snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection('users_id').doc(user.id).update(user.toMap());
  }

  Future<void> deleteUser(String id) async {
    await _db.collection('users_id').doc(id).delete();
  }

  UserModel? getById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }
}
