import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:looli_app/Models/songs.dart';

class LikedSongsService {
  static final _box = Hive.box<Song>('liked_songs');

  static final ValueNotifier<int> likedCountNotifier =
      ValueNotifier(_box.length); // reactive notifier

  static bool isLiked(String id) {
    return _box.containsKey(id);
  }

  static Future<void> likeSong(Song song) async {
    final copiedSong = song.copy();
    await _box.put(song.id, copiedSong);
    likedCountNotifier.value = _box.length;
  }

  static Future<void> unlikeSong(String id) async {
    await _box.delete(id);
    likedCountNotifier.value = _box.length;
  }

  static Future<void> toggleLike(Song song) async {
    if (isLiked(song.id)) {
      await unlikeSong(song.id);
    } else {
      await likeSong(song);
    }
  }

  static List<Song> getAllLiked() {
    return _box.values.toList();
  }

  static Future<void> clearAllLiked() async {
    await _box.clear();
    likedCountNotifier.value = 0;
  }
}

