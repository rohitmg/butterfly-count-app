// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_count.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecentCount _$RecentCountFromJson(Map<String, dynamic> json) => RecentCount(
      id: json['id'] as String,
      placeName: json['place_name'] as String?,
      date: json['date'] as String,
      speciesCount: (json['species_count'] as num).toInt(),
      mainSpecies: json['main_species'] as String,
    );

Map<String, dynamic> _$RecentCountToJson(RecentCount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'place_name': instance.placeName,
      'date': instance.date,
      'species_count': instance.speciesCount,
      'main_species': instance.mainSpecies,
    };
