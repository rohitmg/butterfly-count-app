// lib/data/models/recent_count.dart
import 'package:json_annotation/json_annotation.dart';

part 'recent_count.g.dart';

@JsonSerializable()
class RecentCount {
  final String id;
  @JsonKey(name: 'place_name')
  final String? placeName; // <--- CHANGED TO BE NULLABLE
  final String date;
  @JsonKey(name: 'species_count')
  final int speciesCount;
  @JsonKey(name: 'main_species')
  final String mainSpecies;

  RecentCount({
    required this.id,
    this.placeName, // <--- CHANGED TO BE NULLABLE
    required this.date,
    required this.speciesCount,
    required this.mainSpecies,
  });

  factory RecentCount.fromJson(Map<String, dynamic> json) => _$RecentCountFromJson(json);
  Map<String, dynamic> toJson() => _$RecentCountToJson(this);
}

// NOTE: You will need to manually update your `_$RecentCountFromJson`
// function in the generated file `recent_count.g.dart` if json_serializable is not used.
// If you use `json_serializable`, the generated code will handle these changes automatically.

// If you are using json_serializable, your generated file will have a line like this:
// id: (json['id'] as num).toString(), // <--- THIS IS THE KEY FIX
// placeName: json['place_name'] as String?, // <--- THIS IS THE KEY FIX