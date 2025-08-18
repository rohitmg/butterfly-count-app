// lib/core/app_config.dart
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://butterflycounts.bigbutterflymonth.in/api', // Default for production
  );

  // Local development URL for Android Emulator
  static const String localApiBaseUrlAndroid = 'http://10.0.2.2:8000/api';

  // Local development URL for iOS Simulator, Web, or Desktop
  static const String localApiBaseUrlOther = 'http://localhost:8000/api';
}