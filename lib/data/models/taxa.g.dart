// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxa.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaxaAdapter extends TypeAdapter<Taxa> {
  @override
  final int typeId = 0;

  @override
  Taxa read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Taxa(
      id: fields[0] as String,
      commonName: fields[1] as String?,
      scientificName: fields[2] as String,
      inatId: fields[3] as int?,
      genus: fields[4] as String?,
      tribe: fields[5] as String?,
      subfamily: fields[6] as String?,
      family: fields[7] as String?,
      rank: fields[8] as String?,
      ancestry: (fields[9] as List?)?.cast<String>(),
      notes: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Taxa obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.commonName)
      ..writeByte(2)
      ..write(obj.scientificName)
      ..writeByte(3)
      ..write(obj.inatId)
      ..writeByte(4)
      ..write(obj.genus)
      ..writeByte(5)
      ..write(obj.tribe)
      ..writeByte(6)
      ..write(obj.subfamily)
      ..writeByte(7)
      ..write(obj.family)
      ..writeByte(8)
      ..write(obj.rank)
      ..writeByte(9)
      ..write(obj.ancestry)
      ..writeByte(10)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Taxa _$TaxaFromJson(Map<String, dynamic> json) => Taxa(
      id: json['id'] as String,
      commonName: json['common_name'] as String?,
      scientificName: json['scientific_name'] as String,
      inatId: (json['inat_id'] as num?)?.toInt(),
      genus: json['genus'] as String?,
      tribe: json['tribe'] as String?,
      subfamily: json['subfamily'] as String?,
      family: json['family'] as String?,
      rank: json['rank'] as String?,
      ancestry: (json['ancestry'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$TaxaToJson(Taxa instance) => <String, dynamic>{
      'id': instance.id,
      'common_name': instance.commonName,
      'scientific_name': instance.scientificName,
      'inat_id': instance.inatId,
      'genus': instance.genus,
      'tribe': instance.tribe,
      'subfamily': instance.subfamily,
      'family': instance.family,
      'rank': instance.rank,
      'ancestry': instance.ancestry,
      'notes': instance.notes,
    };
