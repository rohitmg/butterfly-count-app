// lib/data/models/count_model.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:butterfly_counts/data/models/observation.dart';
import 'package:hive/hive.dart'; // NEW: Import Hive

part 'count_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 1) // NEW: Assign a unique typeId (e.g., 1)
class CountModel {
  @HiveField(0) // Assign unique field IDs for Hive
  final int? id;
  @HiveField(1)
  @JsonKey(name: 'user_id')
  final String userId;
  @HiveField(2)
  final String? team;
  @HiveField(3)
  @JsonKey(name: 'open_access')
  final bool openAccess;
  @HiveField(4)
  final DateTime date;
  @HiveField(5)
  @JsonKey(name: 'start_time')
  final DateTime? startTime;
  @HiveField(6)
  @JsonKey(name: 'end_time')
  final DateTime? endTime;
  @HiveField(7)
  final double latitude;
  @HiveField(8)
  final double longitude;
  @HiveField(9)
  final double? altitude;
  @HiveField(10)
  final double? accuracy;
  @HiveField(11)
  @JsonKey(name: 'place_name')
  final String? placeName;
  @HiveField(12)
  @JsonKey(name: 'district_id')
  final String? districtId;
  @HiveField(13)
  @JsonKey(name: 'district_name')
  final String? districtName;
  @HiveField(14)
  @JsonKey(name: 'state_name')
  final String? stateName;
  @HiveField(15)
  @JsonKey(name: 'country_name')
  final String? countryName;
  @HiveField(16)
  @JsonKey(name: 'distance_covered')
  final double? distanceCovered;
  @HiveField(17)
  final String? weather;
  @HiveField(18)
  final String? notes;
  @HiveField(19)
  final String? version;
  @HiveField(20)
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @HiveField(21)
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @HiveField(22)
  final List<Observation> observations; // This field also needs @HiveField

  CountModel({
    this.id, required this.userId, this.team, required this.openAccess, required this.date,
    this.startTime, this.endTime, required this.latitude, required this.longitude,
    this.altitude, this.accuracy, this.placeName, this.districtId, this.districtName,
    this.stateName, this.countryName, this.distanceCovered, this.weather, this.notes,
    this.version, this.createdAt, this.updatedAt, required this.observations,
  });

  factory CountModel.fromJson(Map<String, dynamic> json) => _$CountModelFromJson(json);

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$CountModelToJson(this);
    json['date'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    json['start_time'] = startTime != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(startTime!) : null;
    json['end_time'] = endTime != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(endTime!) : null;
    return json;
  }
}