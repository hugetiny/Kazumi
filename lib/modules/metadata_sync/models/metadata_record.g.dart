// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EpisodeMetadataAdapter extends TypeAdapter<EpisodeMetadata> {
  @override
  final int typeId = 7;

  @override
  EpisodeMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EpisodeMetadata(
      number: fields[0] as int,
      title: fields[1] as String?,
      synopsis: fields[2] as String?,
      airDate: fields[3] as DateTime?,
      runtimeMinutes: fields[4] as int?,
      stillImageUrl: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EpisodeMetadata obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.synopsis)
      ..writeByte(3)
      ..write(obj.airDate)
      ..writeByte(4)
      ..write(obj.runtimeMinutes)
      ..writeByte(5)
      ..write(obj.stillImageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MetadataSourceSnapshotAdapter
    extends TypeAdapter<MetadataSourceSnapshot> {
  @override
  final int typeId = 8;

  @override
  MetadataSourceSnapshot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MetadataSourceSnapshot(
      sourceId: fields[0] as String,
      lastSyncedAt: fields[1] as DateTime,
      localeTag: fields[2] as String,
      rawPayloadJson: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MetadataSourceSnapshot obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.sourceId)
      ..writeByte(1)
      ..write(obj.lastSyncedAt)
      ..writeByte(2)
      ..write(obj.localeTag)
      ..writeByte(3)
      ..write(obj.rawPayloadJson);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetadataSourceSnapshotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MetadataRecordAdapter extends TypeAdapter<MetadataRecord> {
  @override
  final int typeId = 9;

  @override
  MetadataRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MetadataRecord(
      slug: fields[0] as String,
      primaryTitle: fields[1] as String,
      localeTag: fields[8] as String,
      updatedAt: fields[9] as DateTime,
      alternateTitles: (fields[2] as Map).cast<String, String>(),
      synopsis: (fields[3] as Map).cast<String, String>(),
      posterUrl: fields[4] as String?,
      backdropUrl: fields[5] as String?,
      episodes: (fields[6] as List).cast<EpisodeMetadata>(),
      activeSource: fields[7] as String?,
      identifiers: (fields[10] as Map).cast<String, String>(),
      sourceSnapshots: (fields[11] as List).cast<MetadataSourceSnapshot>(),
    );
  }

  @override
  void write(BinaryWriter writer, MetadataRecord obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.slug)
      ..writeByte(1)
      ..write(obj.primaryTitle)
      ..writeByte(2)
      ..write(obj.alternateTitles)
      ..writeByte(3)
      ..write(obj.synopsis)
      ..writeByte(4)
      ..write(obj.posterUrl)
      ..writeByte(5)
      ..write(obj.backdropUrl)
      ..writeByte(6)
      ..write(obj.episodes)
      ..writeByte(7)
      ..write(obj.activeSource)
      ..writeByte(8)
      ..write(obj.localeTag)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.identifiers)
      ..writeByte(11)
      ..write(obj.sourceSnapshots);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetadataRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
