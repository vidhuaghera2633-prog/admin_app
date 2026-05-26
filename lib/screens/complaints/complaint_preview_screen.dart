import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/complaints_provider.dart';
import '../../models/complaint.dart';
import '../../theme/app_theme.dart';
import '../../core/widgets/app_layout.dart';

class ComplaintPreviewScreen extends StatelessWidget {
  final String contact;
  final String address;
  final String details;
  final PlatformFile? billFile;
  final XFile? problemPhoto;
  final PlatformFile? supportingDoc;
  final DateTime? dateTime;

  const ComplaintPreviewScreen({
    super.key,
    required this.contact,
    required this.address,
    required this.details,
    this.billFile,
    this.problemPhoto,
    this.supportingDoc,
    this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: "Preview Complaint",
      showBack: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection("Contact Information", [
              _buildInfoRow(Icons.phone, "Contact Number", contact),
              _buildInfoRow(Icons.location_on, "Address", address.isEmpty ? "Not provided" : address),
            ]),
            const SizedBox(height: 20),
            _buildSection("Problem Details", [
              _buildInfoRow(Icons.report_problem, "Description", details),
              if (dateTime != null)
                _buildInfoRow(Icons.calendar_today, "Preferred Date & Time", 
                  DateFormat("dd MMM yyyy • hh:mm a").format(dateTime!)),
            ]),
            const SizedBox(height: 20),
            _buildSection("Attachments", [
              _buildFileRow(Icons.picture_as_pdf, "Electricity Bill", billFile?.name),
              _buildFileRow(Icons.image, "Problem Photo", problemPhoto?.name),
              _buildFileRow(Icons.attach_file, "Supporting Doc", supportingDoc?.name),
            ]),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () => _submitComplaint(context),
                child: const Text("SUBMIT COMPLAINT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.gray400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileRow(IconData icon, String label, String? fileName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: fileName != null ? Colors.green : AppColors.gray300),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Text(fileName ?? "No file", 
            style: TextStyle(fontSize: 12, color: fileName != null ? AppColors.primary : AppColors.gray400)),
        ],
      ),
    );
  }

  void _submitComplaint(BuildContext context) async {
    final provider = context.read<ComplaintsProvider>();
    final id = 'c${DateTime.now().millisecondsSinceEpoch}';
    
    final newComplaint = Complaint(
      id: id,
      ticketNo: 'TKT-${DateFormat('yyyyMMdd').format(DateTime.now())}-${id.substring(id.length - 4)}',
      customer: Customer(name: "User", phone: contact, email: ""),
      device: Device(type: "Electricity", brand: "", model: "", serial: "", purchaseDate: "", warrantyExpiry: ""),
      issue: details,
      description: details,
      status: ComplaintStatus.pending,
      priority: Priority.medium,
      district: "Default",
      address: address,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await provider.addComplaint(newComplaint);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Complaint submitted successfully!")),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }
}
