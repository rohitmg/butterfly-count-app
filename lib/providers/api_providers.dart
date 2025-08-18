// lib/providers/api_providers.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:butterfly_counts/services/api_service.dart'; // Adjust path as needed
import 'package:firebase_auth/firebase_auth.dart'; // For getting the ID token
import 'package:flutter/foundation.dart';

final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final idToken = await ref.watch(firebaseIdTokenProvider.future);
  final firebaseUser = FirebaseAuth.instance.currentUser;

  if (kDebugMode) {
    print('userProfileProvider: Firebase User UID: ${firebaseUser?.uid}');
    print('userProfileProvider: Firebase ID Token (first 20 chars): ${idToken?.substring(0, 20)}...');
  }

  if (firebaseUser == null) {
    if (kDebugMode) print('userProfileProvider: User is NULL, throwing error.');
    throw Exception('User not logged in.');
  }

  try {
    final response = await apiService.fetchUser(firebaseUser.uid, idToken);

    if (kDebugMode) {
      print('userProfileProvider: API Response Status: ${response.statusCode}');
      print('userProfileProvider: API Response Body: ${response.body}');
    }

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    if (kDebugMode) print('userProfileProvider: Caught error during API call: $e');
    rethrow; // Re-throw to propagate to the .when() error handler
  }
});

// Provider for the ApiService instance
final apiServiceProvider = Provider<ApiService>((ref) {
  // You can pass the base URL here if you have different environments
  return ApiService();
});

// Provider for the current Firebase User's ID Token
final firebaseIdTokenProvider = FutureProvider<String?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return await user.getIdToken();
  }
  return null;
});

// // Provider to fetch the current user's profile from your Laravel API
// final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
//   final apiService = ref.watch(apiServiceProvider);
//   final idToken = await ref.watch(firebaseIdTokenProvider.future); // Await the token

//   final firebaseUser = FirebaseAuth.instance.currentUser;
//   if (firebaseUser == null) {
//     throw Exception('User not logged in.'); // Handle not logged in state
//   }

//   // Assuming your Laravel API has an endpoint like GET /api/users/{uid}
//   // and it's protected by your Firebase Auth middleware.
//   // The middleware will automatically create the user in your DB if they don't exist.
//   final response = await apiService.fetchUser(firebaseUser.uid, idToken);

//   if (response.statusCode == 200) {
//     return response.body as Map<String, dynamic>; // Assuming response.body is already decoded Map
//   } else if (response.statusCode == 401) {
//     throw Exception('Authentication failed. Please log in again.');
//   } else {
//     throw Exception('Failed to load user profile: ${response.statusCode}');
//   }
// });

// You might also want a provider for total counts, recent activity, etc.
// For now, let's just get the user profile.