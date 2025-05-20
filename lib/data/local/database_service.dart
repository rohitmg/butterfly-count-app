import 'package:hive_flutter/hive_flutter.dart';
import '../models/checklist.dart';
import '../models/observation.dart';
import '../models/taxon.dart';
import '../models/user.dart';

class DatabaseService {
  // Box names
  static const String _checklistBox = 'checklists';
  static const String _observationBox = 'observations';
  static const String _taxonBox = 'taxa';
  static const String _userBox = 'users';

  // Initialize Hive and register adapters
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(ChecklistAdapter());
    Hive.registerAdapter(ObservationAdapter());
    Hive.registerAdapter(TaxonAdapter());
    Hive.registerAdapter(UserAdapter());

    // Open all boxes
    await Future.wait([
      Hive.openBox<Checklist>(_checklistBox),
      Hive.openBox<Observation>(_observationBox),
      Hive.openBox<Taxon>(_taxonBox),
      Hive.openBox<User>(_userBox),
    ]);
  }

  // Box getters
  static Box<Checklist> get checklists => Hive.box<Checklist>(_checklistBox);
  static Box<Observation> get observations => Hive.box<Observation>(_observationBox);
  static Box<Taxon> get taxa => Hive.box<Taxon>(_taxonBox);
  static Box<User> get users => Hive.box<User>(_userBox);

  // Helper methods
  static Future<void> clearAll() async {
    await checklists.clear();
    await observations.clear();
    await taxa.clear();
    await users.clear();
  }

  static Future<void> seedDefaultTaxa() async {
    if (taxa.isEmpty) {
      await taxa.addAll([
        Taxon(
          id: 'tax_1',
          scientificName: 'Danaus plexippus',
          commonName: 'Monarch',
          rank: 'species',
          ancestry: '1/2/3',
          preferenceWeight: 80,
        ),
        // Add more default species...
      ]);
    }
  }
}