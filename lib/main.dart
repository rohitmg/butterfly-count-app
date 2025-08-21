import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:butterfly_counts/core/theme/theme_manager.dart';
import 'package:butterfly_counts/data/models/taxa.dart'; // Import the generated adapter for Taxa
import 'package:butterfly_counts/presentation/navigation/main_navigation_wrapper.dart';
import 'package:butterfly_counts/presentation/screens/LoginPage.dart';

// Your Firebase options file
import 'firebase_options.dart';

// Declare a GlobalKey for your MainNavigationWrapper's state
final GlobalKey<MainNavigationWrapperState> mainNavigationKey = GlobalKey<MainNavigationWrapperState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(TaxaAdapter());

  await SharedPreferences.getInstance();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider); 
    return MaterialApp(
      title: 'Butterfly Counts',
      theme: currentTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
              return MainNavigationWrapper(
              key: mainNavigationKey,
             );
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}