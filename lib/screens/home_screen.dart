import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_medication_screen.dart';
import 'medication_view_screen.dart';
import '../services/database_helper.dart';
import '../models/medication.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Medication> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
    });

    final medications = await DatabaseHelper.instance.getAllMedications();
    setState(() {
      _medications = medications.reversed.toList();
      _isLoading = false;
    });
  }

  void _viewMedication(Medication medication) async {
    final deleted = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationViewScreen(medication: medication),
      ),
    );

    if (deleted == true) {
      _loadMedications();
    }
  }

  String _getFormattedTime(List<String> times) {
    if (times.isEmpty) return '';
    return times.map((timeStr) {
      final parts = timeStr.split(':');
      final time =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      return DateFormat('hh:mm a')
          .format(DateTime(2022, 1, 1, time.hour, time.minute));
    }).join(', ');
  }

  Color _getMedicationColor(String type) {
    switch (type.toLowerCase()) {
      case 'tablet':
        return Colors.blue;
      case 'capsual':
        return Colors.red;
      case 'drops':
        return Colors.green;
      case 'injec':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
          flexibleSpace: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medicine',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    'Reminder',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _medications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No medications added yet',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: _medications.length,
                      itemBuilder: (context, index) {
                        final medication = _medications[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _viewMedication(medication),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color:
                                            _getMedicationColor(medication.type)
                                                .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.medication,
                                        color: _getMedicationColor(
                                            medication.type),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            medication.name,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1A1B4B),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _getFormattedTime(
                                                medication.reminderTimes),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                              height: 1.3,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${medication.dosage} ${medication.type}(s) ${medication.frequencyType}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[500],
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMedicationScreen(),
            ),
          );
          _loadMedications();
        },
        backgroundColor: Colors.amber,
        elevation: 2,
        child: const Icon(Icons.add),
      ),
    );
  }
}
