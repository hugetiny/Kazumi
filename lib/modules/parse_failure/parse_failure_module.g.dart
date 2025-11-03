// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parse_failure_module.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParseFailureRecordAdapter extends TypeAdapter<ParseFailureRecord> {
  @override
  final int typeId = 10;

  @override
  ParseFailureRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParseFailureRecord(
      bangumiId: fields[0] as int,
      pluginName: fields[1] as String,
      src: fields[2] as String,
      failureCount: fields[3] as int,
      lastFailureTime: fields[4] as DateTime,
      reason: fields[5] == null ? 'timeout' : fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ParseFailureRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.bangumiId)
      ..writeByte(1)
      ..write(obj.pluginName)
      ..writeByte(2)
      ..write(obj.src)
      ..writeByte(3)
      ..write(obj.failureCount)
      ..writeByte(4)
      ..write(obj.lastFailureTime)
      ..writeByte(5)
      ..write(obj.reason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParseFailureRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
