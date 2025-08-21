// lib/presentation/screens/count/location_page.dart
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:butterfly_counts/utils/snackbar_helper.dart'; // Import SnackBarHelper
import 'package:butterfly_counts/core/app_colors.dart'; // Import AppColors

class LocationPage extends ConsumerWidget {
  const LocationPage({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
    required this.altitudeController,
    required this.accuracyController,
    required this.placeNameController,
    required this.weather,
    required this.comments,
    required this.onUseCurrentLocation,
    required this.onLatitudeChanged,
    required this.onLongitudeChanged,
    required this.onAltitudeChanged,
    required this.onAccuracyChanged,
    required this.onPlaceNameChanged,
    required this.onWeatherChanged,
    required this.onCommentsChanged,
  });

  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final TextEditingController altitudeController;
  final TextEditingController accuracyController;
  final TextEditingController placeNameController;
  final String weather;
  final String? comments;
  final VoidCallback onUseCurrentLocation;
  final ValueChanged<String?> onLatitudeChanged;
  final ValueChanged<String?> onLongitudeChanged;
  final ValueChanged<String?> onAltitudeChanged;
  final ValueChanged<String?> onAccuracyChanged;
  final ValueChanged<String?> onPlaceNameChanged;
  final ValueChanged<String?> onWeatherChanged;
  final ValueChanged<String?> onCommentsChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.my_location),
            label: const Text('Use Current Location'),
            onPressed: onUseCurrentLocation,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: latitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: onLatitudeChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: longitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: onLongitudeChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: altitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Altitude (m)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: onAltitudeChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: accuracyController,
                  decoration: const InputDecoration(
                    labelText: 'Accuracy (m)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: onAccuracyChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: placeNameController,
            decoration: const InputDecoration(
              labelText: 'Place Name (Optional)',
              border: OutlineInputBorder(),
            ),
            onChanged: onPlaceNameChanged,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: weather,
            decoration: const InputDecoration(
              labelText: 'Weather',
              border: OutlineInputBorder(),
            ),
            items: [
              'Sunny',
              'Cloudy',
              'Rainy',
              'Windy',
            ].map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
            onChanged: onWeatherChanged,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Additional Comments',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            onChanged: onCommentsChanged,
          ),
        ],
      ),
    );
  }
}