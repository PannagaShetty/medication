import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medication.dart';
import '../services/database_helper.dart';

class MedicationViewScreen extends StatelessWidget {
  final Medication medication;

  const MedicationViewScreen({super.key, required this.medication});

  Future<void> _deleteMedication(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Medication',
            style: TextStyle(
              color: Color(0xFF1A1B4B),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${medication.name}?',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteMedication(medication.id!);
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  String _getFormattedTime(List<String> times) {
    if (times.isEmpty) return '';
    return times.map((timeStr) {
      final parts = timeStr.split(':');
      return DateFormat('hh:mm a').format(
          DateTime(2022, 1, 1, int.parse(parts[0]), int.parse(parts[1])));
    }).join(', ');
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1B4B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1A1B4B),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A1B4B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B4B),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red[300],
              onPressed: () => _deleteMedication(context),
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.medication,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${medication.dosage} ${medication.type}(s)',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 24),
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(32),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoRow(
                  'Schedule',
                  medication.frequencyType == 'Every Day'
                      ? 'Daily'
                      : medication.frequencyType,
                  Icons.calendar_today,
                ),
                const SizedBox(height: 24),
                _buildInfoRow(
                  'Reminder Times',
                  _getFormattedTime(medication.reminderTimes),
                  Icons.access_time,
                ),
                const SizedBox(height: 24),
                _buildInfoRow(
                  'Duration',
                  medication.duration,
                  Icons.timelapse,
                ),
                const SizedBox(height: 24),
                _buildInfoRow(
                  'Remaining',
                  '${medication.remainingQuantity} ${medication.type}(s)',
                  Icons.inventory_2,
                ),
                const SizedBox(height: 24),
                _buildInfoRow(
                  'Notifications',
                  medication.hasAlarm ? 'Enabled' : 'Disabled',
                  Icons.notifications,
                ),
                if (medication.hasAlarm && medication.snoozeTime != null) ...[
                  const SizedBox(height: 24),
                  _buildInfoRow(
                    'Snooze Time',
                    medication.snoozeTime!,
                    Icons.snooze,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
