import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  // Add this import


class HomeScreen extends ConsumerWidget {  // Changed from StatelessWidget
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header 
          _buildWelcomeHeader(),
          const SizedBox(height: 24),
          
          // Stats Cards
          _buildStatsRow(),
          const SizedBox(height: 24),
          
          // Recent Activity
          _buildRecentActivity(theme),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back!', 
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          )),
        const SizedBox(height: 4),
        Text('Ready to count some butterflies?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          )),
      ],
    );
  }

  Widget _buildStatsRow() {
    return const Row(
      children: [
        Expanded(child: StatCard(title: 'Total Species', value: '24')),
        SizedBox(width: 16),
        Expanded(child: StatCard(title: 'This Month', value: '5')),
      ],
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity',
          style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildActivityItem('Monarch', 3, 'Today'),
                const Divider(),
                _buildActivityItem('Swallowtail', 1, 'Yesterday'),
              ],
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

  const StatCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, 
              style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(value,
              style: Theme.of(context).textTheme.displaySmall),
          ],
        ),
      ),
    );
  }
}