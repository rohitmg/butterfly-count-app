// lib/presentation/screens/count/basic_info_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BasicInfoPage extends ConsumerWidget {
  const BasicInfoPage({
    super.key,
    required this.teamName,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.openAccess,
    required this.onTeamNameChanged,
    required this.onDateSelected,
    required this.onStartTimeSelected,
    required this.onEndTimeSelected,
    required this.onOpenAccessChanged,
  });

  final String? teamName;
  final DateTime selectedDate;
  final DateTime startTime;
  final DateTime? endTime;
  final bool openAccess;
  final ValueChanged<String?> onTeamNameChanged;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onStartTimeSelected;
  final ValueChanged<DateTime?> onEndTimeSelected;
  final ValueChanged<bool> onOpenAccessChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Team Name (Optional)',
              border: OutlineInputBorder(),
            ),
            initialValue: teamName, // Set initial value
            onChanged: onTeamNameChanged,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Date'),
            subtitle: Text(DateFormat.yMd().format(selectedDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Start Time'),
            subtitle: Text(DateFormat.jm().format(startTime)),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(startTime),
              );
              if (time != null) {
                final newStartTime = DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day,
                  time.hour, time.minute,
                );
                onStartTimeSelected(newStartTime);
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('End Time'),
            subtitle: Text(
              endTime != null ? DateFormat.jm().format(endTime!) : '--',
            ),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: endTime != null
                    ? TimeOfDay.fromDateTime(endTime!)
                    : TimeOfDay.fromDateTime(
                        startTime.add(const Duration(hours: 1)),
                      ),
              );
              if (time != null) {
                final newEndTime = DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day,
                  time.hour, time.minute,
                );
                onEndTimeSelected(newEndTime);
              }
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Open Access'),
            subtitle: const Text('Make this count publicly visible'),
            value: openAccess,
            onChanged: onOpenAccessChanged,
          ),
        ],
      ),
    );
  }
}