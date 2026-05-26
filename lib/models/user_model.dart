import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id, name, email, phone, role;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'uid': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) => UserModel(
    id: docId,
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    phone: map['phone'] ?? '',
    role: map['role'] ?? 'user',
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role,
      createdAt: createdAt,
    );
  }
}
