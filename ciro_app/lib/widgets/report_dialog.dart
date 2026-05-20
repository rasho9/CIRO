import 'package:flutter/material.dart';
import 'package:ciro_app/theme/colors.dart';

class ReportDialog extends StatefulWidget {
  final Function(
    String type,
    String severity,
    String location,
    String description,
  ) onSubmit;

  const ReportDialog({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final typeController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  String severity = 'Medium';

  @override
  void dispose() {
    typeController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF070B1F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF1E284C)),
      ),
      title: const Row(
        children: [
          Icon(Icons.report_gmailerrorred, color: AppColors.cyanAccent),
          SizedBox(width: 10),
          Text(
            'CIVIC SIGNAL INGESTION REPORT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'TYPE OF EMERGENCY INCIDENT',
              style: TextStyle(fontSize: 9, color: Colors.white30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: typeController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Flash Flood, Fire Outbreak, Traffic Spill',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF0F143A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'SEVERITY THREAT LEVEL',
              style: TextStyle(fontSize: 9, color: Colors.white30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: ['Low', 'Medium', 'Critical'].map((sev) {
                bool isSel = severity == sev;
                Color col = sev == 'Critical'
                    ? AppColors.redAlert
                    : sev == 'Medium'
                        ? const Color(0xFFFF9100)
                        : const Color(0xFFFFD600);

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        severity = sev;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSel ? col.withOpacity(0.12) : const Color(0xFF0F143A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSel ? col : const Color(0xFF1E284C)),
                      ),
                      child: Text(
                        sev.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSel ? Colors.white : Colors.white38,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'GEOLOCATION SECTOR',
              style: TextStyle(fontSize: 9, color: Colors.white30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: locationController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Saddar Sector E, Gulberg Blvd Block D',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF0F143A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'RAW ANOMALY DESCRIPTION',
              style: TextStyle(fontSize: 9, color: Colors.white30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: descriptionController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Provide details like structural damage or water level depth...',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF0F143A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'STAND DOWN',
            style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cyanAccent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () {
            if (typeController.text.isNotEmpty && locationController.text.isNotEmpty) {
              widget.onSubmit(
                typeController.text,
                severity,
                locationController.text,
                descriptionController.text,
              );
              Navigator.pop(context);
            }
          },
          child: const Text(
            'SUBMIT SIGNAL FUSION',
            style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
