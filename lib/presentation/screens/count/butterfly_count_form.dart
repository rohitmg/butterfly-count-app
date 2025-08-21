import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Data models and providers
import 'package:butterfly_counts/data/models/count_model.dart';
import 'package:butterfly_counts/data/models/observation.dart';
import 'package:butterfly_counts/data/models/taxa.dart';
import 'package:butterfly_counts/providers/api_providers.dart';
import 'package:butterfly_counts/providers/app_preferences_provider.dart';
import 'package:butterfly_counts/utils/snackbar_helper.dart';
import 'package:butterfly_counts/core/app_colors.dart';

// Sub-pages
import 'package:butterfly_counts/presentation/screens/count/basic_info_page.dart';
import 'package:butterfly_counts/presentation/screens/count/location_page.dart';
import 'package:butterfly_counts/presentation/screens/count/checklist_page.dart';

class ButterflyCountForm extends ConsumerStatefulWidget {
  // NEW: Add a callback to notify the parent about successful submission
  final VoidCallback onSubmissionSuccess;
  final ValueChanged<bool> onUnsavedChanges;

  const ButterflyCountForm({Key? key, required this.onSubmissionSuccess, required this.onUnsavedChanges}) : super(key: key);

  @override
  ConsumerState<ButterflyCountForm> createState() => _ButterflyCountFormState();
}

class _ButterflyCountFormState extends ConsumerState<ButterflyCountForm> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form data (managed by this root stateful widget)
  String? teamName;
  DateTime selectedDate = DateTime.now();
  DateTime startTime = DateTime.now();
  DateTime? endTime;
  late bool openAccess; // Initialized in initState from preferences

  double? latitude, longitude, altitude, accuracy;
  String weather = 'Sunny';
  String? comments; // Corresponds to 'notes' in CountModel

  final List<Observation> observations = []; // List of observations for the current count

  /// Timer for checklist page duration
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  // Controllers for text fields to pre-fill with current location
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _altitudeController = TextEditingController();
  final TextEditingController _accuracyController = TextEditingController();
  final TextEditingController _placeNameController = TextEditingController();

  // New: Internal flag for unsaved changes
  bool _hasChanges = false;
  
  // NEW: Method to set the internal _hasChanges flag and notify the parent
  void _setChangesFlag(bool hasChanges) {
    if (_hasChanges != hasChanges) {
      setState(() => _hasChanges = hasChanges);
      widget.onUnsavedChanges(hasChanges);
    }
  }

  // NEW: A simple helper to check if the form is dirty
  bool get _isFormDirty =>
      teamName != null ||
      comments != null ||
      observations.isNotEmpty ||
      latitude != null ||
      _latitudeController.text.isNotEmpty; // Check controllers too


  @override
  void initState() {
    super.initState();
    _startTimer();
    // Initialize openAccess from the preference provider
    openAccess = ref.read(openAccessPreferenceProvider);
    _getLocation(); // Fetch initial location on form load
  }

  @override
  void didUpdateWidget(covariant ButterflyCountForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update text controllers if location changes (e.g., after _getLocation)
    _latitudeController.text = latitude?.toStringAsFixed(7) ?? '';
    _longitudeController.text = longitude?.toStringAsFixed(7) ?? '';
    _altitudeController.text = altitude?.toStringAsFixed(2) ?? '';
    _accuracyController.text = accuracy?.toStringAsFixed(2) ?? '';
    
    // NEW: Update the parent about changes when widget state changes
    _setChangesFlag(_isFormDirty);
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _elapsed = Duration.zero; // Reset elapsed time
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
    // NEW: Notify parent that widget is disposed (no more changes)
    widget.onUnsavedChanges(false);
  }

  // --- Callbacks to update state from child pages ---
  void _updateTeamName(String? value) {
    setState(() => teamName = value);
    _setChangesFlag(_isFormDirty);
  }
  void _updateSelectedDate(DateTime value) {
    setState(() {
      selectedDate = value;
      startTime = DateTime(
        value.year, value.month, value.day,
        startTime.hour, startTime.minute,
      );
      if (endTime != null) {
        endTime = DateTime(
          value.year, value.month, value.day,
          endTime!.hour, endTime!.minute,
        );
      }
    });
    _setChangesFlag(_isFormDirty);
  }
  void _updateStartTime(DateTime value) {
    setState(() {
      startTime = value;
      if (endTime != null && !endTime!.isAfter(startTime)) {
        endTime = startTime.add(const Duration(hours: 1));
      }
    });
    _setChangesFlag(_isFormDirty);
  }
  void _updateEndTime(DateTime? value) {
    if (value != null && !value.isAfter(startTime)) {
      SnackBarHelper.showFloatingSnackBar(
        context,
        message: 'End time must be after start time',
        type: SnackBarType.warning,
      );
      return;
    }
    setState(() => endTime = value);
    _setChangesFlag(_isFormDirty);
  }
  void _updateOpenAccess(bool value) {
    setState(() => openAccess = value);
    _setChangesFlag(_isFormDirty);
  }

  void _updateLatitude(String? value) {
    setState(() => latitude = double.tryParse(value ?? ''));
    _setChangesFlag(_isFormDirty);
  }
  void _updateLongitude(String? value) {
    setState(() => longitude = double.tryParse(value ?? ''));
    _setChangesFlag(_isFormDirty);
  }
  void _updateAltitude(String? value) {
    setState(() => altitude = double.tryParse(value ?? ''));
    _setChangesFlag(_isFormDirty);
  }
  void _updateAccuracy(String? value) {
    setState(() => accuracy = double.tryParse(value ?? ''));
    _setChangesFlag(_isFormDirty);
  }
  void _updatePlaceName(String? value) {
    setState(() => _placeNameController.text = value ?? '');
    _setChangesFlag(_isFormDirty);
  }
  void _updateWeather(String? value) {
    setState(() => weather = value ?? 'Sunny');
    _setChangesFlag(_isFormDirty);
  }
  void _updateComments(String? value) {
    setState(() => comments = value);
    _setChangesFlag(_isFormDirty);
  }

  void _addObservation(Observation obs) {
    setState(() {
      observations.add(obs);
    });
    _setChangesFlag(_isFormDirty);
  }

  void _deleteObservation(Observation obs) {
    setState(() {
      observations.removeWhere((o) => o.id == obs.id);
    });
    _setChangesFlag(_isFormDirty);
  }

  // --- Navigation Logic ---
  void _goToPage(int i) {
    if (i == 2 && (latitude == null || longitude == null)) {
      SnackBarHelper.showFloatingSnackBar(
        context,
        message: 'Please set location first',
        type: SnackBarType.warning,
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

  // --- Location Retrieval ---
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
      _setChangesFlag(_isFormDirty);
      SnackBarHelper.showFloatingSnackBar(
        context,
        message: 'Location updated!',
        type: SnackBarType.info,
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
        _setChangesFlag(_isFormDirty);
        SnackBarHelper.showFloatingSnackBar(
          context,
          message:
              'Geolocation not supported/failed. Using demo coordinates (Delhi).',
          type: SnackBarType.warning,
        );
      } else {
        SnackBarHelper.showFloatingSnackBar(
          context,
          message: 'Error getting location: ${e.toString()}',
          type: SnackBarType.danger,
        );
      }
    }
  }

  // --- Form Submission ---
  Future<void> _submitForm() async {
    final countSubmissionNotifier = ref.read(countSubmissionProvider.notifier);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      SnackBarHelper.showFloatingSnackBar(
        context,
        message: 'You must be logged in to submit a count.',
        type: SnackBarType.danger,
      );
      return;
    }

    if (latitude == null || longitude == null) {
      SnackBarHelper.showFloatingSnackBar(
        context,
        message: 'Please set a valid location before submitting.',
        type: SnackBarType.warning,
      );
      return;
    }

    if (observations.isEmpty) {
      SnackBarHelper.showFloatingSnackBar(
        context,
        message: 'Please add at least one observation.',
        type: SnackBarType.warning,
      );
      return;
    }

    endTime ??= DateTime.now(); // Ensure endTime is set if not picked

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
      distanceCovered: null, // Not collected in UI yet
      weather: weather,
      notes: comments,
      version: '1.0.0', // Hardcode for now
      observations: observations, // Pass the observations list
    );

    await countSubmissionNotifier.submitCountAndObservations(
      countData: countData,
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

    // Listen for submission success/error
    ref.listen<AsyncValue<int?>>(countSubmissionProvider, (previous, next) {
      next.whenOrNull(
        data: (countId) {
          if (countId != null) {
            SnackBarHelper.showFloatingSnackBar(
              context,
              message: 'Count submitted successfully! ID: $countId',
              type: SnackBarType.success, // Use success type
            );
            widget.onSubmissionSuccess();
          }
        },
        error: (err, stack) {
          // Check for network-related errors to suggest offline queue
          final errorMessage = err.toString();
          SnackBarType snackBarType = SnackBarType.danger;
          String message = 'Submission failed: $errorMessage';

          if (errorMessage.contains('Failed host lookup') ||
              errorMessage.contains('Network is unreachable') ||
              errorMessage.contains('Connection refused')) {
            message = 'No network connection. Form added to submission queue.';
            snackBarType = SnackBarType.warning; // Use warning for queued
          } else if (errorMessage.contains('401 Unauthorized')) {
            message =
                'Submission failed: You are not authorized. Please log in again.';
            snackBarType = SnackBarType.danger;
          }

          SnackBarHelper.showFloatingSnackBar(
            context,
            message: message,
            type: snackBarType,
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Butterfly Count'),
        actions: [
          // Only show submit button on the last page
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
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                // Pass state and callbacks to BasicInfoPage
                BasicInfoPage(
                  teamName: teamName,
                  selectedDate: selectedDate,
                  startTime: startTime,
                  endTime: endTime,
                  openAccess: openAccess,
                  onTeamNameChanged: _updateTeamName,
                  onDateSelected: _updateSelectedDate,
                  onStartTimeSelected: _updateStartTime,
                  onEndTimeSelected: _updateEndTime,
                  onOpenAccessChanged: _updateOpenAccess,
                ),
                // Pass state and callbacks to LocationPage
                LocationPage(
                  latitudeController: _latitudeController,
                  longitudeController: _longitudeController,
                  altitudeController: _altitudeController,
                  accuracyController: _accuracyController,
                  placeNameController: _placeNameController,
                  weather: weather,
                  comments: comments,
                  onUseCurrentLocation: _getLocation, // Pass the location method
                  onLatitudeChanged: _updateLatitude,
                  onLongitudeChanged: _updateLongitude,
                  onAltitudeChanged: _updateAltitude,
                  onAccuracyChanged: _updateAccuracy,
                  onPlaceNameChanged: _updatePlaceName,
                  onWeatherChanged: _updateWeather,
                  onCommentsChanged: _updateComments,
                ),
                // Pass state and callbacks to ChecklistPage
                ChecklistPage(
                  observations: observations,
                  elapsedDuration: _elapsed,
                  submissionState: submissionState,
                  onAddObservation: _addObservation,
                  onDeleteObservation: _deleteObservation,
                  onSubmitForm: _submitForm,
                ),
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

  // Helper for bottom navigation tabs (remains in root)
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
            SnackBarHelper.showFloatingSnackBar(
              context,
              message: 'Please set location first',
              type: SnackBarType.warning,
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
}