import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/app_layout.dart';
import '../../core/theme/page_transition.dart';
import '../../core/widgets/fade_in.dart';

import 'complaint_preview_screen.dart';

class RaiseComplaintScreen extends StatefulWidget {
  const RaiseComplaintScreen({super.key});

  @override
  State<RaiseComplaintScreen> createState() => _RaiseComplaintScreenState();
}

class _RaiseComplaintScreenState extends State<RaiseComplaintScreen> {
  // Controllers
  final contactController = TextEditingController();
  final addressController = TextEditingController();
  final detailsController = TextEditingController();

  // Files
  PlatformFile? electricityBill;
  XFile? problemPhoto;
  PlatformFile? supportingDoc;

  // Date Time
  DateTime? complaintDateTime;

  // Pick Electricity Bill
  Future<void> pickElectricityBill() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        electricityBill = result.files.first;
      });
    }
  }

  // Pick Problem Photo
  Future<void> pickProblemPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        problemPhoto = picked;
      });
    }
  }

  // Pick Supporting Document
  Future<void> pickSupportingDoc() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        supportingDoc = result.files.first;
      });
    }
  }

  // Pick Date & Time
  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      complaintDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: "Raise Complaint",
      showBack: true,

      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const FadeInWidget(
              delay: 100,
              child: Text(
                "Create Electricity Complaint",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Contact Number
            _inputField(
              label: "Contact Number",
              controller: contactController,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),

            // Address
            _inputField(
              label: "Address",
              controller: addressController,
              icon: Icons.location_on,
              maxLines: 2,
              isOptional: true,
            ),

            // Problem Details
            _inputField(
              label: "Problem Details",
              controller: detailsController,
              icon: Icons.report_problem,
              maxLines: 3,
            ),

            const SizedBox(height: 15),

            // Upload Bill
            _uploadTile(
              title: "Electricity Bill (Optional)",
              subtitle: electricityBill?.name ?? "Upload Bill Document",
              icon: Icons.picture_as_pdf,
              onTap: pickElectricityBill,
            ),

            // Upload Problem Photo
            _uploadTile(
              title: "Problem Photo (Optional)",
              subtitle: problemPhoto?.name ?? "Upload Problem Image",
              icon: Icons.image,
              onTap: pickProblemPhoto,
            ),

            // Supporting Document
            _uploadTile(
              title: "Supporting Document (Optional)",
              subtitle: supportingDoc?.name ?? "Upload Any Document",
              icon: Icons.attach_file,
              onTap: pickSupportingDoc,
            ),

            // Date & Time Picker
            _uploadTile(
              title: "Date & Time (Optional)",
              subtitle: complaintDateTime == null
                  ? "Select Date & Time"
                  : DateFormat("dd MMM yyyy • hh:mm a")
                  .format(complaintDateTime!),
              icon: Icons.calendar_today,
              onTap: pickDateTime,
            ),

            const SizedBox(height: 30),

            // Preview Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  FadePageRoute(
                    page: ComplaintPreviewScreen(
                      contact: contactController.text,
                      address: addressController.text,
                      details: detailsController.text,
                      billFile: electricityBill,
                      problemPhoto: problemPhoto,
                      supportingDoc: supportingDoc,
                      dateTime: complaintDateTime,
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xff0D47A1), Color(0xff1976D2)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    "PREVIEW COMPLAINT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Input Field Widget
  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isOptional = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: isOptional ? "$label (Optional)" : label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  // Upload Tile Widget
  Widget _uploadTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.upload),
        onTap: onTap,
      ),
    );
  }
}
