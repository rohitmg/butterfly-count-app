import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

// your imports…
import 'package:butterfly_counts/data/models/count_model.dart'; // Renamed from checklist.dart
import 'package:butterfly_counts/data/models/observation.dart';
import 'package:butterfly_counts/data/models/taxa.dart'; // New import for taxa lookup
import 'package:butterfly_counts/providers/api_providers.dart';
import 'package:butterfly_counts/providers/app_preferences_provider.dart'; // NEW: Import app preferences


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
   late bool openAccess;

  double? latitude, longitude, altitude, accuracy;
  String weather = 'Sunny';
  String? comments;

  final List<Observation> observations = [];

  /// Timer for checklist page
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  // Controllers for text fields to pre-fill with current location
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _altitudeController = TextEditingController();
  final TextEditingController _accuracyController = TextEditingController();
  final TextEditingController _placeNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTimer();
    openAccess = ref.read(openAccessPreferenceProvider);
  }

  @override
  void didUpdateWidget(covariant ButterflyCountForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update text controllers if location changes
    _latitudeController.text = latitude?.toString() ?? '';
    _longitudeController.text = longitude?.toString() ?? '';
    _altitudeController.text = altitude?.toString() ?? '';
    _accuracyController.text = accuracy?.toString() ?? '';
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
    _latitudeController.dispose();
    _longitudeController.dispose();
    _altitudeController.dispose();
    _accuracyController.dispose();
    _placeNameController.dispose();
    super.dispose();
  }

  void _goToPage(int i) {
    if (i == 2 && (latitude == null || longitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set location first'),
          behavior: SnackBarBehavior.floating, // Use floating behavior
        ),
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

  Future<void> _getLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        latitude = pos.latitude;
        longitude = pos.longitude;
        accuracy = pos.accuracy;
        altitude = pos.altitude;
        _latitudeController.text = latitude!.toStringAsFixed(7);
        _longitudeController.text = longitude!.toStringAsFixed(7);
        _accuracyController.text = accuracy!.toStringAsFixed(2);
        _altitudeController.text = altitude!.toStringAsFixed(2);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (kDebugMode &&
          (kIsWeb ||
              Platform.isWindows ||
              Platform.isLinux ||
              Platform.isMacOS)) {
        setState(() {
          latitude = 28.6139; // Default to Delhi for debug
          longitude = 77.2090; // Default to Delhi for debug
          accuracy = 10;
          altitude = 200;
          _latitudeController.text = latitude!.toStringAsFixed(7);
          _longitudeController.text = longitude!.toStringAsFixed(7);
          _accuracyController.text = accuracy!.toStringAsFixed(2);
          _altitudeController.text = altitude!.toStringAsFixed(2);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Geolocation not supported/failed. Using demo coordinates (Delhi).',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    final countSubmissionNotifier = ref.read(countSubmissionProvider.notifier);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to submit a count.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set a valid location before submitting.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (observations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one observation.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    endTime ??= DateTime.now();

    final countData = CountModel(
      userId: user.uid,
      team: teamName,
      openAccess: openAccess,
      date: selectedDate,
      startTime: startTime,
      endTime: endTime,
      latitude: latitude!,
      longitude: longitude!,
      altitude: altitude,
      accuracy: accuracy,
      placeName: _placeNameController.text.isNotEmpty
          ? _placeNameController.text
          : null,
      distanceCovered: null,
      weather: weather,
      notes: comments,
      version: '1.0.0',
      observations: observations, // Pass the observations list here
    );

    await countSubmissionNotifier.submitCountAndObservations(
      countData: countData,
      // observationsData is no longer passed separately
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tabBarBg = isDark ? Colors.grey[850]! : Colors.grey[200]!;
    final activeColor = isDark ? Colors.lightBlue[200]! : Colors.blue;
    final inactiveColor = isDark ? Colors.grey[500]! : Colors.grey[600]!;
    final disabledColor = Theme.of(context).disabledColor;

    final submissionState = ref.watch(countSubmissionProvider);

    ref.listen<AsyncValue<int?>>(countSubmissionProvider, (previous, next) {
      next.whenOrNull(
        data: (countId) {
          if (countId != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Count submitted successfully! ID: $countId'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          }
        },
        error: (err, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Submission failed: ${err.toString()}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Butterfly Count'),
        actions: [
          if (_currentPage == 2)
            IconButton(
              icon: submissionState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.check),
              onPressed: submissionState.isLoading ? null : _submitForm,
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
                _buildChecklistPage(submissionState),
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
    final color = locked ? disabled : (selected ? active : inactive);

    return Expanded(
      child: InkWell(
        onTap: () {
          if (!locked) {
            _goToPage(index);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please set location first'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: color.withOpacity(selected ? 0.15 : 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (locked) ...[
                const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
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
                initialTime: endTime != null
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
                      behavior: SnackBarBehavior.floating,
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
            onPressed: _getLocation,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => latitude = double.tryParse(value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _longitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
                  controller: _altitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Altitude (m)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => altitude = double.tryParse(value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _accuracyController,
                  decoration: const InputDecoration(
                    labelText: 'Accuracy (m)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => accuracy = double.tryParse(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _placeNameController,
            decoration: const InputDecoration(
              labelText: 'Place Name (Optional)',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _placeNameController.text = value,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: weather,
            decoration: const InputDecoration(
              labelText: 'Weather',
              border: OutlineInputBorder(),
            ),
            items: [
              'Sunny',
              'Cloudy',
              'Rainy',
              'Windy',
            ].map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
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

  Widget _buildChecklistPage(AsyncValue<int?> submissionState) {
    final elapsedText = _elapsed.toString().split('.').first;

    final int totalIndividualsObserved = observations.fold<int>(
      0,
      (s, o) => s + o.individuals,
    );
    final int uniqueSpeciesObserved = observations
        .map((o) => o.taxaId)
        .toSet()
        .length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildStatCard('Species', uniqueSpeciesObserved.toString()),
              const SizedBox(width: 8),
              _buildStatCard(
                'Individuals',
                totalIndividualsObserved.toString(),
              ),
              const SizedBox(width: 8),
              _buildStatCard('Duration', elapsedText),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                dataRowColor: MaterialStateProperty.all(
                  Theme.of(context).primaryColor.withOpacity(0.03),
                ),
                columns: const [
                  DataColumn(label: Text('Species')),
                  DataColumn(label: Text('Count')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: observations.map((obs) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          obs.taxaCommonName ??
                              obs.taxaScientificName ??
                              'Unknown',
                        ),
                      ),
                      DataCell(Text('${obs.individuals}')),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => setState(() {
                            observations.removeWhere((o) => o.id == obs.id);
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
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton.extended(
                icon: const Icon(Icons.add),
                label: const Text('Add Observation'),
                onPressed: submissionState.isLoading
                    ? null
                    : () => _showAddObservationDialog(context, ref),
              ),
              FloatingActionButton.extended(
                icon: submissionState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.check),
                label: const Text('Submit Count'),
                onPressed: submissionState.isLoading ? null : _submitForm,
              ),
            ],
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

  void _showAddObservationDialog(BuildContext ctx, WidgetRef ref) {
    // Use ValueNotifier for a reactive selectedTaxa object
    final selectedTaxaNotifier = ValueNotifier<Taxa?>(null);
    final TextEditingController commonNameController = TextEditingController();
    final TextEditingController scientificNameController =
        TextEditingController();
    final ValueNotifier<int> individualsNotifier = ValueNotifier(1);
    String? activity;
    String? obsNotes;

    final allTaxaAsyncValue = ref.read(allTaxaProvider);
    final taxaList = allTaxaAsyncValue.asData?.value ?? [];

    // The dialog state builder listens to the selectedTaxaNotifier
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Add Observation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Common Name Autocomplete
              ValueListenableBuilder<Taxa?>(
                valueListenable: selectedTaxaNotifier,
                builder: (context, selectedTaxa, child) {
                  return Autocomplete<Taxa>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<Taxa>.empty();
                      }
                      final query = textEditingValue.text.toLowerCase();
                      return taxaList.where(
                        (taxa) =>
                            taxa.commonName?.toLowerCase().contains(query) ??
                            false,
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      final query = commonNameController.text;
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                final suggestionText =
                                    (option.commonName != null &&
                                        option.commonName!.isNotEmpty)
                                    ? '${option.commonName} (${option.scientificName})'
                                    : option.scientificName;

                                return ListTile(
                                  visualDensity: const VisualDensity(
                                    horizontal: 0,
                                    vertical: -4,
                                  ),
                                  title: Text.rich(
                                    _buildHighlightedText(
                                      suggestionText,
                                      query,
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  onTap: () {
                                    onSelected(option);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    displayStringForOption: (Taxa option) =>
                        option.commonName ?? '',
                    onSelected: (Taxa taxa) {
                      selectedTaxaNotifier.value = taxa;
                      commonNameController.text = taxa.commonName ?? '';
                      scientificNameController.text = taxa.scientificName;
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          // The onSelected handler will set the controller's text
                          // The onChanged handler will clear the linked controller
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Common Name',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) {
                              if (v !=
                                  (selectedTaxaNotifier.value?.commonName ??
                                      '')) {
                                selectedTaxaNotifier.value = null;
                                scientificNameController.clear();
                              }
                              commonNameController.text = v;
                            },
                          );
                        },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Scientific Name Autocomplete
              ValueListenableBuilder<Taxa?>(
                valueListenable: selectedTaxaNotifier,
                builder: (context, selectedTaxa, child) {
                  return Autocomplete<Taxa>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<Taxa>.empty();
                      }
                      final query = textEditingValue.text.toLowerCase();
                      return taxaList.where(
                        (taxa) =>
                            taxa.scientificName.toLowerCase().contains(query),
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      final query = scientificNameController.text;
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                final suggestionText =
                                    (option.commonName != null &&
                                        option.commonName!.isNotEmpty)
                                    ? '${option.commonName} (${option.scientificName})'
                                    : option.scientificName;

                                return ListTile(
                                  visualDensity: const VisualDensity(
                                    horizontal: 0,
                                    vertical: -4,
                                  ),
                                  title: Text.rich(
                                    _buildHighlightedText(
                                      suggestionText,
                                      query,
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  onTap: () {
                                    onSelected(option);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    displayStringForOption: (Taxa option) =>
                        option.scientificName,
                    onSelected: (Taxa taxa) {
                      selectedTaxaNotifier.value = taxa;
                      commonNameController.text = taxa.commonName ?? '';
                      scientificNameController.text = taxa.scientificName;
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Scientific Name',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) {
                              if (v !=
                                  (selectedTaxaNotifier.value?.scientificName ??
                                      '')) {
                                selectedTaxaNotifier.value = null;
                                commonNameController.clear();
                              }
                            },
                          );
                        },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Individuals with Increment/Decrement Buttons
              ValueListenableBuilder<int>(
                valueListenable: individualsNotifier,
                builder: (context, individuals, _) {
                  return Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (individuals > 1) {
                            individualsNotifier.value--;
                          }
                        },
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: TextEditingController(
                            text: individuals.toString(),
                          ),
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            labelText: 'Individuals',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => individualsNotifier.value =
                              int.tryParse(value) ?? 1,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => individualsNotifier.value++,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              // Activity and Notes
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Activity (Optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => activity = v,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Remarks (Optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => obsNotes = v,
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
              final finalSelectedTaxa = selectedTaxaNotifier.value;
              final finalScientificName =
                  finalSelectedTaxa?.scientificName ??
                  scientificNameController.text;
              final finalCommonName =
                  finalSelectedTaxa?.commonName ?? commonNameController.text;

              if (finalScientificName.isEmpty && finalCommonName.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Please select or enter a species name.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              final finalTaxaId =
                  finalSelectedTaxa?.id ??
                  finalScientificName.toLowerCase().replaceAll(' ', '_');

              setState(() {
                observations.add(
                  Observation(
                    id: observations.length + 1,
                    countId: 0,
                    userId: FirebaseAuth.instance.currentUser!.uid,
                    taxaId: finalTaxaId,
                    taxaCommonName: finalCommonName,
                    taxaScientificName: finalScientificName,
                    individuals: individualsNotifier.value,
                    activity: activity,
                    notes: obsNotes,
                    timestamp: DateTime.now(),
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

  // Helper function for highlighting text in Autocomplete suggestions
  TextSpan _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return TextSpan(text: text);
    }
    final List<TextSpan> spans = [];
    final lowercaseText = text.toLowerCase();
    final lowercaseQuery = query.toLowerCase();
    int start = 0;
    int indexOfMatch;
    while ((indexOfMatch = lowercaseText.indexOf(lowercaseQuery, start)) !=
        -1) {
      if (indexOfMatch > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfMatch)));
      }
      spans.add(
        TextSpan(
          text: text.substring(indexOfMatch, indexOfMatch + query.length),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      );
      start = indexOfMatch + query.length;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return TextSpan(children: spans);
  }
}
