// lib/presentation/screens/count/observation_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Ensure this is imported if used
import 'package:firebase_auth/firebase_auth.dart'; // For user UID

import 'package:butterfly_counts/data/models/observation.dart';
import 'package:butterfly_counts/data/models/taxa.dart';
import 'package:butterfly_counts/providers/api_providers.dart';
import 'package:butterfly_counts/utils/snackbar_helper.dart';
import 'package:butterfly_counts/core/app_colors.dart';

/// Shows the dialog for adding a new observation.
/// This is a top-level function as it's no longer tied to a specific widget's state.
void showAddObservationDialog(
  BuildContext ctx,
  WidgetRef ref,
  Function(Observation)
  onAddObservationCallback, // Callback to add observation to parent's list
  List<Observation>
  currentObservations, { // Pass current observations for local ID generation
  Observation? observationToEdit,
  Function(Observation)? onUpdateObservation,
}) {
  final selectedTaxaNotifier = ValueNotifier<Taxa?>(null);
  final TextEditingController commonNameController = TextEditingController();
  final TextEditingController scientificNameController =
      TextEditingController();
  final ValueNotifier<int> individualsNotifier = ValueNotifier(1);
  String? activity;
  String? obsNotes;

  if (observationToEdit != null) {
    commonNameController.text = observationToEdit.taxaCommonName ?? '';
    scientificNameController.text = observationToEdit.taxaScientificName ?? '';
    individualsNotifier.value = observationToEdit.individuals;
    activity = observationToEdit.activity;
    obsNotes = observationToEdit.notes;
  }

  final allTaxaAsyncValue = ref.read(allTaxaProvider);
  final taxaList = allTaxaAsyncValue.asData?.value ?? [];

  showDialog(
    context: ctx,
    builder: (_) => AlertDialog(
      title: Text(
        observationToEdit != null ? 'Edit Observation' : 'Add Observation',
      ), // Dynamic title
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Scientific Name Autocomplete
            ValueListenableBuilder<Taxa?>(
              valueListenable: selectedTaxaNotifier,
              builder: (context, selectedTaxa, child) {
                return Autocomplete<Taxa>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Taxa>.empty();
                    }
                    final query = textEditingValue.text.toLowerCase();
                    return taxaList.where(
                      (taxa) =>
                          taxa.scientificName.toLowerCase().contains(query),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    final query = scientificNameController.text;
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Taxa option = options.elementAt(index);
                              final suggestionText =
                                  (option.commonName != null &&
                                      option.commonName!.isNotEmpty)
                                  ? '${option.commonName} (${option.scientificName})'
                                  : option.scientificName;
                              return ListTile(
                                visualDensity: const VisualDensity(
                                  horizontal: 0,
                                  vertical: -4,
                                ),
                                title: Text.rich(
                                  _buildHighlightedText(suggestionText, query),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  displayStringForOption: (Taxa option) =>
                      option.scientificName,
                  onSelected: (Taxa taxa) {
                    selectedTaxaNotifier.value = taxa;
                    commonNameController.text = taxa.commonName ?? '';
                    scientificNameController.text = taxa.scientificName;
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Scientific Name',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) {
                            if (v !=
                                (selectedTaxaNotifier.value?.scientificName ??
                                    '')) {
                              selectedTaxaNotifier.value = null;
                              commonNameController.clear();
                            } else if (selectedTaxaNotifier.value == null &&
                                commonNameController.text.isNotEmpty &&
                                v.isEmpty) {
                              commonNameController.clear();
                            }
                          },
                        );
                      },
                );
              },
            ),
            const SizedBox(height: 16),
            // Common Name Autocomplete
            ValueListenableBuilder<Taxa?>(
              valueListenable: selectedTaxaNotifier,
              builder: (context, selectedTaxa, child) {
                return Autocomplete<Taxa>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Taxa>.empty();
                    }
                    final query = textEditingValue.text.toLowerCase();
                    return taxaList.where(
                      (taxa) =>
                          taxa.commonName?.toLowerCase().contains(query) ??
                          false,
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    final query = commonNameController.text;
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Taxa option = options.elementAt(index);
                              final suggestionText =
                                  (option.commonName != null &&
                                      option.commonName!.isNotEmpty)
                                  ? '${option.commonName} (${option.scientificName})'
                                  : option.scientificName;
                              return ListTile(
                                visualDensity: const VisualDensity(
                                  horizontal: 0,
                                  vertical: -4,
                                ),
                                title: Text.rich(
                                  _buildHighlightedText(suggestionText, query),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  displayStringForOption: (Taxa option) =>
                      option.commonName ?? '',
                  onSelected: (Taxa taxa) {
                    selectedTaxaNotifier.value = taxa;
                    commonNameController.text = taxa.commonName ?? '';
                    scientificNameController.text = taxa.scientificName;
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: commonNameController,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Common Name',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) {
                            if (v !=
                                (selectedTaxaNotifier.value?.commonName ??
                                    '')) {
                              selectedTaxaNotifier.value = null;
                              scientificNameController.clear();
                            } else if (selectedTaxaNotifier.value == null &&
                                scientificNameController.text.isNotEmpty &&
                                v.isEmpty) {
                              scientificNameController.clear();
                            }
                          },
                        );
                      },
                );
              },
            ),
            const SizedBox(height: 16),

            // Individuals with Increment/Decrement Buttons
            ValueListenableBuilder<int>(
              valueListenable: individualsNotifier,
              builder: (context, individuals, _) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (individuals > 1) {
                          individualsNotifier.value--;
                        }
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: TextEditingController(
                          text: individuals.toString(),
                        ),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          labelText: 'Individuals',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => individualsNotifier.value =
                            int.tryParse(value) ?? 1,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => individualsNotifier.value++,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            // Activity and Notes
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Activity (Optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => activity = v,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Remarks (Optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => obsNotes = v,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final finalSelectedTaxa = selectedTaxaNotifier.value;
            final finalScientificName =
                finalSelectedTaxa?.scientificName ??
                scientificNameController.text;
            final finalCommonName =
                finalSelectedTaxa?.commonName ?? commonNameController.text;

            if (finalScientificName.isEmpty && finalCommonName.isEmpty) {
              SnackBarHelper.showFloatingSnackBar(
                ctx,
                message: 'Please select or enter a species name.',
                type: SnackBarType.warning,
              );
              return;
            }

            final finalTaxaId =
                finalSelectedTaxa?.id ??
                finalScientificName.toLowerCase().replaceAll(' ', '_');

            // Create a new Observation instance with the updated data
            final newObservation = Observation(
              // Use the existing ID if in edit mode, otherwise create a new local ID
              id: observationToEdit?.id ?? (currentObservations.length + 1),
              countId: 0, // Placeholder, will be set by backend
              userId: FirebaseAuth.instance.currentUser!.uid,
              taxaId: finalTaxaId,
              taxaCommonName: finalCommonName,
              taxaScientificName: finalScientificName,
              individuals: individualsNotifier.value,
              activity: activity,
              notes: obsNotes,
              // Use the existing timestamp if in edit mode, otherwise use a new one
              timestamp: observationToEdit?.timestamp ?? DateTime.now(),
            );

            // Call the correct callback based on whether we're in add or edit mode
            if (observationToEdit != null) {
              // We are in edit mode, so call the onUpdateObservation callback
              // onUpdateObservation is a required named parameter when observationToEdit is not null
              onUpdateObservation!(newObservation);
            } else {
              // We are in add mode, so call the onAddObservation callback
              onAddObservationCallback(newObservation);
            }

            Navigator.pop(ctx);
          },
          // Change the button text based on whether an observation is being edited
          child: Text(observationToEdit != null ? 'Save' : 'Add'),
        ),
      ],
    ),
  );
}

/// Helper function for highlighting text in Autocomplete suggestions
TextSpan _buildHighlightedText(String text, String query) {
  if (query.isEmpty) {
    return TextSpan(text: text);
  }
  final List<TextSpan> spans = [];
  final lowercaseText = text.toLowerCase();
  final lowercaseQuery = query.toLowerCase();
  int start = 0;
  int indexOfMatch;
  while ((indexOfMatch = lowercaseText.indexOf(lowercaseQuery, start)) != -1) {
    if (indexOfMatch > start) {
      spans.add(TextSpan(text: text.substring(start, indexOfMatch)));
    }
    spans.add(
      TextSpan(
        text: text.substring(indexOfMatch, indexOfMatch + query.length),
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
    start = indexOfMatch + query.length;
  }
  if (start < text.length) {
    spans.add(TextSpan(text: text.substring(start)));
  }
  return TextSpan(children: spans);
}
