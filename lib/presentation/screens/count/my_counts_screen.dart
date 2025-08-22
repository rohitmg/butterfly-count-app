import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:butterfly_counts/providers/sync_providers.dart';
import 'package:butterfly_counts/providers/api_providers.dart';
import 'package:butterfly_counts/services/sync_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:butterfly_counts/utils/snackbar_helper.dart';
import 'package:butterfly_counts/core/app_colors.dart';

class MyCountsScreen extends ConsumerWidget {
  const MyCountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);
    final pendingFormsAsyncValue = ref.watch(pendingFormsProvider);

    final isConnected = networkStatus.asData?.value != ConnectivityResult.none;
    final hasPendingForms = pendingFormsAsyncValue.asData?.value.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Counts'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display a status message
            Text(
              'Pending Forms: ${pendingFormsAsyncValue.asData?.value.length ?? '0'}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton.icon(
              onPressed: isConnected && hasPendingForms
                  ? () async {
                      final syncService = ref.read(syncServiceProvider);
                      // Pass context for snackbars
                      await syncService.checkAndSubmitPendingForms(context);
                      // Invalidate provider to re-fetch pending forms list
                      ref.invalidate(pendingFormsProvider);
                    }
                  : null, // Button is disabled if no network or no pending forms
              icon: const Icon(Icons.cloud_upload),
              label: Text(
                isConnected
                    ? 'Submit Pending Counts'
                    : 'No Network',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            // Sub-text for status
            if (!isConnected)
              Text(
                'Waiting for network connection...',
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }
}