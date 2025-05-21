import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/local/database_service.dart';
import 'core/theme/theme_provider.dart';
import 'presentation/navigation/main_navigation_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.init();
  await DatabaseService.seedDefaultTaxa();

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
    // This is just a bool (true for dark mode, false for light)
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Butterfly Count',
      theme: ThemeData.light(), // Always define light theme
      darkTheme: ThemeData.dark(), // Always define dark theme
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainNavigationWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
