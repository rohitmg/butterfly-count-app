// lib/data/models/recent_count.dart
class RecentCount {
  final String id;
  final String placeName;
  final String date;
  final int speciesCount;
  final String mainSpecies; // To display in the list

  RecentCount({
    required this.id,
    required this.placeName,
    required this.date,
    required this.speciesCount,
    required this.mainSpecies,
  });

  factory RecentCount.fromJson(Map<String, dynamic> json) {
    return RecentCount(
      id: json['id'].toString(),
      placeName: json['place_name'] as String,
      date: json['date'] as String, // You may want to parse this to DateTime
      speciesCount: json['species_count'] as int,
      mainSpecies: json['main_species'] as String,
    );
  }
}