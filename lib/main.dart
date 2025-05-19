import 'package:flutter/material.dart';
import 'presentation/navigation/main_navigation_wrapper.dart'; // Add this import

void main() => runApp(const ButterflyCountApp());

class ButterflyCountApp extends StatelessWidget {
  const ButterflyCountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Butterfly Count',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainNavigationWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}