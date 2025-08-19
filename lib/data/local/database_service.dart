// lib/data/local/database_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:butterfly_counts/data/models/count_model.dart'; // Updated from checklist.dart
import 'package:butterfly_counts/data/models/observation.dart';
import 'package:butterfly_counts/data/models/taxa.dart'; // Updated from taxon.dart
import 'package:butterfly_counts/data/models/user.dart'; // Assuming this is your local User model if you have one

// Import generated adapters for each model that uses Hive
import 'package:butterfly_counts/data/models/count_model.g.dart'; // NEW: If CountModel uses Hive
import 'package:butterfly_counts/data/models/observation.g.dart'; // NEW: If Observation uses Hive
import 'package:butterfly_counts/data/models/taxa.g.dart'; // NEW: If Taxa uses Hive (already in HiveService)
import 'package:butterfly_counts/data/models/user.g.dart'; // NEW: If User uses Hive

class DatabaseService {
  // Box names - Updated for consistency
  static const String _countModelBox = 'countModels'; // Renamed from _checklistBox
  static const String _observationBox = 'observations';
  static const String _taxaBox = 'taxa'; // Renamed from _taxonBox
  static const String _userBox = 'users';

  // Initialize Hive and register adapters
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters - Updated to new names
    // Only register if the model is actually Hive-annotated and has a generated adapter
    // You might remove these if you decide not to store these models in Hive directly
    Hive.registerAdapter(CountModelAdapter()); // Updated from ChecklistAdapter
    Hive.registerAdapter(ObservationAdapter());
    Hive.registerAdapter(TaxaAdapter()); // Updated from TaxonAdapter
    Hive.registerAdapter(UserAdapter()); // Assuming User model has a Hive adapter

    // Open all boxes - Updated to new names
    await Future.wait([
      Hive.openBox<CountModel>(_countModelBox), // Updated from Checklist
      Hive.openBox<Observation>(_observationBox),
      Hive.openBox<Taxa>(_taxaBox), // Updated from Taxon
      Hive.openBox<User>(_userBox),
    ]);
  }

  // Box getters - Updated for consistency
  static Box<CountModel> get countModels => Hive.box<CountModel>(_countModelBox); // Renamed getter
  static Box<Observation> get observations => Hive.box<Observation>(_observationBox);
  static Box<Taxa> get taxa => Hive.box<Taxa>(_taxaBox); // Renamed getter
  static Box<User> get users => Hive.box<User>(_userBox);

  // Helper methods
  static Future<void> clearAll() async {
    await countModels.clear(); // Updated
    await observations.clear();
    await taxa.clear(); // Updated
    await users.clear();
  }

  // Update seedDefaultTaxa to use the new Taxa model name
  static Future<void> seedDefaultTaxa() async {
    if (taxa.isEmpty) {
      await taxa.addAll([
        Taxa( // Updated from Taxon
          id: 'tax_1',
          scientificName: 'Danaus plexippus',
          commonName: 'Monarch',
          rank: 'species',
          ancestry: ['Danaus plexippus'], // Example ancestry as List<String>
          // Ensure all required fields are provided as per Taxa model constructor
          genus: 'Danaus',
          tribe: 'Danaini',
          subfamily: 'Danainae',
          family: 'Nymphalidae',
          inatId: null,
          notes: null
        ),
        // Add more default species...
      ]);
    }
  }
}