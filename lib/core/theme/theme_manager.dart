// lib/core/theme/theme_manager.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For persisting theme preference

// Key for SharedPreferences
const String _kThemeBrightnessKey = 'themeBrightness';

// The ThemeNotifier manages the ThemeData directly
class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(ThemeData.light()) { // Start with a default light theme
    _loadTheme(); // Load saved theme on initialization
  }

  // Define your themes
  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    // Add other light theme specific properties
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[100],
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey[600],
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blueGrey,
    // Add other dark theme specific properties
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[900],
      selectedItemColor: Colors.lightBlue[200],
      unselectedItemColor: Colors.grey[500],
    ),
  );

  // Load theme preference from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_kThemeBrightnessKey) ?? false; // Default to light
    state = isDark ? _darkTheme : _lightTheme;
  }

  // Toggle theme and save preference
  void toggleTheme() {
    final newTheme = state.brightness == Brightness.dark ? _lightTheme : _darkTheme;
    state = newTheme; // Update the theme state

    // Persist the new preference
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(_kThemeBrightnessKey, newTheme.brightness == Brightness.dark);
    });
  }

  // You can also expose methods to set specific themes if needed
  void setLightTheme() {
    state = _lightTheme;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(_kThemeBrightnessKey, false);
    });
  }

  void setDarkTheme() {
    state = _darkTheme;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(_kThemeBrightnessKey, true);
    });
  }
}

// The main theme provider that exposes the current ThemeData
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});