import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medication.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _dosage = 1;
  List<TimeOfDay> _reminderTimes = [TimeOfDay.now()];
  String _selectedType = 'Tablet';
  String _selectedFrequencyType = 'Every Day';
  String _selectedDuration = '1 Month';
  bool _alarmEnabled = true;
  String _selectedSnooze = '2 min';
  Set<int> _selectedCustomDays = {};
  int _selectedDayOfWeek = DateTime.now().weekday;

  final List<String> _frequencyTypes = [
    'Every Day',
    'Once a Week',
    'Custom Days'
  ];

  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  void _updateReminderTimes() {
    setState(() {
      if (_dosage > _reminderTimes.length) {
        while (_reminderTimes.length < _dosage) {
          _reminderTimes.add(TimeOfDay.now());
        }
      } else if (_dosage < _reminderTimes.length) {
        _reminderTimes = _reminderTimes.sublist(0, _dosage);
      }
    });
  }

  void _saveMedication() async {
    if (_formKey.currentState!.validate()) {
      // Create medication object
      final medication = Medication(
        name: _nameController.text,
        type: _selectedType,
        dosage: _dosage,
        reminderTimes: _reminderTimes,
        frequencyType: _selectedFrequencyType,
        selectedDays: _selectedFrequencyType == 'Every Day'
            ? List.generate(7, (index) => index + 1)
            : _selectedFrequencyType == 'Once a Week'
                ? [_selectedDayOfWeek]
                : _selectedCustomDays.toList(),
        duration: _selectedDuration,
        hasAlarm: _alarmEnabled,
        snoozeTime: _selectedSnooze,
        remainingQuantity: 30, // Default value
      );

      // Save to database
      final id = await DatabaseHelper.instance.insertMedication(medication);

      // Schedule notifications
      if (_alarmEnabled) {
        final now = DateTime.now();
        for (var time in _reminderTimes) {
          for (var weekday in medication.selectedDays) {
            var scheduledDate = DateTime(
              now.year,
              now.month,
              now.day,
              time.hour,
              time.minute,
            );

            // Adjust date to next occurrence of the weekday
            while (scheduledDate.weekday != weekday) {
              scheduledDate = scheduledDate.add(const Duration(days: 1));
            }

            // If the time has passed for today, schedule for next week
            if (scheduledDate.isBefore(now)) {
              scheduledDate = scheduledDate.add(const Duration(days: 7));
            }

            await NotificationService().scheduleMedicationNotification(
              medication,
              scheduledDate,
              id * 100 + medication.selectedDays.indexOf(weekday),
            );
          }
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
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
          flexibleSpace: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 50, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    'Medicine',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Medicine Name',
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF1A1B4B)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter medicine name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Medicine Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: [
                        for (final type in [
                          'Tablet',
                          'Capsule',
                          'Drops',
                          'Injection'
                        ])
                          Padding(
                            padding: EdgeInsets.only(
                                right: type != 'Injection' ? 8 : 0),
                            child: ChoiceChip(
                              label: Text(type),
                              selected: _selectedType == type,
                              selectedColor:
                                  const Color(0xFF1A1B4B).withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: _selectedType == type
                                    ? const Color(0xFF1A1B4B)
                                    : Colors.grey[600],
                                fontWeight: _selectedType == type
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedType = type;
                                  });
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Dosage',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (_dosage > 1) {
                              setState(() {
                                _dosage--;
                                _updateReminderTimes();
                              });
                            }
                          },
                          color: Colors.grey[600],
                        ),
                        Text(
                          _dosage.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _dosage++;
                              _updateReminderTimes();
                            });
                          },
                          color: const Color(0xFF1A1B4B),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Reminder Times',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_reminderTimes.length, (index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          'Reminder ${index + 1}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('hh:mm a').format(
                            DateTime(2022, 1, 1, _reminderTimes[index].hour,
                                _reminderTimes[index].minute),
                          ),
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: _reminderTimes[index],
                          );
                          if (time != null) {
                            setState(() {
                              _reminderTimes[index] = time;
                            });
                          }
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedFrequencyType,
                        isExpanded: true,
                        items: _frequencyTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFrequencyType = newValue!;
                            if (newValue == 'Custom Days') {
                              _selectedCustomDays = {};
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  if (_selectedFrequencyType == 'Once a Week') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedDayOfWeek,
                          isExpanded: true,
                          items: List.generate(7, (index) {
                            return DropdownMenuItem<int>(
                              value: index + 1,
                              child: Text(_weekDays[index]),
                            );
                          }),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedDayOfWeek = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                  if (_selectedFrequencyType == 'Custom Days') ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: List.generate(7, (index) {
                        final weekday = index + 1;
                        return FilterChip(
                          label: Text(_weekDays[index].substring(0, 3)),
                          selected: _selectedCustomDays.contains(weekday),
                          selectedColor:
                              const Color(0xFF1A1B4B).withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: _selectedCustomDays.contains(weekday)
                                ? const Color(0xFF1A1B4B)
                                : Colors.grey[600],
                            fontWeight: _selectedCustomDays.contains(weekday)
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCustomDays.add(weekday);
                              } else {
                                _selectedCustomDays.remove(weekday);
                              }
                            });
                          },
                        );
                      }),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Duration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDuration,
                        isExpanded: true,
                        items: ['1 Week', '2 Weeks', '1 Month', '3 Months']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDuration = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            Switch(
                              value: _alarmEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _alarmEnabled = value;
                                });
                              },
                              activeColor: const Color(0xFF1A1B4B),
                            ),
                          ],
                        ),
                        if (_alarmEnabled) ...[
                          const Divider(height: 24),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSnooze,
                              isExpanded: true,
                              items: ['2 min', '5 min', '10 min', '15 min']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedSnooze = newValue!;
                                });
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _saveMedication,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1B4B),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Add Medicine',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
