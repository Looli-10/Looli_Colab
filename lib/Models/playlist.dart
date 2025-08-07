import 'package:hive/hive.dart';
import 'songs.dart';

part 'playlist.g.dart';

@HiveType(typeId: 2)
class Playlist extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<Song> songs;

  @HiveField(2)
  String? imagePath; // 🎯 Add this

  Playlist({
    required this.name,
    required this.songs,
    this.imagePath,
  });
}

