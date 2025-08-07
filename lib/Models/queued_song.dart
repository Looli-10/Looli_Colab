import 'package:hive/hive.dart';
import 'package:looli_app/Models/songs.dart';

part 'queued_song.g.dart';

@HiveType(typeId: 1)
class QueuedSong extends HiveObject {
  @HiveField(0)
  String songId;

  @HiveField(1)
  String title;

  @HiveField(2)
  String artist;

  @HiveField(3)
  String album;

  @HiveField(4)
  String url;

  @HiveField(5)
  String image;

  @HiveField(6)
  String language;

  @HiveField(7)
  String? theme;

  QueuedSong({
    required this.songId,
    required this.title,
    required this.artist,
    required this.album,
    required this.url,
    required this.image,
    required this.language,
    this.theme,
  });

  factory QueuedSong.fromSong(Song song) {
    return QueuedSong(
      songId: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      url: song.url,
      image: song.image,
      language: song.language,
      theme: song.theme,
    );
  }

  Song toSong() {
    return Song(
      id: songId,
      title: title,
      artist: artist,
      album: album,
      url: url,
      image: image,
      language: language,
      theme: theme,
    );
  }
}
