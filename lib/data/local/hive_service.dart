// lib/data/local/hive_service.dart
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:butterfly_counts/data/models/count_model.dart'; // Import CountModel
import 'package:butterfly_counts/data/models/observation.dart'; // Import Observation
import 'package:butterfly_counts/data/models/taxa.dart';
// Import generated adapters for other models if you intend to store them directly in Hive
class HiveService {
  static const String _taxaBox = 'masterTaxaList';
  static const String _pendingSubmissionsBox = 'pendingSubmissionsBox'; // Define the box name

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaxaAdapter()); 
     // NEW: Register adapters for CountModel and Observation if you intend to store them directly in Hive
    // You must add @HiveType and @HiveField annotations to these models first.
    Hive.registerAdapter(CountModelAdapter()); // Register CountModelAdapter
    Hive.registerAdapter(ObservationAdapter()); // Register ObservationAdapter
  }

  Future<Box<T>> getBox<T>(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<T>(boxName);
    }
    return Hive.box<T>(boxName);
  }

  Future<void> saveTaxa(List<Taxa> taxaList) async {
    final box = await Hive.openBox<Taxa>(_taxaBox);
    await box.clear();
    for (var taxa in taxaList) {
      await box.put(taxa.id, taxa);
    }
    await box.close();
  }

  Future<List<Taxa>> getTaxa() async {
    final box = await Hive.openBox<Taxa>(_taxaBox);
    final List<Taxa> taxaList = box.values.toList();
    await box.close();
    return taxaList;
  }


  // NEW: Method to save a CountModel to the pending submissions queue
  Future<void> savePendingSubmission(CountModel countData) async {
    final box = await getBox<CountModel>(_pendingSubmissionsBox);
    // Use a unique key for each pending submission, e.g., timestamp or UUID
    await box.put(DateTime.now().toIso8601String(), countData);
    // You might want to add a unique ID to CountModel if it doesn't have one before submission
    // For now, using timestamp as a simple key
    await box.close(); // Close the box after writing
  }

  // NEW: Method to retrieve pending submissions
  Future<List<CountModel>> getPendingSubmissions() async {
    final box = await getBox<CountModel>(_pendingSubmissionsBox);
    final List<CountModel> pending = box.values.toList();
    await box.close();
    return pending;
  }

  // NEW: Method to clear a specific pending submission after successful sync
  Future<void> clearPendingSubmission(String key) async {
    final box = await getBox<CountModel>(_pendingSubmissionsBox);
    await box.delete(key);
    await box.close();
  }
}