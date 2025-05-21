// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxon.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaxonAdapter extends TypeAdapter<Taxon> {
  @override
  final int typeId = 2;

  @override
  Taxon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Taxon(
      id: fields[0] as String,
      scientificName: fields[1] as String,
      commonName: fields[2] as String?,
      rank: fields[3] as String?,
      ancestry: fields[4] as String?,
      preferenceWeight: fields[5] as int,
      thumbnailUrl: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Taxon obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.scientificName)
      ..writeByte(2)
      ..write(obj.commonName)
      ..writeByte(3)
      ..write(obj.rank)
      ..writeByte(4)
      ..write(obj.ancestry)
      ..writeByte(5)
      ..write(obj.preferenceWeight)
      ..writeByte(6)
      ..write(obj.thumbnailUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
