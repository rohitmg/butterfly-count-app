// lib/data/local/hive_service.dart
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:butterfly_counts/data/models/taxa.dart'; // Import your Taxa model

class HiveService {
  static const String _taxaBox = 'taxaBox';

  // Future<void> init() async {
  //   await Hive.initFlutter();
  //   Hive.registerAdapter(TaxaAdapter()); // Register the generated adapter
  // }

  Future<Box<T>> getBox<T>(String boxName) async {
    return await Hive.openBox<T>(boxName);
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
}