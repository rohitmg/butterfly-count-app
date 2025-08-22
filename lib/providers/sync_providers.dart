import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:butterfly_counts/data/local/hive_service.dart';
import 'package:butterfly_counts/data/models/count_model.dart';
import 'package:butterfly_counts/providers/api_providers.dart'; 

// Provider to stream network connectivity status
final networkStatusProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

// Provider to get the list of pending forms from Hive
final pendingFormsProvider = FutureProvider<List<CountModel>>((ref) async {
  final hiveService = ref.read(hiveServiceProvider);
  return hiveService.getPendingSubmissions();
});
