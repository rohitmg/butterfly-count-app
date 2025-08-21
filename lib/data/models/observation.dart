// lib/data/models/observation.dart
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart'; // NEW: Import Hive

part 'observation.g.dart';

@JsonSerializable()
@HiveType(typeId: 2) // NEW: Assign a unique typeId (e.g., 2)
class Observation {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  @JsonKey(name: 'count_id')
  final int countId;
  @HiveField(2)
  @JsonKey(name: 'user_id')
  final String userId;
  @HiveField(3)
  @JsonKey(name: 'taxa_id')
  final String taxaId;
  @HiveField(4)
  @JsonKey(name: 'taxa_common_name')
  final String? taxaCommonName;
  @HiveField(5)
  @JsonKey(name: 'taxa_scientific_name')
  final String? taxaScientificName;
  @HiveField(6)
  final int individuals;
  @HiveField(7)
  final String? activity;
  @HiveField(8)
  final String? notes;
  @HiveField(9)
  final DateTime timestamp;
  @HiveField(10)
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @HiveField(11)
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Observation({
    this.id, required this.countId, required this.userId, required this.taxaId,
    this.taxaCommonName, this.taxaScientificName, required this.individuals,
    this.activity, this.notes, required this.timestamp, this.createdAt, this.updatedAt,
  });

  factory Observation.fromJson(Map<String, dynamic> json) => _$ObservationFromJson(json);
  Map<String, dynamic> toJson() => _$ObservationToJson(this);
}