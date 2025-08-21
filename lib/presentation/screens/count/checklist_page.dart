// lib/presentation/screens/count/checklist_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:butterfly_counts/data/models/observation.dart';
import 'package:butterfly_counts/data/models/taxa.dart';
import 'package:butterfly_counts/providers/api_providers.dart';
import 'package:butterfly_counts/utils/snackbar_helper.dart';
import 'package:butterfly_counts/core/app_colors.dart';
// NEW: Import the standalone dialog file
import 'package:butterfly_counts/presentation/screens/count/observation_dialog.dart';

class ChecklistPage extends ConsumerWidget {
  const ChecklistPage({
    super.key,
    required this.observations,
    required this.elapsedDuration,
    required this.submissionState,
    required this.onAddObservation,
    required this.onDeleteObservation,
    required this.onSubmitForm,
  });

  final List<Observation> observations;
  final Duration elapsedDuration;
  final AsyncValue<int?> submissionState;
  final Function(Observation) onAddObservation;
  final Function(Observation) onDeleteObservation;
  final VoidCallback onSubmitForm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elapsedText = elapsedDuration.toString().split('.').first;

    final int totalIndividualsObserved = observations.fold<int>(
      0,
      (s, o) => s + o.individuals,
    );
    final int uniqueSpeciesObserved = observations
        .map((o) => o.taxaId)
        .toSet()
        .length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildStatCard(
                context,
                'Species',
                uniqueSpeciesObserved.toString(),
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                context,
                'Individuals',
                totalIndividualsObserved.toString(),
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                context,
                'Duration',
                elapsedText,
              ), 
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                dataRowColor: MaterialStateProperty.all(
                  Theme.of(context).primaryColor.withOpacity(0.03),
                ),
                columns: const [
                  DataColumn(label: Text('Species')),
                  DataColumn(label: Text('Individuals')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: observations.map((obs) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          obs.taxaCommonName ??
                              obs.taxaScientificName ??
                              'Unknown',
                        ),
                      ),
                      DataCell(Text('${obs.individuals}')),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => onDeleteObservation(obs),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton.extended(
                icon: const Icon(Icons.add),
                label: const Text('Add Observation'),
                onPressed: submissionState.isLoading
                    ? null
                    : () => showAddObservationDialog(
                        context,
                        ref,
                        onAddObservation,
                        observations,
                      ),
              ),
              FloatingActionButton.extended(
                icon: submissionState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.check),
                label: const Text('Submit Count'),
                onPressed: submissionState.isLoading ? null : onSubmitForm,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Moved StatCard here
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value, {
    Color? customColor,
  }) {
    // <--- context parameter is here
    final color = customColor ?? Theme.of(context).primaryColor;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: Theme.of(context).textTheme.labelSmall),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
