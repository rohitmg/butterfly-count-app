import 'package:hive/hive.dart';

part 'observation.g.dart';

@HiveType(typeId: 1)
class Observation {
  @HiveField(0) final String id;
  @HiveField(1) final String checklistId;
  @HiveField(2) final String? taxonId;
  @HiveField(3) final String? customName;
  @HiveField(4) final int individuals;
  @HiveField(5) final String? lifeStage;
  @HiveField(6) final String? behavior;
  @HiveField(7) final String? remarks;

  Observation({
    required this.id,
    required this.checklistId,
    this.taxonId,
    this.customName,
    required this.individuals,
    this.lifeStage,
    this.behavior,
    this.remarks,
  }) : assert(taxonId != null || customName != null, 
         'Must have either taxonId or customName');
}