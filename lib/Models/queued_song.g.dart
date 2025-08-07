// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queued_song.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QueuedSongAdapter extends TypeAdapter<QueuedSong> {
  @override
  final int typeId = 1;

  @override
  QueuedSong read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QueuedSong(
      songId: fields[0] as String,
      title: fields[1] as String,
      artist: fields[2] as String,
      album: fields[3] as String,
      url: fields[4] as String,
      image: fields[5] as String,
      language: fields[6] as String,
      theme: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QueuedSong obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.songId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.album)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.image)
      ..writeByte(6)
      ..write(obj.language)
      ..writeByte(7)
      ..write(obj.theme);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueuedSongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
