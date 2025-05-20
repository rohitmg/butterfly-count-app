import 'package:hive/hive.dart';
import 'observation.dart';

part 'checklist.g.dart';

@HiveType(typeId: 0)
class Checklist {
  @HiveField(0) final String id;
  @HiveField(1) final String userId;
  @HiveField(2) final String? teamName;
  @HiveField(3) final String placeName;
  @HiveField(4) final double latitude;
  @HiveField(5) final double longitude;
  @HiveField(6) final double? altitude;
  @HiveField(7) final double? accuracy;
  @HiveField(8) final DateTime date;
  @HiveField(9) final String startTime;
  @HiveField(10) final String endTime;
  @HiveField(11) final String weather;
  @HiveField(12) final String? comments;
  @HiveField(13) final bool isOpenAccess;
  @HiveField(14) final String syncStatus;
  @HiveField(15) final DateTime createdAt;
  @HiveField(16) final DateTime updatedAt;
  @HiveField(17) final List<Observation> observations;

  Checklist({
    required this.id,
    required this.userId,
    this.teamName,
    required this.placeName,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.weather,
    this.comments,
    this.isOpenAccess = false,
    this.syncStatus = 'pending',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.observations = const [],
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();
}