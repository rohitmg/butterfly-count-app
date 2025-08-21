import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/home/home_screen.dart';
import '../screens/count/butterfly_count_form.dart';
import '../screens/count/my_counts_screen.dart';
import '../screens/settings/settings_screen.dart';

// Remove the 'user' parameter from the constructor
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key}); // <--- REMOVED REQUIRED USER

  @override
  State<MainNavigationWrapper> createState() => MainNavigationWrapperState(); // <--- Changed to non-private for GlobalKey
}

// Make the State class non-private so GlobalKey can reference it
class MainNavigationWrapperState extends State<MainNavigationWrapper> { // <--- REMOVED UNDERSCORE
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(), // Ensure all children are const if possible
    const ButterflyCountForm(),
    const MyCountsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'New Count'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'My Counts'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}