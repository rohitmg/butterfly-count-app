import 'package:hive_flutter/hive_flutter.dart';
import '../models/butterfly_count.dart'

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    // Register adapters here (we'll create them next)
    Hive.registerAdapter(ButterflyCountAdapter());
    await Hive.openBox<ButterflyCount>('butterfly_counts');
  }
}