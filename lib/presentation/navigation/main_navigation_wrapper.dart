// lib/presentation/navigation/main_navigation_wrapper.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:butterfly_counts/utils/snackbar_helper.dart';
import 'package:butterfly_counts/core/app_colors.dart';

// Import the sub-pages
import '../screens/home/home_screen.dart';
import '../screens/count/butterfly_count_form.dart';
import '../screens/count/my_counts_screen.dart';
import '../screens/settings/settings_screen.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => MainNavigationWrapperState();
}

class MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  bool _hasUnsavedChanges = false;

  void _updateUnsavedChanges(bool hasChanges) {
    if (mounted) {
      setState(() => _hasUnsavedChanges = hasChanges);
    }
  }

  // NEW: Callback to navigate to the home screen
  void _navigateToHome() {
    setState(() {
      _currentIndex = 0;
      _hasUnsavedChanges = false; // Reset changes flag
    });
    // The Navigator will still have the form page on the stack
    // so we need to pop that off. This is a bit complex.
    // The simplest way is to ensure the form is cleared, and MainNavigationWrapper
    // just stays on the home screen index.
  }

  // Pages list
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      // Pass the callbacks to ButterflyCountForm
      ButterflyCountForm(
        onUnsavedChanges: _updateUnsavedChanges,
        onSubmissionSuccess: _navigateToHome, // Pass the new callback here
      ),
      const MyCountsScreen(),
      const SettingsScreen(),
    ];
  }

  Future<void> _showUnsavedChangesDialog(int newIndex) async {
    final bool? shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
            'You have unsaved changes in your count form. Do you want to discard them and navigate away?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Discard'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldDiscard == true) {
      // Navigate to the new page and reset the changes flag
      setState(() {
        _hasUnsavedChanges = false;
        _currentIndex = newIndex;
      });
      SnackBarHelper.showFloatingSnackBar(
        context,
        message: 'Changes have been discarded.',
        type: SnackBarType.info,
      );
    }
  }

  void _onItemTapped(int index) {
    if (_hasUnsavedChanges && _currentIndex == 1 && index != 1) {
      _showUnsavedChangesDialog(index);
    } else {
      setState(() {
        _currentIndex = index;
        if(_currentIndex != 1) {
          _hasUnsavedChanges = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
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
