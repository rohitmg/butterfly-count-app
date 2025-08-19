import 'dart:async'; // Still needed for Completer if used elsewhere, but not for this onPressed

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../../core/theme/theme_provider.dart';
import '../../../providers/api_providers.dart'; // Import your API providers
import '../../../data/models/taxa.dart'; // Ensure Taxa model is imported for ProviderSubscription type

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final localTaxaStatusAsync = ref.watch(
      localTaxaStatusProvider,
    ); // Watch the new provider

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (value) =>
                ref.read(themeProvider.notifier).state = value,
          ),
          const Divider(), // Add a divider for separation
          // NEW: Taxa List Management Section
          localTaxaStatusAsync.when(
            data: (status) {
              final isCached = status['is_cached'] as bool;
              final lastUpdatedString = status['last_updated'] as String?;
              DateTime? lastUpdatedDate;
              if (lastUpdatedString != null) {
                try {
                  lastUpdatedDate = DateTime.parse(lastUpdatedString);
                } catch (e) {
                  // Handle parsing error if timestamp format is inconsistent
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
                                Text(
                                  isCached
                                      ? 'Updating taxa list...'
                                      : 'Downloading taxa list...',
                                ),
                              ],
                            ),
                            duration: const Duration(
                              minutes: 1,
                            ), // Long duration for loading
                          ),
                        );

                        try {
                          // Invalidate and wait for the provider to complete
                          ref.invalidate(allTaxaProvider);
                          ref.invalidate(
                            localTaxaStatusProvider,
                          ); // Invalidate status to show loading

                          // Wait for the provider to complete its async operation
                          await ref.read(
                            allTaxaProvider.future,
                          ); // Await the future directly

                          // Show success message
                          scaffold.showSnackBar(
                            const SnackBar(
                              content: Text('Taxa list updated successfully!'),
                            ),
                          );
                        } catch (e) {
                          // Show error message
                          scaffold.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to update taxa list: ${e.toString()}',
                              ),
                            ),
                          );
                        } finally {
                          // Hide loading snackbar
                          loadingSnackbar.close();
                          // Invalidate localTaxaStatusProvider again to reflect the final state (success or error)
                          ref.invalidate(localTaxaStatusProvider);
                        }
                      },
                      child: Text(isCached ? 'Update List' : 'Download List'),
                    ),
                  ),
                  // TODO: Add UI for adding/removing/editing individual species from user's local overrides
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
