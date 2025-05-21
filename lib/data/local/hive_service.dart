import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/checklist.dart';
import '../../data/models/observation.dart';
import '../../data/models/taxon.dart';
import '../../data/models/user.dart';

class HiveService {
  static const String checklistBoxName = 'checklists';
  static const String observationBoxName = 'observations';
  static const String taxonBoxName = 'taxa';
  static const String userBoxName = 'users';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(ChecklistAdapter());
    Hive.registerAdapter(ObservationAdapter());
    Hive.registerAdapter(TaxonAdapter());
    Hive.registerAdapter(UserAdapter());

    // Open all boxes
    await Future.wait([
      Hive.openBox<Checklist>(checklistBoxName),
      Hive.openBox<Observation>(observationBoxName),
      Hive.openBox<Taxon>(taxonBoxName),
      Hive.openBox<User>(userBoxName),
    ]);
  }

  // Box getters
  static Box<Checklist> get checklists => Hive.box<Checklist>(checklistBoxName);
  static Box<Observation> get observations => Hive.box<Observation>(observationBoxName);
  static Box<Taxon> get taxa => Hive.box<Taxon>(taxonBoxName);
  static Box<User> get users => Hive.box<User>(userBoxName);

  static Future<void> clearAll() async {
    await checklists.clear();
    await observations.clear();
    await taxa.clear();
    await users.clear();
  }
}