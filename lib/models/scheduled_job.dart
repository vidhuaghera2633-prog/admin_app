class ScheduledJob {
  final String id, technicianId, complaintId;
  final String date, time;
  final double duration;
  final String customer, district, issue;

  ScheduledJob({
    required this.id, required this.technicianId, required this.complaintId,
    required this.date, required this.time, required this.duration,
    required this.customer, required this.district, required this.issue,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'technicianId': technicianId,
    'complaintId': complaintId,
    'date': date,
    'time': time,
    'duration': duration,
    'customer': customer,
    'district': district,
    'issue': issue,
  };

  factory ScheduledJob.fromMap(Map<String, dynamic> map) => ScheduledJob(
    id: map['id'] ?? '',
    technicianId: map['technicianId'] ?? '',
    complaintId: map['complaintId'] ?? '',
    date: map['date'] ?? '',
    time: map['time'] ?? '',
    duration: (map['duration'] ?? 0.0).toDouble(),
    customer: map['customer'] ?? '',
    district: map['district'] ?? '',
    issue: map['issue'] ?? '',
  );
}
