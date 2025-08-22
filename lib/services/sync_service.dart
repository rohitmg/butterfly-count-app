// lib/services/sync_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; 

import 'package:butterfly_counts/services/api_service.dart';
import 'package:butterfly_counts/data/local/hive_service.dart';
import 'package:hive_flutter/hive_flutter.dart'; 
import 'package:hive/hive.dart'; 

import 'package:butterfly_counts/data/local/hive_service.dart';
import 'package:butterfly_counts/data/models/count_model.dart';
import 'package:butterfly_counts/providers/api_providers.dart';
import 'package:butterfly_counts/utils/snackbar_helper.dart';
import 'package:butterfly_counts/core/app_colors.dart';

// Provider for the SyncService
final syncServiceProvider = Provider<SyncService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  // Pass ref to the SyncService constructor if it needs to invalidate providers
  return SyncService(apiService: apiService, hiveService: hiveService, ref: ref);
});

class SyncService {
  final ApiService _apiService;
  final HiveService _hiveService;
  final Ref _ref; // To invalidate providers

  static const String _pendingSubmissionsBox = 'pendingSubmissionsBox';

  SyncService({required ApiService apiService, required HiveService hiveService, required Ref ref})
      : _apiService = apiService,
        _hiveService = hiveService,
        _ref = ref;

  Future<void> checkAndSubmitPendingForms(BuildContext context) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      if (kDebugMode) print('SyncService: No network connection. Skipping sync.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (kDebugMode) print('SyncService: User not logged in. Skipping sync.');
      return;
    }

    final idToken = await user.getIdToken();
    if (idToken == null) {
      if (kDebugMode) print('SyncService: ID token not available. Skipping sync.');
      return;
    }

    final pendingForms = await _hiveService.getPendingSubmissions();
    if (pendingForms.isEmpty) {
      if (kDebugMode) print('SyncService: No pending forms to submit.');
      return;
    }

    if (kDebugMode) print('SyncService: Found ${pendingForms.length} pending forms. Starting submission.');
    
    int successfulSubmissions = 0;
    
    final Box<CountModel> pendingBox = await _hiveService.getBox<CountModel>(_pendingSubmissionsBox);
    final Map<dynamic, CountModel> pendingMap = pendingBox.toMap();
    await pendingBox.close(); 

    for (final entry in pendingMap.entries) {
      final key = entry.key;
      final countData = entry.value;

      try {
        final countResponse = await _apiService.postCount(countData, idToken);
        if (countResponse.statusCode == 201) {
          final newCountJson = json.decode(countResponse.body);
          final newCountId = newCountJson['id'] as int;

          // Clear using the actual key
          await _hiveService.clearPendingSubmission(key); 
          successfulSubmissions++;
          
          if (kDebugMode) print('SyncService: Successfully submitted pending form with ID $newCountId.');

          // Refresh providers on successful sync
          _ref.invalidate(userStatsProvider);
          _ref.invalidate(recentCountsProvider);
        } else {
          if (kDebugMode) print('SyncService: Failed to submit pending form. Status: ${countResponse.statusCode}');
        }
      } catch (e) {
        if (kDebugMode) print('SyncService: Network or API error during sync: $e');
      }
    }

    if (successfulSubmissions > 0) {
      SnackBarHelper.showFloatingSnackBar(
        context, // Use the passed context for SnackBar
        message: 'Submitted $successfulSubmissions pending forms!',
        type: SnackBarType.success,
      );
    }
  }
}