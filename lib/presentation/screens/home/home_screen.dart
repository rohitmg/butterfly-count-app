import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 30), // Add your logo
            const SizedBox(width: 10),
            const Text('Butterfly Count'),
          ],
        ),
      ),
      body: SingleChildScrollView(
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
            _buildRecentActivity(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/new-count'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome, User!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text('Last sync: 2h ago', style: TextStyle(color: Colors.grey[600])),
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

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.article),
          title: const Text('Monarch x3'),
          subtitle: const Text('Today'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.article),
          title: const Text('Swallowtail x1'),
          subtitle: const Text('Yesterday'),
          onTap: () {},
        ),
      ],
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
