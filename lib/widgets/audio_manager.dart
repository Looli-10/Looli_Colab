import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/services/queue_service.dart';
import 'package:audio_service/audio_service.dart';

class PlayerManager {
  static final PlayerManager _instance = PlayerManager._internal();
  factory PlayerManager() => _instance;

  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<Song?> currentSongNotifier = ValueNotifier(null);
  final ValueNotifier<LoopMode> repeatModeNotifier = ValueNotifier(
    LoopMode.off,
  );
  final ValueNotifier<bool> shuffleModeNotifier = ValueNotifier(false);

  List<Song> _playlist = [];
  ConcatenatingAudioSource? _audioSource;

  PlayerManager._internal() {
    _player.currentIndexStream.listen((index) async {
      if (index != null && index < _playlist.length) {
        final song = _playlist[index];
        currentSongNotifier.value = song;

        // ✅ Save last played song
        final box = await Hive.openBox('player_state');
        await box.put('last_played_song', song);

        // 🔧 NEW LOGIC FOR RECENTLY PLAYED
        List<dynamic> existing = box.get('last_playlist', defaultValue: []);
        List<Song> recentSongs = List<Song>.from(existing);

        // Remove if already exists to avoid duplicates
        recentSongs.removeWhere((s) => s.id == song.id);

        // Add song to end (most recent last)
        recentSongs.add(song);

        // Limit to last 10 songs
        if (recentSongs.length > 10) {
          recentSongs = recentSongs.sublist(recentSongs.length - 10);
        }

        // Save updated list
        await box.put('last_playlist', recentSongs);
      }
    });
  }

  AudioPlayer get player => _player;
  List<Song> get currentPlaylist => _playlist;

  set currentPlaylist(List<Song> songs) {
    _playlist = songs;
  }

  Future<void> setPlaylist(List<Song> songs, {int startIndex = 0}) async {
    _playlist = songs;

    _audioSource = ConcatenatingAudioSource(
      children:
          songs.map((s) {
            return AudioSource.uri(
              Uri.parse(s.url),
              tag: MediaItem(
                id: s.id.toString(),
                title: s.title,
                artist: s.artist,
                album: s.album,
                artUri: Uri.tryParse(s.image),
              ),
            );
          }).toList(),
    );

    await _player.stop();
    await _player.setAudioSource(_audioSource!, initialIndex: startIndex);
    await _player.play();
  }

  Future<void> playSong(Song song, List<Song> playlist) async {
    final index = playlist.indexWhere((s) => s.id == song.id);
    if (index == -1) return;
    await setPlaylist(playlist, startIndex: index);
  }

  Future<void> appendToQueue(List<Song> newSongs) async {
    if (_audioSource == null || _playlist.isEmpty) return;

    final newSources =
        newSongs.map((s) {
          return AudioSource.uri(
            Uri.parse(s.url),
            tag: MediaItem(
              id: s.id.toString(),
              title: s.title,
              artist: s.artist,
              album: s.album,
              artUri: Uri.tryParse(s.image),
            ),
          );
        }).toList();

    final currentIndex = _player.currentIndex ?? 0;
    final insertIndex = currentIndex + 1;

    _playlist.insertAll(insertIndex, newSongs);
    final concatSource = _audioSource as ConcatenatingAudioSource;
    await concatSource.insertAll(insertIndex, newSources);
  }

  Future<void> restoreLastPlayedSong() async {
    final box = await Hive.openBox('player_state');
    final lastPlayedSong = box.get('last_played_song') as Song?;
    final dynamicList = box.get('last_playlist');

    if (lastPlayedSong != null && dynamicList != null && dynamicList is List) {
      final List<Song> lastPlaylist = List<Song>.from(dynamicList);
      final index = lastPlaylist.indexWhere((s) => s.id == lastPlayedSong.id);

      if (index != -1) {
        currentSongNotifier.value = lastPlayedSong;
        _playlist = lastPlaylist;

        _audioSource = ConcatenatingAudioSource(
          children:
              lastPlaylist.map((s) {
                return AudioSource.uri(
                  Uri.parse(s.url),
                  tag: MediaItem(
                    id: s.id.toString(),
                    title: s.title,
                    artist: s.artist,
                    album: s.album,
                    artUri: Uri.tryParse(s.image),
                  ),
                );
              }).toList(),
        );

        await _player.setAudioSource(_audioSource!, initialIndex: index);
        // 🟡 Do not auto-play on app launch
      }
    }
  }

  void toggleShuffle() async {
    final enabled = !shuffleModeNotifier.value;
    shuffleModeNotifier.value = enabled;
    await _player.setShuffleModeEnabled(enabled);
  }

  void toggleRepeat() {
    LoopMode next;
    switch (_player.loopMode) {
      case LoopMode.off:
        next = LoopMode.all;
        break;
      case LoopMode.all:
        next = LoopMode.one;
        break;
      case LoopMode.one:
        next = LoopMode.off;
        break;
    }
    _player.setLoopMode(next);
    repeatModeNotifier.value = next;
  }

  void playNext() => _player.seekToNext();
  void playPrevious() => _player.seekToPrevious();

  Future<void> stop() async {
    await _player.stop();
    currentSongNotifier.value = null;
  }

  Future<void> setSong(Song song, List<Song> playlist) async {
    currentPlaylist = playlist;
    currentSongNotifier.value = song;

    await player.setAudioSource(
      AudioSource.uri(
        Uri.parse(song.url),
        tag: MediaItem(
          id: song.id.toString(),
          title: song.title,
          artist: song.artist,
          album: song.album,
          artUri: Uri.tryParse(song.image),
        ),
      ),
    );
  }
}
