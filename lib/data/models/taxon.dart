import 'package:hive/hive.dart';

part 'taxon.g.dart';

@HiveType(typeId: 2)
class Taxon {
  @HiveField(0) final String id;
  @HiveField(1) final String scientificName;
  @HiveField(2) final String? commonName;
  @HiveField(3) final String? rank;
  @HiveField(4) final String? ancestry;
  @HiveField(5) final int preferenceWeight;
  @HiveField(6) final String? thumbnailUrl;

  Taxon({
    required this.id,
    required this.scientificName,
    required this.commonName,
    required this.rank,
    required this.ancestry,
    this.preferenceWeight = 50,
    this.thumbnailUrl,
  });
}