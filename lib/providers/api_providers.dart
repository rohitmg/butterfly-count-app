// lib/providers/api_providers.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:butterfly_counts/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:butterfly_counts/data/models/user_stats.dart';
import 'package:butterfly_counts/data/models/recent_count.dart';
import 'package:butterfly_counts/data/models/count_model.dart';
import 'package:butterfly_counts/data/models/observation.dart';
import 'package:butterfly_counts/data/models/taxa.dart';
import 'package:butterfly_counts/data/local/hive_service.dart'; // Ensure this import is correct

// --- Core API and Auth Providers ---

// Provider for ApiService instance
final apiServiceProvider = Provider<ApiService>((ref) {
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

// Provider to fetch the current user's profile from your Laravel API
final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final idToken = await ref.watch(firebaseIdTokenProvider.future);

  final firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser == null) {
    throw Exception('User not logged in.');
  }

  final response = await apiService.fetchUser(firebaseUser.uid, idToken);

  if (response.statusCode == 200) {
    return json.decode(response.body) as Map<String, dynamic>;
  } else if (response.statusCode == 401) {
    throw Exception('Authentication failed. Please log in again.');
  } else {
    throw Exception(
      'Failed to load user profile: ${response.statusCode} - ${response.body}',
    );
  }
});

// Provider to fetch user-specific statistics
final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final idToken = await ref.watch(firebaseIdTokenProvider.future);

  if (FirebaseAuth.instance.currentUser == null) {
    throw Exception('User not logged in to fetch stats.');
  }

  final response = await apiService.fetchUserStats(idToken);
  if (response.statusCode == 200) {
    return UserStats.fromJson(json.decode(response.body));
  } else {
    throw Exception(
      'Failed to load user stats: ${response.statusCode} - ${response.body}',
    );
  }
});

// Provider to fetch recent counts
final recentCountsProvider = FutureProvider<List<RecentCount>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final idToken = await ref.watch(firebaseIdTokenProvider.future);

  if (FirebaseAuth.instance.currentUser == null) {
    return [];
  }

  final response = await apiService.fetchRecentCounts(idToken);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => RecentCount.fromJson(json)).toList();
  } else {
    throw Exception(
      'Failed to load recent counts: ${response.statusCode} - ${response.body}',
    );
  }
});

// --- Local Storage Providers ---

// Provider for HiveService instance
// This must be defined as a top-level provider.
final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

// --- Data Lookup/Submission Providers ---

// Provider to fetch all taxa for selection/autocomplete with caching
final allTaxaProvider = FutureProvider<List<Taxa>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final hiveService = ref.watch(
    hiveServiceProvider,
  ); // hiveServiceProvider is now correctly in scope

  // Define keys for Hive storage of taxa list and its timestamp
  const String taxaListKey =
      'masterTaxaList'; // Name for the box storing Taxa objects
  const String lastModifiedTimestampKey =
      'masterTaxaListLastModified'; // Key for the timestamp within a box

  // 1. Try to load from local cache first
  try {
    // Open the box for taxa list
    final taxaBox = await hiveService.getBox<Taxa>(taxaListKey);
    final cachedTaxa = taxaBox.values.toList();
    await taxaBox.close(); // Close the box after reading

    // Open the box for the timestamp
    final timestampBox = await hiveService.getBox<String>(
      lastModifiedTimestampKey,
    );
    final cachedTimestamp = timestampBox.get(lastModifiedTimestampKey);
    await timestampBox.close(); // Close the box after reading

    if (cachedTaxa.isNotEmpty && cachedTimestamp != null) {
      if (kDebugMode)
        print(
          'allTaxaProvider: Loaded taxa from cache. Cached timestamp: $cachedTimestamp',
        );

      // 2. Fetch the latest timestamp from the API to check for updates
      final response = await apiService.fetchPublicTaxaList();
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = json.decode(response.body);
        final String? latestTimestamp = apiResponse['last_modified_timestamp'];

        if (latestTimestamp != null && latestTimestamp == cachedTimestamp) {
          if (kDebugMode)
            print('allTaxaProvider: Cached taxa list is up-to-date.');
          return cachedTaxa; // Return cached data if timestamps match
        } else {
          if (kDebugMode)
            print(
              'allTaxaProvider: Cached taxa list is outdated or API has no timestamp. Fetching new list.',
            );
          // Continue to fetch new list if timestamps don't match or latestTimestamp is null
        }
      } else {
        if (kDebugMode)
          print(
            'allTaxaProvider: Failed to check for latest timestamp (${response.statusCode}). Attempting to return cached data if available.',
          );
        return cachedTaxa; // Fallback to cached if API check fails
      }
    }
  } catch (e) {
    if (kDebugMode)
      print(
        'allTaxaProvider: Error during cache check or reading: $e. Proceeding to fetch from API.',
      );
    // Continue to fetch from API if cache fails
  }

  // 3. If not in cache, fetch from API
  try {
    final response = await apiService.fetchPublicTaxaList();
    if (response.statusCode == 200) {
      final Map<String, dynamic> apiResponse = json.decode(response.body);
      final List<dynamic> data = apiResponse['data'];
      final String? latestTimestamp = apiResponse['last_modified_timestamp'];

      final List<Taxa> fetchedTaxa = data
          .map((json) => Taxa.fromJson(json))
          .toList();

      // 4. Save to local cache
      final taxaBox = await hiveService.getBox<Taxa>(taxaListKey);
      await taxaBox.clear(); // Clear existing taxa before saving new list
      for (var taxa in fetchedTaxa) {
        await taxaBox.put(taxa.id, taxa); // Store by ID for easy lookup
      }
      await taxaBox.close(); // Close the box after writing

      if (latestTimestamp != null) {
        final timestampBox = await hiveService.getBox<String>(
          lastModifiedTimestampKey,
        );
        await timestampBox.put(lastModifiedTimestampKey, latestTimestamp);
        await timestampBox.close();
      }
      if (kDebugMode)
        print('allTaxaProvider: Fetched new taxa list from API and cached.');
      return fetchedTaxa;
    } else {
      throw Exception(
        'Failed to load taxa from API: ${response.statusCode} - ${response.body}',
      );
    }
  } catch (e) {
    if (kDebugMode)
      print('allTaxaProvider: Caught error fetching taxa from API: $e');
    rethrow;
  }
});

// StateNotifierProvider for managing the Count submission process
class CountSubmissionNotifier extends StateNotifier<AsyncValue<int?>> {
  final ApiService _apiService;
  final FirebaseAuth _firebaseAuth;
  final Ref _ref;

  CountSubmissionNotifier(this._apiService, this._firebaseAuth, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> submitCountAndObservations({
    required CountModel countData,
    required List<Observation> observationsData,
  }) async {
    state = const AsyncValue.loading(); // Set loading state

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('User not logged in. Cannot submit count.');
      }
      final idToken = await user.getIdToken();

      // 1. Submit the Count
      final countResponse = await _apiService.postCount(countData, idToken);
      if (countResponse.statusCode != 201) {
        throw Exception(
          'Failed to submit count: ${countResponse.statusCode} - ${countResponse.body}',
        );
      }
      final newCountJson = json.decode(countResponse.body);
      final newCountId =
          newCountJson['id'] as int; // Get the ID from Laravel's response

      // 2. Submit Observations, linking them to the new Count ID
      for (var obs in observationsData) {
        final observationToSubmit = Observation(
          id: obs.id, // ID will be ignored for new creation
          countId: newCountId, // Link to the newly created count
          userId: user.uid, // Ensure user ID is passed
          taxaId: obs.taxaId,
          taxaCommonName: obs.taxaCommonName,
          taxaScientificName: obs.taxaScientificName,
          individuals: obs.individuals,
          activity: obs.activity,
          notes: obs.notes,
          timestamp: obs.timestamp,
        );
        final obsResponse = await _apiService.postObservation(
          observationToSubmit,
          idToken,
        );
        if (obsResponse.statusCode != 201) {
          throw Exception(
            'Failed to submit observation for ${obs.taxaCommonName}: ${obsResponse.statusCode} - ${obsResponse.body}',
          );
        }
      }

      state = AsyncValue.data(
        newCountId,
      ); // Set success state with the new count ID
      _ref.invalidate(userStatsProvider); // Refresh stats on home screen
      _ref.invalidate(
        recentCountsProvider,
      ); // Refresh recent counts on home screen
    } catch (e, st) {
      if (kDebugMode) print('Count submission error: $e\n$st');
      state = AsyncValue.error(e, st); // Set error state
    }
  }
}

final countSubmissionProvider =
    StateNotifierProvider<CountSubmissionNotifier, AsyncValue<int?>>((ref) {
      return CountSubmissionNotifier(
        ref.watch(apiServiceProvider),
        FirebaseAuth.instance,
        ref, // Pass ref to invalidate other providers
      );
    });

//Provider to check local taxa cache status and last updated timestamp
final localTaxaStatusProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final hiveService = ref.watch(hiveServiceProvider);
  const String taxaListKey = 'masterTaxaList';
  const String lastModifiedTimestampKey = 'masterTaxaListLastModified';

  try {
    final taxaBox = await hiveService.getBox<Taxa>(taxaListKey);
    final isCached = taxaBox.isNotEmpty;
    await taxaBox.close(); // Close the box after checking

    final timestampBox = await hiveService.getBox<String>(
      lastModifiedTimestampKey,
    );
    final lastUpdated = timestampBox.get(lastModifiedTimestampKey);
    await timestampBox.close(); // Close the box

    return {'is_cached': isCached, 'last_updated': lastUpdated};
  } catch (e) {
    if (kDebugMode) print('Error checking local taxa status: $e');
    return {'is_cached': false, 'last_updated': null};
  }
});
