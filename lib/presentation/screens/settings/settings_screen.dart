// lib/presentation/screens/settings/settings_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:butterfly_counts/core/theme/theme_manager.dart';
import 'package:butterfly_counts/providers/api_providers.dart';
import 'package:butterfly_counts/data/models/taxa.dart';
import 'package:butterfly_counts/providers/app_preferences_provider.dart';
import 'package:butterfly_counts/utils/snackbar_helper.dart';
import 'package:butterfly_counts/data/auth/auth_service.dart'; // NEW: Import AuthService
import 'package:butterfly_counts/presentation/screens/LoginPage.dart'; // NEW: Import LoginPage
import 'package:butterfly_counts/core/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // NEW: Logout method
  Future<void> _logout(BuildContext context) async {
    try {
      await AuthService().signOut();
      SnackBarHelper.showFloatingSnackBar(
        context,
        message: 'Logged out successfully!',
        type: SnackBarType.success,
      );
      // Navigate back to login page after logout
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false, // Clear all previous routes
      );
    } catch (e) {
      SnackBarHelper.showFloatingSnackBar(
        context,
        message: 'Logout failed: ${e.toString()}',
        type: SnackBarType.danger,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final isDarkMode = currentTheme.brightness == Brightness.dark;
    
    final localTaxaStatusAsync = ref.watch(localTaxaStatusProvider);
    final openAccessPreference = ref.watch(openAccessPreferenceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (value) {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          const Divider(),

          SwitchListTile(
            title: const Text('Default Open Access'),
            subtitle: const Text('Make your counts publicly visible by default'),
            value: openAccessPreference,
            onChanged: (value) => ref.read(openAccessPreferenceProvider.notifier).setOpenAccessPreference(value),
          ),
          const Divider(),

          localTaxaStatusAsync.when(
            data: (status) {
              final isCached = status['is_cached'] as bool;
              final lastUpdatedString = status['last_updated'] as String?;
              DateTime? lastUpdatedDate;
              if (lastUpdatedString != null) {
                try {
                  lastUpdatedDate = DateTime.parse(lastUpdatedString);
                } catch (e) {
                  lastUpdatedDate = null;
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text('Taxa List'),
                    subtitle: Text(
                      isCached
                          ? (lastUpdatedDate != null
                                ? 'Last updated: ${DateFormat.yMd().add_jm().format(lastUpdatedDate)}'
                                : 'Cached (date unknown)')
                          : 'Not downloaded',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        final scaffold = ScaffoldMessenger.of(context);

                        // Show loading snackbar
                        final loadingSnackbar = scaffold.showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(width: 16),
                                Text(isCached ? 'Updating taxa list...' : 'Downloading taxa list...'),
                              ],
                            ),
                            duration: const Duration(minutes: 1),
                          ),
                        );

                        try {
                          ref.invalidate(allTaxaProvider);
                          ref.invalidate(localTaxaStatusProvider);

                          await ref.read(allTaxaProvider.future);

                          // Use custom SnackBarHelper for success
                          SnackBarHelper.showFloatingSnackBar(
                            context,
                            message: 'Taxa list updated successfully!',
                            type: SnackBarType.success,
                          );
                        } catch (e) {
                          // Use custom SnackBarHelper for error
                          SnackBarHelper.showFloatingSnackBar(
                            context,
                            message: 'Failed to update taxa list: ${e.toString()}',
                            type: SnackBarType.danger,
                          );
                        } finally {
                          loadingSnackbar.close();
                          ref.invalidate(localTaxaStatusProvider);
                        }
                      },
                      child: Text(isCached ? 'Update List' : 'Download List'),
                    ),
                  ),
                ],
              );
            },
            loading: () => const ListTile(
              title: Text('Taxa List'),
              subtitle: Text('Checking status...'),
              trailing: CircularProgressIndicator(),
            ),
            error: (err, stack) => ListTile(
              title: const Text('Taxa List'),
              subtitle: Text('Error: ${err.toString()}'),
              trailing: const Icon(Icons.error),
            ),
          ),
          const Divider(), // Divider before logout button
          
          // NEW: Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              onPressed: () => _logout(context), // Call the logout method
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger, // Red color for danger/logout
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}