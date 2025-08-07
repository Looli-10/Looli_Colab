import 'package:hive/hive.dart';

part 'songs.g.dart';

@HiveType(typeId: 0)
class Song extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String artist;

  @HiveField(3)
  final String url;

  @HiveField(4)
  final String image;

  @HiveField(5)
  final String album;

  @HiveField(6)
  final String? theme;

  @HiveField(7)
  final String language;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.url,
    required this.image,
    required this.album,
    this.theme,
    required this.language,
  });

  Song copy() {
    return Song(
      id: id,
      title: title,
      artist: artist,
      url: url,
      image: image,
      album: album,
      theme: theme,
      language: language,
    );
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id']?.trim() ?? '',
      title: json['title']?.trim() ?? 'Unknown Title',
      artist: json['artist']?.trim() ?? 'Unknown Artist',
      url: json['url']?.trim() ?? '',
      image: json['image']?.trim() ?? '',
      album: json['album']?.trim() ?? 'Unknown Album',
      theme: json['theme']?.trim(),
      language: json['language']?.trim() ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'url': url,
        'image': image,
        'album': album,
        'theme': theme,
        'language': language,
      };
}

// Album class does NOT need Hive
class Album {
  final String title;
  final String image;
  final List<Song> songs;

  Album({
    required this.title,
    required this.image,
    required this.songs,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    final albumTitle = json['title']?.trim() ?? 'Unknown Album';
    final List<dynamic> songList = json['songs'] ?? [];

    List<Song> songs = songList.map((e) {
      return Song.fromJson({
        ...e,
        'album': albumTitle,
      });
    }).toList();

    return Album(
      title: albumTitle,
      image: json['image']?.trim() ?? '',
      songs: songs,
    );
  }
}
