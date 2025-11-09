// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadTaskAdapter extends TypeAdapter<DownloadTask> {
  @override
  final int typeId = 20;

  @override
  DownloadTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadTask(
      gid: fields[0] as String,
      url: fields[1] as String,
      title: fields[2] as String,
      fileName: fields[3] as String?,
      totalLength: fields[4] as int,
      completedLength: fields[5] as int,
      downloadSpeed: fields[6] as int,
      status: fields[7] as String,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
      errorMessage: fields[10] as String?,
      errorCode: fields[11] as int?,
      bangumiId: fields[12] as String?,
      episodeNumber: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadTask obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.gid)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.fileName)
      ..writeByte(4)
      ..write(obj.totalLength)
      ..writeByte(5)
      ..write(obj.completedLength)
      ..writeByte(6)
      ..write(obj.downloadSpeed)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.errorMessage)
      ..writeByte(11)
      ..write(obj.errorCode)
      ..writeByte(12)
      ..write(obj.bangumiId)
      ..writeByte(13)
      ..write(obj.episodeNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
