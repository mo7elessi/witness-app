// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoModelAdapter extends TypeAdapter<VideoModel> {
  @override
  final int typeId = 0;

  @override
  VideoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoModel(
      id: fields[0] as String?,
      videoDuration: fields[3] as String?,
      path: fields[2] as String?,
      title: fields[1] as String?,
      dateTime: fields[4] as DateTime?,
      flags: (fields[5] as List?)?.cast<FlagModel>(),
      videoThumbnail: fields[6] as String?,
      isUploaded: fields[7] as bool?,
    )..videoData = fields[8] as VideoData?;
  }

  @override
  void write(BinaryWriter writer, VideoModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(4)
      ..write(obj.dateTime)
      ..writeByte(5)
      ..write(obj.flags)
      ..writeByte(6)
      ..write(obj.videoThumbnail)
      ..writeByte(7)
      ..write(obj.isUploaded)
      ..writeByte(8)
      ..write(obj.videoData)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.path)
      ..writeByte(3)
      ..write(obj.videoDuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
