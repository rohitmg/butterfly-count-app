// lib/data/local/hive_service.dart
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:butterfly_counts/data/models/count_model.dart'; // Import CountModel
import 'package:butterfly_counts/data/models/observation.dart'; // Import Observation
import 'package:butterfly_counts/data/models/taxa.dart';
// Import generated adapters for other models if you intend to store them directly in Hive
class HiveService {
  static const String _taxaBox = 'masterTaxaList';
  static const String _pendingSubmissionsBox = 'pendingSubmissionsBox'; 
  static const String _inProgressCountBox = 'inProgressCountBox';

  Future<Box<T>> getBox<T>(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<T>(boxName);
    }
    return Hive.box<T>(boxName);
  }

// Specific method to save the main taxa list
  Future<void> saveTaxa(List<Taxa> taxaList) async {
    final box = await Hive.openBox<Taxa>(_taxaBox);
    await box.clear();
    for (var taxa in taxaList) {
      await box.put(taxa.id, taxa);
    }
        // Do NOT close the box here. It can remain open.
    // If you need to explicitly close, manage it at a higher level (e.g., app shutdown).
    // await box.close();
  }

  // Specific method to get the main taxa list
  Future<List<Taxa>> getTaxa() async {
    final box = await Hive.openBox<Taxa>(_taxaBox);
    final List<Taxa> taxaList = box.values.toList();
    return taxaList;
  }


  // Save a CountModel to the pending submissions queue
  Future<void> savePendingSubmission(CountModel countData) async {
    final box = await getBox<CountModel>(_pendingSubmissionsBox);
    
    await box.put(DateTime.now().toIso8601String(), countData);
  }

  // Retrieve pending submissions
  Future<List<CountModel>> getPendingSubmissions() async {
    final box = await getBox<CountModel>(_pendingSubmissionsBox);
    final List<CountModel> pending = box.values.toList();
    
    return pending;
  }

  // Clear a specific pending submission after successful sync
  Future<void> clearPendingSubmission(String key) async {
    final box = await getBox<CountModel>(_pendingSubmissionsBox);
    await box.delete(key);
  }

  // NEW: Methods for in-progress count state
  Future<void> saveInProgressCount(String key, Map<String, dynamic> countState) async {
    final box = await getBox<Map<String, dynamic>>(_inProgressCountBox);
    await box.put(key, countState);
    // Do NOT close the box here.
  }

  Future<Map<String, dynamic>?> loadInProgressCount(String key) async {
    final box = await getBox<Map<String, dynamic>>(_inProgressCountBox);
    final savedState = box.get(key);
    // Do NOT close the box here.
    return savedState;
  }

  Future<void> clearInProgressCount(String key) async {
    final box = await getBox<Map<String, dynamic>>(_inProgressCountBox);
    await box.delete(key);
    // Do NOT close the box here.
  }
}