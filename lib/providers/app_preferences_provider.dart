// lib/providers/app_preferences_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

// Key for storing the preference in SharedPreferences
const String _openAccessPreferenceKey = 'openAccessPreference';

// Notifier to manage the global open access preference
class OpenAccessPreferenceNotifier extends StateNotifier<bool> {
  // We'll initialize with a default value, then load from SharedPreferences
  OpenAccessPreferenceNotifier() : super(false) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(_openAccessPreferenceKey) ?? false; // Default to false if not set
      if (kDebugMode) print('Loaded openAccessPreference: $state');
    } catch (e) {
      if (kDebugMode) print('Error loading openAccessPreference: $e');
      state = false; // Fallback to default on error
    }
  }

  Future<void> setOpenAccessPreference(bool value) async {
    state = value; // Update the state immediately
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_openAccessPreferenceKey, value); // Persist to storage
      if (kDebugMode) print('Saved openAccessPreference: $value');
    } catch (e) {
      if (kDebugMode) print('Error saving openAccessPreference: $e');
      // You might want to revert state or show an error to the user
    }
  }
}

// Provider for the global open access preference
final openAccessPreferenceProvider = StateNotifierProvider<OpenAccessPreferenceNotifier, bool>((ref) {
  return OpenAccessPreferenceNotifier();
});