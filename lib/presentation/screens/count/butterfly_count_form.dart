import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

// your imports…
import 'package:butterfly_count/data/models/checklist.dart';
import 'package:butterfly_count/data/models/observation.dart';

class ButterflyCountForm extends ConsumerStatefulWidget {
  const ButterflyCountForm({Key? key}) : super(key: key);

  @override
  ConsumerState<ButterflyCountForm> createState() => _ButterflyCountFormState();
}

class _ButterflyCountFormState extends ConsumerState<ButterflyCountForm> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form data…
  String? teamName;
  DateTime selectedDate = DateTime.now();
  DateTime startTime = DateTime.now();
  DateTime? endTime;
  bool openAccess = false;

  double? latitude, longitude, altitude, accuracy;
  String weather = 'Sunny';
  String? comments;

  final List<Observation> observations = [];

  /// Timer for checklist page
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  static const Duration _testThreshold = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    // start the timer right away
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _elapsed = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(startTime);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int i) {
    if (i == 2 && (latitude == null || longitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set location first')),
      );
      return;
    }
    setState(() => _currentPage = i);
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colors for the tab bar
    final tabBarBg = isDark ? Colors.grey[850]! : Colors.grey[200]!;
    final activeColor = isDark ? Colors.lightBlue[200]! : Colors.blue;
    final inactiveColor = isDark ? Colors.grey[500]! : Colors.grey[600]!;
    final disabledColor = Theme.of(context).disabledColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Butterfly Count'),
        actions: [
          if (_currentPage == 2)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                // Build and save checklist…
                final checklist = Checklist(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: '1',
                  teamName: teamName,
                  placeName: '',
                  latitude: latitude ?? 0,
                  longitude: longitude ?? 0,
                  altitude: altitude,
                  accuracy: accuracy,
                  date: selectedDate,
                  startTime: startTime,
                  endTime: endTime ?? DateTime.now(),
                  weather: weather,
                  comments: comments,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  isOpenAccess: openAccess,
                  syncStatus: 'pending',
                  observations: observations,
                );
                // TODO: save checklist
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Form submitted!')),
                );
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_currentPage + 1) / 3, minHeight: 4),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _buildBasicInfoPage(),
                _buildLocationPage(),
                _buildChecklistPage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: tabBarBg,
        child: Row(
          children: [
            _buildBottomTab(
              'Survey',
              0,
              activeColor,
              inactiveColor,
              disabledColor,
            ),
            _buildBottomTab(
              'Location',
              1,
              activeColor,
              inactiveColor,
              disabledColor,
            ),
            _buildBottomTab(
              'Checklist',
              2,
              activeColor,
              inactiveColor,
              disabledColor,
              locked: latitude == null || longitude == null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomTab(
    String label,
    int index,
    Color active,
    Color inactive,
    Color disabled, {
    bool locked = false,
  }) {
    final selected = index == _currentPage;
    final color =
        locked
            ? disabled
            : selected
            ? active
            : inactive;

    return Expanded(
      child: InkWell(
        onTap: () => _goToPage(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: color.withOpacity(selected ? 0.15 : 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (locked) ...[
                const Icon(Icons.lock_outline, size: 16),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
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
            onChanged: (v) => teamName = v,
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
                setState(() {
                  selectedDate = picked;
                  // also adjust startTime and endTime to match picked date
                  startTime = DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                    startTime.hour,
                    startTime.minute,
                  );
                  if (endTime != null) {
                    endTime = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      endTime!.hour,
                      endTime!.minute,
                    );
                  }
                });
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
                setState(() {
                  startTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    time.hour,
                    time.minute,
                  );
                  // Ensure end time is after start time
                  if (endTime != null && !endTime!.isAfter(startTime)) {
                    endTime = startTime.add(const Duration(hours: 1));
                  }
                });
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
                initialTime:
                    endTime != null
                        ? TimeOfDay.fromDateTime(endTime!)
                        : TimeOfDay.fromDateTime(
                          startTime.add(const Duration(hours: 1)),
                        ),
              );
              if (time != null) {
                final newEndTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  time.hour,
                  time.minute,
                );
                if (newEndTime.isAfter(startTime)) {
                  setState(() => endTime = newEndTime);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('End time must be after start time'),
                    ),
                  );
                }
              }
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Open Access'),
            subtitle: const Text('Make this count publicly visible'),
            value: openAccess,
            onChanged: (value) => setState(() => openAccess = value),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.my_location),
            label: const Text('Use Current Location'),
            onPressed: () async {
              try {
                final position = await Geolocator.getCurrentPosition();
                setState(() {
                  latitude = position.latitude;
                  longitude = position.longitude;
                  accuracy = position.accuracy;
                  altitude = position.altitude;
                });
              } catch (e) {
                // Only allow fallback in debug mode, and on desktop/web:
                if (kDebugMode &&
                    (kIsWeb ||
                        Platform.isWindows ||
                        Platform.isLinux ||
                        Platform.isMacOS)) {
                  setState(() {
                    latitude = 0.0;
                    longitude = 0.0;
                    accuracy = 1;
                    altitude = 2;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Geolocation not supported on this platform.\nDemo values used. This will never show in production!',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error getting location: ${e.toString()}'),
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: latitude?.toString() ?? '',
                  onChanged: (value) => latitude = double.tryParse(value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: longitude?.toString() ?? '',
                  onChanged: (value) => longitude = double.tryParse(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Altitude (m)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: altitude?.toString() ?? '',
                  onChanged: (value) => altitude = double.tryParse(value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Accuracy (m)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: accuracy?.toString() ?? '',
                  onChanged: (value) => accuracy = double.tryParse(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: weather,
            decoration: const InputDecoration(
              labelText: 'Weather',
              border: OutlineInputBorder(),
            ),
            items:
                ['Sunny', 'Cloudy', 'Rainy', 'Windy']
                    .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                    .toList(),
            onChanged: (value) => setState(() => weather = value ?? 'Sunny'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Additional Comments',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            onChanged: (value) => comments = value,
          ),
        ],
      ),
    );
  }

  Future<void> _getLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        latitude = pos.latitude;
        longitude = pos.longitude;
        accuracy = pos.accuracy;
        altitude = pos.altitude;
      });
    } catch (e) {
      if (kDebugMode &&
          (kIsWeb ||
              Platform.isWindows ||
              Platform.isLinux ||
              Platform.isMacOS)) {
        setState(() {
          latitude = 0;
          longitude = 0;
          accuracy = 1;
          altitude = 2;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Running on desktop/web in debug: using demo coords\nWon’t appear in production.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
      }
    }
  }

  Widget _buildChecklistPage() {
    final underThreshold = _elapsed < _testThreshold;
    final timerColor = underThreshold ? Colors.amber : Colors.green;
    final elapsedText = _elapsed.toString().split('.').first; // hh:mm:ss

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildStatCard('Species', observations.length.toString()),
              const SizedBox(width: 8),
              _buildStatCard(
                'Individuals',
                observations
                    .fold<int>(0, (s, o) => s + o.individuals)
                    .toString(),
              ),
              const SizedBox(width: 8),
              _buildStatCard('Duration', elapsedText, customColor: timerColor),
            ],
          ),
        ),
        // Full-width, subtly colored DataTable:
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  timerColor.withOpacity(0.1),
                ),
                dataRowColor: MaterialStateProperty.all(
                  timerColor.withOpacity(0.03),
                ),
                columns: const [
                  DataColumn(label: Text('Species')),
                  DataColumn(label: Text('Count')),
                  DataColumn(label: Text('Actions')),
                ],
                rows:
                    observations.map((obs) {
                      return DataRow(
                        cells: [
                          DataCell(Text(obs.customName ?? 'Unknown')),
                          DataCell(Text('${obs.individuals}')),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed:
                                  () => setState(() {
                                    observations.removeWhere(
                                      (o) => o.id == obs.id,
                                    );
                                  }),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
        // Add button stays overlayed:
        Padding(
          padding: const EdgeInsets.all(16),
          child: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('Add Observation'),
            onPressed: () => _showAddObservationDialog(context),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, {Color? customColor}) {
    final color = customColor ?? Theme.of(context).primaryColor;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: Theme.of(context).textTheme.labelSmall),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddObservationDialog(BuildContext ctx) {
    String? name;
    int count = 1;
    String? remarks;
    showDialog(
      context: ctx,
      builder:
          (_) => AlertDialog(
            title: const Text('Add Observation'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Species Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => name = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Count',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: '1',
                    onChanged: (v) => count = int.tryParse(v) ?? 1,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Remarks (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => remarks = v,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    observations.add(
                      Observation(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        checklistId: '',
                        customName: name,
                        individuals: count,
                        remarks: remarks,
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }
}
