// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode, defaultTargetPlatform;
import 'package:flutter/material.dart' show TargetPlatform; // Ensure TargetPlatform is available
import 'package:butterfly_counts/core/app_config.dart'; // Corrected import path

class ApiService {
  final String _baseUrl;

  // Constructor for easier testing or if you want to explicitly pass base URL
  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? (
    kDebugMode
      ? (
          defaultTargetPlatform == TargetPlatform.android
              ? AppConfig.localApiBaseUrlAndroid // Corrected reference
              : AppConfig.localApiBaseUrlOther // Corrected reference
        )
      : AppConfig.apiBaseUrl
  );

  // Example: Fetch taxa
  Future<http.Response> fetchTaxa() {
    final uri = Uri.parse('$_baseUrl/taxa');
    return http.get(uri);
  }

  // Example: Post a count
  Future<http.Response> postCount(Map<String, dynamic> data) {
    final uri = Uri.parse('$_baseUrl/counts');
    return http.post(uri, body: jsonEncode(data), headers: {'Content-Type': 'application/json'});
  }

  // Example: Fetch user profile
  Future<http.Response> fetchUser(String uid, String? idToken) async {
    final uri = Uri.parse('$_baseUrl/users/$uid');
    if (kDebugMode) {
      print('ApiService: Fetching user from URL: $uri');
      print('ApiService: Authorization Header: Bearer ${idToken?.substring(0, 20)}...');
    }
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (idToken != null) {
      headers['Authorization'] = 'Bearer $idToken';
    }
    return http.get(uri, headers: headers);
  }

  // ... other API methods as you add them
}
