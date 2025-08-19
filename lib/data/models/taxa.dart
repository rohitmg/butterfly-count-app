// lib/data/models/taxa.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart'; // <--- NEW: Import Hive

part 'taxa.g.dart';

@JsonSerializable()
@HiveType(typeId: 0) // <--- NEW: Assign a unique typeId for Hive. Start from 0 and increment for other models.
class Taxa {
  @HiveField(0) // <--- NEW: Assign unique field IDs for Hive. Start from 0 for each model.
  final String id;
  @HiveField(1)
  @JsonKey(name: 'common_name')
  final String? commonName;
  @HiveField(2)
  @JsonKey(name: 'scientific_name')
  final String scientificName;
  @HiveField(3)
  @JsonKey(name: 'inat_id')
  final int? inatId;
  @HiveField(4)
  final String? genus;
  @HiveField(5)
  final String? tribe;
  @HiveField(6)
  final String? subfamily;
  @HiveField(7)
  final String? family;
  @HiveField(8)
  final String? rank;
  @HiveField(9)
  final List<String>? ancestry;
  @HiveField(10)
  final String? notes;
  // Note: created_at and updated_at are typically not stored in Hive for static data
  // If you want them, add @HiveField(11) and @HiveField(12) respectively.

  Taxa({
    required this.id,
    this.commonName,
    required this.scientificName,
    this.inatId,
    this.genus,
    this.tribe,
    this.subfamily,
    this.family,
    this.rank,
    this.ancestry,
    this.notes,
  });

  factory Taxa.fromJson(Map<String, dynamic> json) => _$TaxaFromJson(json);
  Map<String, dynamic> toJson() => _$TaxaToJson(this);

  @override
  String toString() {
    return commonName != null && commonName!.isNotEmpty
        ? '$commonName ($scientificName)'
        : scientificName;
  }
}