// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode, defaultTargetPlatform;
import 'package:flutter/material.dart' show TargetPlatform; // Ensure TargetPlatform is available
import 'package:butterfly_counts/core/app_config.dart'; // Corrected import path
import 'package:butterfly_counts/data/models/count_model.dart'; // New import
import 'package:butterfly_counts/data/models/observation.dart'; 
import 'package:butterfly_counts/data/models/taxa.dart';

class ApiService {
  final String _baseUrl;

  // Constructor for easier testing or if you want to explicitly pass base URL
  ApiService({String? baseUrl})
    : _baseUrl =
          baseUrl ??
          (kDebugMode
              ? (defaultTargetPlatform == TargetPlatform.android
                    ? AppConfig
                          .localApiBaseUrlAndroid // Corrected reference
                    : AppConfig
                          .localApiBaseUrlOther // Corrected reference
                          )
              : AppConfig.apiBaseUrl);

  // Example: Fetch taxa
  Future<http.Response> fetchTaxa() {
    final uri = Uri.parse('$_baseUrl/taxa');
    return http.get(uri);
  }



  // Fetch user profile
  Future<http.Response> fetchUser(String uid, String? idToken) async {
    final uri = Uri.parse('$_baseUrl/users/$uid');
    if (kDebugMode) {
      print('ApiService: Fetching user from URL: $uri');
      print(
        'ApiService: Authorization Header: Bearer ${idToken?.substring(0, 20)}...',
      );
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

  // Fetch stats for the user
  Future<http.Response> fetchUserStats(String? idToken) async {
    final uri = Uri.parse('$_baseUrl/me/stats');
    final headers = {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    return http.get(uri, headers: headers);
  }

  // Fetch recent counts for the user
  Future<http.Response> fetchRecentCounts(
    String? idToken, {
    int limit = 5,
  }) async {
    final uri = Uri.parse('$_baseUrl/me/recent-counts?limit=$limit');
    final headers = {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    return http.get(uri, headers: headers);
  }


  Future<http.Response> postCount(CountModel count, String? idToken) async {
    final uri = Uri.parse('$_baseUrl/counts');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (idToken != null) {
      headers['Authorization'] = 'Bearer $idToken';
    }
    return http.post(uri, headers: headers, body: jsonEncode(count.toJson()));
  }

  // Post a new Observation record
  Future<http.Response> postObservation(Observation observation, String? idToken) async {
    final uri = Uri.parse('$_baseUrl/observations');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (idToken != null) {
      headers['Authorization'] = 'Bearer $idToken';
    }
    return http.post(uri, headers: headers, body: jsonEncode(observation.toJson()));
  }

  // Fetch all taxa for autocomplete/lookup
  Future<http.Response> fetchAllTaxa() async {
    final uri = Uri.parse('$_baseUrl/taxa'); // Assuming /api/taxa is public or handled by middleware
    return http.get(uri);
  }

  // Fetch the public taxa list with last_modified_timestamp
  Future<http.Response> fetchPublicTaxaList() async {
    final uri = Uri.parse('$_baseUrl/taxa-list');
    // No Authorization header needed as this is a public route
    return http.get(uri);
  }
}
