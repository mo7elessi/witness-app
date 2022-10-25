// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flag_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlagModelAdapter extends TypeAdapter<FlagModel> {
  @override
  final int typeId = 1;

  @override
  FlagModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FlagModel(
      id: fields[0] as String?,
      videoDuration: fields[3] as String?,
      path: fields[2] as String?,
      title: fields[1] as String?,
      flagPoint: fields[9] as String?,
      isLike: fields[4] as bool?,
      isExtracted: fields[5] as bool?,
      startDuration: fields[7] as Duration?,
      endDuration: fields[8] as Duration?,
    );
  }

  @override
  void write(BinaryWriter writer, FlagModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(4)
      ..write(obj.isLike)
      ..writeByte(5)
      ..write(obj.isExtracted)
      ..writeByte(9)
      ..write(obj.flagPoint)
      ..writeByte(7)
      ..write(obj.startDuration)
      ..writeByte(8)
      ..write(obj.endDuration)
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
      other is FlagModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
