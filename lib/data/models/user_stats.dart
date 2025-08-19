// lib/data/models/user_stats.dart
class UserStats {
  final int totalCounts;
  final int totalSpecies;
  final int totalIndividuals;
  final int thisMonthCounts;
  final int thisMonthSpecies;
  final int thisMonthIndividuals;

  UserStats({
    required this.totalCounts,
    required this.totalSpecies,
    required this.totalIndividuals,
    required this.thisMonthCounts,
    required this.thisMonthSpecies,
    required this.thisMonthIndividuals,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalCounts: json['total_counts'] as int,
      totalSpecies: json['total_species'] as int,
      totalIndividuals: json['total_individuals'] as int,
      thisMonthCounts: json['this_month_counts'] as int,
      thisMonthSpecies: json['this_month_species'] as int,
      thisMonthIndividuals: json['this_month_individuals'] as int,
    );
  }
}