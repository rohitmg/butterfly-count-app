import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:butterfly_counts/providers/api_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:butterfly_counts/data/models/recent_count.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _requestPermissionsAndFetchData(); // Consolidated permission and data fetching
  }

  Future<void> _requestPermissionsAndFetchData() async {
    // 1. Handle location permissions
    _requestLocationPermission();

    // 2. Automatically pull taxa list if it's not available
    // Use Future.microtask to avoid a build-time dependency and ref.read() to trigger the fetch
    Future.microtask(() {
      final taxaAsyncValue = ref.read(allTaxaProvider);
      
      // The allTaxaProvider's logic already handles the caching/fetching.
      // We just need to "read" it here to initiate its future.
      // The UI (e.g., the Autocomplete in the form) will then watch its state.
    });
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final userProfileAsyncValue = ref.watch(userProfileProvider);
    final userStatsAsyncValue = ref.watch(userStatsProvider);
    final recentCountsAsyncValue = ref.watch(recentCountsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        if (recentCounts == null) // Loading state (when future is null, e.g., initial load)
          const Center(child: CircularProgressIndicator())
        else if (recentCounts.isEmpty) // Empty state (API returned empty list or error)
          const Text('No recent activity found.')
        else // Data available
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: recentCounts.map((count) {
                  // Ensure these fields exist in your RecentCount model
                  return _buildActivityItem(
                    count.mainSpecies, // Access mainSpecies from RecentCount object
                    count.speciesCount, // Access speciesCount from RecentCount object
                    count.date, // Access date from RecentCount object
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