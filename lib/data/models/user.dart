import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
class User {
  @HiveField(0) final String firebaseId;
  @HiveField(1) final String name;
  @HiveField(2) final String email;
  @HiveField(3) final String? photoUrl;
  @HiveField(4) final bool darkMode;
  @HiveField(5) final bool shareOpenAccess;
  @HiveField(7) final DateTime? lastSync;

  User({
    required this.firebaseId,
    required this.name,
    required this.email,
    this.photoUrl,
    this.darkMode = false,
    this.shareOpenAccess = false,
    this.lastSync,
  });
}