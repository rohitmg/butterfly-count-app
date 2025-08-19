// lib/data/models/observation.dart
import 'package:flutter/material.dart'; // For @required if using older Dart, or just for clarity
import 'package:json_annotation/json_annotation.dart'; // New import

part 'observation.g.dart'; // This line tells Dart to look for the generated file

@JsonSerializable() // Add this annotation above your class
class Observation {
  final int? id;
  @JsonKey(name: 'count_id') // Map JSON key to Dart field name
  final int countId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'taxa_id')
  final String taxaId;
  @JsonKey(name: 'taxa_common_name')
  final String? taxaCommonName;
  @JsonKey(name: 'taxa_scientific_name')
  final String? taxaScientificName;
  final int individuals;
  final String? activity;
  final String? notes;
  final DateTime timestamp;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Observation({
    this.id,
    required this.countId,
    required this.userId,
    required this.taxaId,
    this.taxaCommonName,
    this.taxaScientificName,
    required this.individuals,
    this.activity,
    this.notes,
    required this.timestamp,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor for deserialization from JSON
  factory Observation.fromJson(Map<String, dynamic> json) => _$ObservationFromJson(json);

  // Method for serialization to JSON
  Map<String, dynamic> toJson() => _$ObservationToJson(this);
}