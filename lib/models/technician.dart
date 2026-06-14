import 'package:cloud_firestore/cloud_firestore.dart';

enum TechnicianStatus { available, busy, offline }

class AvailabilitySlot {
  final String day;
  final List<String> slots;
  AvailabilitySlot({required this.day, required this.slots});

  Map<String, dynamic> toMap() => {
    'day': day,
    'slots': slots,
  };

  factory AvailabilitySlot.fromMap(Map<String, dynamic> map) => AvailabilitySlot(
    day: map['day'] ?? '',
    slots: List<String>.from(map['slots'] ?? []),
  );
}

class Technician {
  final String id, name, phone, email;
  List<String> skills, districts;
  TechnicianStatus status;
  double rating;
  int completedJobs, activeJobs;
  List<AvailabilitySlot> availability;
  final DateTime joinDate;

  Technician({
    required this.id, required this.name, required this.phone, required this.email,
    required this.skills, required this.districts, required this.status,
    required this.rating, required this.completedJobs, required this.activeJobs,
    required this.availability, required this.joinDate,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'skills': skills,
    'districts': districts,
    'status': status.name,
    'rating': rating,
    'completedJobs': completedJobs,
    'activeJobs': activeJobs,
    'availability': availability.map((a) => a.toMap()).toList(),
    'joinDate': Timestamp.fromDate(joinDate),
  };

  factory Technician.fromMap(Map<String, dynamic> map) => Technician(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    phone: map['phone'] ?? '',
    email: map['email'] ?? '',
    skills: List<String>.from(map['skills'] ?? []),
    districts: List<String>.from(map['districts'] ?? []),
    status: TechnicianStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => TechnicianStatus.offline),
    rating: (map['rating'] ?? 0.0).toDouble(),
    completedJobs: map['completedJobs'] ?? 0,
    activeJobs: map['activeJobs'] ?? 0,
    availability: (map['availability'] as List?)?.map((a) => AvailabilitySlot.fromMap(a)).toList() ?? [],
    joinDate: (map['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  Technician copyWith({
    String? name, String? phone, String? email, List<String>? skills,
    List<String>? districts, TechnicianStatus? status,
  }) {
    return Technician(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      skills: skills ?? this.skills,
      districts: districts ?? this.districts,
      status: status ?? this.status,
      rating: rating,
      completedJobs: completedJobs,
      activeJobs: activeJobs,
      availability: availability,
      joinDate: joinDate,
    );
  }
}
