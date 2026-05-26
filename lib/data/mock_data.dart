import '../models/complaint.dart';
import '../models/technician.dart';
import '../models/scheduled_job.dart';

class MockData {
  static List<Complaint> complaints = [
    Complaint(
      id: 'c1', ticketNo: 'TKT-2024-001',
      customer: Customer(name: 'Rahul Sharma', phone: '+91 98765 43210', email: 'rahul.sharma@email.com'),
      device: Device(type: 'AC Unit', brand: 'Voltas', model: '123V CZT', serial: 'IN-AC-10001', purchaseDate: '2022-04-10', warrantyExpiry: '2025-04-10'),
      issue: 'AC not cooling', description: 'The AC is running but not cooling the room. Set at 18°C but still warm.',
      status: ComplaintStatus.pending, priority: Priority.high,
      district: 'Mumbai', address: 'Flat 12B, Andheri West, Mumbai',
      createdAt: DateTime(2024, 2, 15, 9, 30), updatedAt: DateTime(2024, 2, 15, 9, 30),
      logs: [
        LogEntry(time: DateTime(2024, 2, 15, 9, 30), action: 'Complaint submitted', by: 'Customer'),
        LogEntry(time: DateTime(2024, 2, 15, 9, 35), action: 'Ticket assigned to queue', by: 'System'),
      ],
    ),
    Complaint(
      id: 'c2', ticketNo: 'TKT-2024-002',
      customer: Customer(name: 'Priya Singh', phone: '+91 91234 56789', email: 'priya.singh@email.com'),
      device: Device(type: 'Refrigerator', brand: 'Godrej', model: 'Edge Pro', serial: 'IN-RF-20002', purchaseDate: '2021-06-15', warrantyExpiry: '2024-06-15'),
      issue: 'Not cooling properly', description: 'Refrigerator is not maintaining temperature. Food is spoiling.',
      status: ComplaintStatus.active, priority: Priority.critical,
      district: 'Delhi', address: 'House 45, Lajpat Nagar, Delhi',
      createdAt: DateTime(2024, 2, 14, 11, 0), updatedAt: DateTime(2024, 2, 15, 10, 0),
      assignedTechnicianId: 't1',
      parts: ['Compressor relay', 'Thermostat sensor'],
      notes: ['Customer prefers morning visits'],
      logs: [
        LogEntry(time: DateTime(2024, 2, 14, 11, 0), action: 'Complaint submitted', by: 'Customer'),
        LogEntry(time: DateTime(2024, 2, 14, 14, 0), action: 'Assigned to Amit Kumar', by: 'Admin'),
        LogEntry(time: DateTime(2024, 2, 15, 8, 0), action: 'Technician en route', by: 'Amit Kumar'),
      ],
    ),
    Complaint(
      id: 'c3', ticketNo: 'TKT-2024-003',
      customer: Customer(name: 'Sunita Patel', phone: '+91 99887 76655', email: 'sunita.patel@email.com'),
      device: Device(type: 'Washing Machine', brand: 'IFB', model: 'Senorita Aqua', serial: 'IN-WM-30003', purchaseDate: '2020-03-20', warrantyExpiry: '2023-03-20'),
      issue: 'Drum not spinning', description: 'Washing machine makes noise but drum does not spin.',
      status: ComplaintStatus.completed, priority: Priority.medium,
      district: 'Ahmedabad', address: 'B-22, Satellite, Ahmedabad',
      createdAt: DateTime(2024, 2, 10, 14, 0), updatedAt: DateTime(2024, 2, 12, 16, 0),
      assignedTechnicianId: 't2',
      parts: ['Drive belt', 'Motor pulley'],
      notes: ['Belt replaced, tested OK'],
      logs: [
        LogEntry(time: DateTime(2024, 2, 10, 14, 0), action: 'Complaint submitted', by: 'Customer'),
        LogEntry(time: DateTime(2024, 2, 11, 9, 0), action: 'Assigned to Rakesh Verma', by: 'Admin'),
        LogEntry(time: DateTime(2024, 2, 12, 10, 0), action: 'Diagnosis: Drive belt broken', by: 'Rakesh Verma'),
        LogEntry(time: DateTime(2024, 2, 12, 16, 0), action: 'Repair completed successfully', by: 'Rakesh Verma'),
      ],
    ),
    Complaint(
      id: 'c4', ticketNo: 'TKT-2024-004',
      customer: Customer(name: 'Anil Kumar', phone: '+91 98765 12345', email: 'anil.kumar@email.com'),
      device: Device(type: 'Microwave', brand: 'Bajaj', model: '1701 MT', serial: 'IN-MW-40004', purchaseDate: '2018-07-01', warrantyExpiry: '2021-07-01'),
      issue: 'Not heating', description: 'Microwave turns on but does not heat food.',
      status: ComplaintStatus.rejected, priority: Priority.low,
      district: 'Bengaluru', address: 'Flat 8, Indiranagar, Bengaluru',
      createdAt: DateTime(2024, 2, 12, 10, 0), updatedAt: DateTime(2024, 2, 13, 11, 0),
      notes: ['Warranty expired, customer declined paid repair'],
      logs: [
        LogEntry(time: DateTime(2024, 2, 12, 10, 0), action: 'Complaint submitted', by: 'Customer'),
        LogEntry(time: DateTime(2024, 2, 13, 11, 0), action: 'Rejected: Warranty expired', by: 'Admin'),
      ],
    ),
    Complaint(
      id: 'c5', ticketNo: 'TKT-2024-005',
      customer: Customer(name: 'Meena Iyer', phone: '+91 90000 11122', email: 'meena.iyer@email.com'),
      device: Device(type: 'TV', brand: 'Sony', model: 'Bravia 55X9000H', serial: 'IN-TV-50005', purchaseDate: '2023-01-05', warrantyExpiry: '2026-01-05'),
      issue: 'Screen flickering', description: 'TV screen flickers and sometimes goes black.',
      status: ComplaintStatus.pending, priority: Priority.medium,
      district: 'Chennai', address: 'Villa 23, Besant Nagar, Chennai',
      createdAt: DateTime(2024, 2, 16, 7, 30), updatedAt: DateTime(2024, 2, 16, 7, 30),
      attachments: ['video2.mp4'],
      logs: [
        LogEntry(time: DateTime(2024, 2, 16, 7, 30), action: 'Complaint submitted with video attachment', by: 'Customer'),
      ],
    ),
    Complaint(
      id: 'c6', ticketNo: 'TKT-2024-006',
      customer: Customer(name: 'Vikas Gupta', phone: '+91 98888 77766', email: 'vikas.gupta@email.com'),
      device: Device(type: 'AC Unit', brand: 'Blue Star', model: 'IA318YNU', serial: 'IN-AC-60006', purchaseDate: '2022-05-20', warrantyExpiry: '2025-05-20'),
      issue: 'Water leaking', description: 'Water dripping from the indoor unit, damaging the wall.',
      status: ComplaintStatus.active, priority: Priority.high,
      district: 'Pune', address: 'House 7, Kothrud, Pune',
      createdAt: DateTime(2024, 2, 15, 14, 0), updatedAt: DateTime(2024, 2, 16, 8, 0),
      assignedTechnicianId: 't3',
      parts: ['Drain pipe', 'Insulation tape'],
      logs: [
        LogEntry(time: DateTime(2024, 2, 15, 14, 0), action: 'Complaint submitted', by: 'Customer'),
        LogEntry(time: DateTime(2024, 2, 15, 16, 0), action: 'Assigned to Suresh Nair', by: 'Admin'),
      ],
    ),
  ];

  static List<Technician> technicians = [
    Technician(
      id: 't1', name: 'Amit Kumar', phone: '+91 90011 22334', email: 'amit.kumar@techserve.in',
      skills: ['AC Repair', 'Refrigerator', 'Freezer'],
      districts: ['Mumbai', 'Delhi', 'Pune'],
      status: TechnicianStatus.busy, rating: 4.8,
      completedJobs: 142, activeJobs: 2,
      joinDate: DateTime(2022, 3, 15),
      availability: [
        AvailabilitySlot(day: 'Monday', slots: ['8:00-12:00', '13:00-17:00']),
        AvailabilitySlot(day: 'Tuesday', slots: ['8:00-12:00', '13:00-17:00']),
        AvailabilitySlot(day: 'Wednesday', slots: ['8:00-12:00']),
        AvailabilitySlot(day: 'Thursday', slots: ['8:00-17:00']),
        AvailabilitySlot(day: 'Sunday', slots: ['8:00-12:00']),
      ],
    ),
    Technician(
      id: 't2', name: 'Rakesh Verma', phone: '+91 90022 33445', email: 'rakesh.verma@techserve.in',
      skills: ['Washing Machine', 'Dryer', 'Dishwasher'],
      districts: ['Ahmedabad', 'Delhi', 'Jaipur'],
      status: TechnicianStatus.available, rating: 4.6,
      completedJobs: 98, activeJobs: 0,
      joinDate: DateTime(2022, 7, 1),
      availability: [
        AvailabilitySlot(day: 'Monday', slots: ['8:00-17:00']),
        AvailabilitySlot(day: 'Tuesday', slots: ['8:00-17:00']),
        AvailabilitySlot(day: 'Thursday', slots: ['8:00-17:00']),
        AvailabilitySlot(day: 'Friday', slots: ['8:00-12:00']),
      ],
    ),
    Technician(
      id: 't3', name: 'Suresh Nair', phone: '+91 90033 44556', email: 'suresh.nair@techserve.in',
      skills: ['AC Repair', 'TV Repair', 'Small Appliances'],
      districts: ['Pune', 'Bengaluru', 'Mumbai'],
      status: TechnicianStatus.busy, rating: 4.9,
      completedJobs: 203, activeJobs: 3,
      joinDate: DateTime(2021, 11, 20),
      availability: [
        AvailabilitySlot(day: 'Monday', slots: ['8:00-17:00']),
        AvailabilitySlot(day: 'Wednesday', slots: ['8:00-17:00']),
        AvailabilitySlot(day: 'Thursday', slots: ['8:00-17:00']),
      ],
    ),
    Technician(
      id: 't4', name: 'Deepak Joshi', phone: '+91 90044 55667', email: 'deepak.joshi@techserve.in',
      skills: ['Refrigerator', 'Freezer', 'Microwave'],
      districts: ['Bengaluru', 'Chennai', 'Hyderabad'],
      status: TechnicianStatus.offline, rating: 4.4,
      completedJobs: 67, activeJobs: 0,
      joinDate: DateTime(2023, 2, 10),
      availability: [
        AvailabilitySlot(day: 'Monday', slots: ['9:00-17:00']),
        AvailabilitySlot(day: 'Tuesday', slots: ['9:00-17:00']),
      ],
    ),
    Technician(
      id: 't5', name: 'Neha Desai', phone: '+91 90055 66778', email: 'neha.desai@techserve.in',
      skills: ['TV Repair', 'Home Theater', 'Smart Home'],
      districts: ['Chennai', 'Mumbai', 'Delhi'],
      status: TechnicianStatus.available, rating: 4.7,
      completedJobs: 115, activeJobs: 1,
      joinDate: DateTime(2022, 9, 5),
      availability: [
        AvailabilitySlot(day: 'Monday', slots: ['8:00-17:00']),
        AvailabilitySlot(day: 'Tuesday', slots: ['8:00-17:00']),
        AvailabilitySlot(day: 'Wednesday', slots: ['8:00-17:00']),
        AvailabilitySlot(day: 'Thursday', slots: ['8:00-17:00']),
        AvailabilitySlot(day: 'Sunday', slots: ['8:00-12:00']),
      ],
    ),
  ];

  static List<ScheduledJob> scheduledJobs = [
    ScheduledJob(id: 'j1', technicianId: 't1', complaintId: 'c2', date: '2024-02-19', time: '10:00', duration: 2.0, customer: 'Priya Singh', district: 'Delhi', issue: 'Refrigerator not cooling'),
    ScheduledJob(id: 'j2', technicianId: 't3', complaintId: 'c6', date: '2024-02-19', time: '14:00', duration: 1.5, customer: 'Vikas Gupta', district: 'Pune', issue: 'AC water leaking'),
    ScheduledJob(id: 'j3', technicianId: 't5', complaintId: 'c5', date: '2024-02-20', time: '09:00', duration: 2.0, customer: 'Meena Iyer', district: 'Chennai', issue: 'TV screen flickering'),
    ScheduledJob(id: 'j4', technicianId: 't1', complaintId: 'c1', date: '2024-02-20', time: '11:00', duration: 2.5, customer: 'Rahul Sharma', district: 'Mumbai', issue: 'AC not cooling'),
    ScheduledJob(id: 'j5', technicianId: 't2', complaintId: 'c3', date: '2024-02-21', time: '09:00', duration: 1.0, customer: 'Sunita Patel', district: 'Ahmedabad', issue: 'Follow-up visit'),
  ];

  static Map<String, dynamic> dashboardStats = {
    'total': 248, 'pending': 45, 'active': 72, 'completed': 118, 'rejected': 13,
    'todayNew': 8, 'todayCompleted': 12, 'avgResponseTime': '2.4h', 'satisfaction': 4.7,
  };

  static List<Map<String, dynamic>> weeklyData = [
    {'day': 'Sun', 'complaints': 14, 'resolved': 10},
    {'day': 'Mon', 'complaints': 20, 'resolved': 17},
    {'day': 'Tue', 'complaints': 25, 'resolved': 21},
    {'day': 'Wed', 'complaints': 17, 'resolved': 14},
    {'day': 'Thu', 'complaints': 28, 'resolved': 23},
    {'day': 'Fri', 'complaints': 10, 'resolved': 7},
    {'day': 'Sat', 'complaints': 13, 'resolved': 11},
  ];

  static List<Map<String, dynamic>> monthlyData = [
    {'month': 'Sep', 'complaints': 150, 'resolved': 135},
    {'month': 'Oct', 'complaints': 180, 'resolved': 165},
    {'month': 'Nov', 'complaints': 210, 'resolved': 190},
    {'month': 'Dec', 'complaints': 170, 'resolved': 158},
    {'month': 'Jan', 'complaints': 220, 'resolved': 200},
    {'month': 'Feb', 'complaints': 255, 'resolved': 120},
  ];

  static List<Map<String, dynamic>> districtData = [
    {'name': 'Mumbai', 'count': 90, 'intensity': 0.92},
    {'name': 'Delhi', 'count': 60, 'intensity': 0.70},
    {'name': 'Bengaluru', 'count': 40, 'intensity': 0.50},
    {'name': 'Chennai', 'count': 35, 'intensity': 0.45},
    {'name': 'Pune', 'count': 30, 'intensity': 0.38},
    {'name': 'Ahmedabad', 'count': 25, 'intensity': 0.32},
    {'name': 'Hyderabad', 'count': 20, 'intensity': 0.25},
    {'name': 'Kolkata', 'count': 18, 'intensity': 0.20},
    {'name': 'Jaipur', 'count': 15, 'intensity': 0.18},
  ];

  static List<Map<String, dynamic>> deviceData = [
    {'name': 'AC Unit', 'count': 95},
    {'name': 'Refrigerator', 'count': 70},
    {'name': 'Washing Machine', 'count': 52},
    {'name': 'TV', 'count': 28},
    {'name': 'Microwave', 'count': 22},
    {'name': 'Others', 'count': 18},
  ];
}
