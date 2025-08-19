import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:butterfly_counts/providers/api_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:butterfly_counts/data/models/recent_count.dart'; // New import

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final userProfileAsyncValue = ref.watch(userProfileProvider);
    final userStatsAsyncValue = ref.watch(userStatsProvider);
    final recentCountsAsyncValue = ref.watch(recentCountsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - dynamic
          userProfileAsyncValue.when(
            data: (userProfile) => _buildWelcomeHeader(userProfile['name']),
            loading: () => _buildWelcomeHeader('Loading...'),
            error: (err, stack) {
              if (err.toString().contains('User not logged in')) {
                return _buildWelcomeHeader('Welcome!');
              }
              return _buildWelcomeHeader('Error loading user');
            },
          ),
          const SizedBox(height: 24),

          // Stats Cards - dynamic
          userStatsAsyncValue.when(
            data: (stats) => _buildStatsRow(
              totalCounts: stats.totalCounts.toString(),
              totalSpecies: stats.totalSpecies.toString(),
              totalIndividuals: stats.totalIndividuals.toString(),
              thisMonthCounts: stats.thisMonthCounts.toString(),
              thisMonthSpecies: stats.thisMonthSpecies.toString(),
              thisMonthIndividuals: stats.thisMonthIndividuals.toString(),
            ),
            loading: () => _buildStatsRow(
                totalCounts: '...', totalSpecies: '...', totalIndividuals: '...',
                thisMonthCounts: '...', thisMonthSpecies: '...', thisMonthIndividuals: '...'),
            error: (err, stack) => _buildStatsRow(
                totalCounts: 'Error', totalSpecies: 'Error', totalIndividuals: 'Error',
                thisMonthCounts: 'Error', thisMonthSpecies: 'Error', thisMonthIndividuals: 'Error'),
          ),
          const SizedBox(height: 24),

          // Recent Activity - dynamic
          recentCountsAsyncValue.when(
            data: (recentCounts) => _buildRecentActivity(theme, recentCounts),
            loading: () => _buildRecentActivity(theme, null), // Pass null for loading
            error: (err, stack) => _buildRecentActivity(theme, []), // Pass empty list on error
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(String userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back, $userName!',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Ready to count some butterflies?',
          style: TextStyle(fontSize: 16, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildStatsRow({
    required String totalCounts,
    required String totalSpecies,
    required String totalIndividuals,
    required String thisMonthCounts,
    required String thisMonthSpecies,
    required String thisMonthIndividuals,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: StatCard(title: 'Total Counts', value: totalCounts)),
            const SizedBox(width: 16),
            Expanded(child: StatCard(title: 'Total Species', value: totalSpecies)),
            const SizedBox(width: 16),
            Expanded(child: StatCard(title: 'Total Individuals', value: totalIndividuals)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: StatCard(title: 'This Month Counts', value: thisMonthCounts)),
            const SizedBox(width: 16),
            Expanded(child: StatCard(title: 'This Month Species', value: thisMonthSpecies)),
            const SizedBox(width: 16),
            Expanded(child: StatCard(title: 'This Month Individuals', value: thisMonthIndividuals)),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(ThemeData theme, List<RecentCount>? recentCounts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        if (recentCounts == null) // Loading state
          const Center(child: CircularProgressIndicator())
        else if (recentCounts.isEmpty) // Empty/error state
          const Text('No recent activity found.')
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: recentCounts.map((count) {
                  return _buildActivityItem(
                    count.mainSpecies, // From your new model
                    count.speciesCount,
                    count.date,
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActivityItem(String species, int count, String date) {
    return ListTile(
      leading: const Icon(Icons.article, size: 28),
      title: Text('$species x$count'),
      subtitle: Text(date),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.displaySmall),
          ],
        ),
      ),
    );
  }
}