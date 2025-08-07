import 'package:hive/hive.dart';
import 'package:looli_app/Models/playlist.dart';
import 'package:looli_app/Models/songs.dart';

class PlaylistService {
  static const String _boxName = 'custom_playlists'; // ✅ Match the box used elsewhere

  static Future<void> init() async {
    await Hive.openBox<Playlist>(_boxName);
  }

  static List<Playlist> getAllPlaylists() {
    final box = Hive.box<Playlist>(_boxName);
    return box.values.toList();
  }

  static Future<void> addPlaylist(Playlist playlist) async {
    final box = Hive.box<Playlist>(_boxName);
    await box.add(playlist);
  }

  static Future<void> updatePlaylist(int index, Playlist updatedPlaylist) async {
    final box = Hive.box<Playlist>(_boxName);
    await box.putAt(index, updatedPlaylist);
  }

  static Future<void> deletePlaylist(int index) async {
    final box = Hive.box<Playlist>(_boxName);
    await box.deleteAt(index);
  }

  static Future<void> addSongToPlaylist(int index, Song song) async {
    final box = Hive.box<Playlist>(_boxName);
    final playlist = box.getAt(index);
    if (playlist != null && !playlist.songs.any((s) => s.id == song.id)) {
      playlist.songs.add(song);
      await playlist.save();
    }
  }

  static Future<void> removeSongFromPlaylist(int index, Song song) async {
    final box = Hive.box<Playlist>(_boxName);
    final playlist = box.getAt(index);
    if (playlist != null) {
      playlist.songs.removeWhere((s) => s.id == song.id);
      await playlist.save();
    }
  }
  static Box<Playlist> getBox() {
  return Hive.box<Playlist>(_boxName);
}

}
