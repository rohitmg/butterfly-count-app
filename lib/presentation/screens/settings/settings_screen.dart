// lib/presentation/screens/settings/settings_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:butterfly_counts/core/theme/theme_manager.dart'; // <--- NEW: Import theme_manager
import 'package:butterfly_counts/providers/api_providers.dart';
import 'package:butterfly_counts/data/models/taxa.dart';
import 'package:butterfly_counts/providers/app_preferences_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the actual ThemeData from themeProvider
    final currentTheme = ref.watch(themeProvider);
    final isDarkMode = currentTheme.brightness == Brightness.dark; // Derive isDarkMode from theme
    
    final localTaxaStatusAsync = ref.watch(localTaxaStatusProvider);
    final openAccessPreference = ref.watch(openAccessPreferenceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDarkMode, // Use the derived isDarkMode
            onChanged: (value) {
              // Call the toggleTheme method on the notifier
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

                          scaffold.showSnackBar(
                            const SnackBar(content: Text('Taxa list updated successfully!')),
                          );
                        } catch (e) {
                          scaffold.showSnackBar(
                            SnackBar(content: Text('Failed to update taxa list: ${e.toString()}')),
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
        ],
      ),
    );
  }
}