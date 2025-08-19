import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:butterfly_counts/providers/api_providers.dart';
import 'package:butterfly_counts/data/models/recent_count.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator

// Change HomeScreen to a ConsumerStatefulWidget to use initState
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _requestLocationPermission(); // Request location permission on load
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled.
      // You might want to show a dialog prompting the user to enable them.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied.
        // You might want to show a dialog explaining why permissions are needed.
        return Future.error('Location permissions are denied.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever.
      // You might want to show a dialog directing the user to app settings.
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
    // Location permission is granted.
    // You could log this or trigger initial location fetch if needed immediately (though we're doing it on button press later).
  }

  @override
  Widget build(BuildContext context) { // <--- REMOVED WidgetRef ref from arguments
    final theme = Theme.of(context);

    // Access ref directly as a property of ConsumerState
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
            loading: () => _buildRecentActivity(theme, null),
            error: (err, stack) => _buildRecentActivity(theme, []),
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
        if (recentCounts == null)
          const Center(child: CircularProgressIndicator())
        else if (recentCounts.isEmpty)
          const Text('No recent activity found.')
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: recentCounts.map((count) {
                  return _buildActivityItem(
                    count.mainSpecies,
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
