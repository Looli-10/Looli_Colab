import 'package:flutter/material.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Screens/PlayerPage.dart';
import 'package:looli_app/widgets/audio_manager.dart';
import 'package:looli_app/Models/songs.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final _player = PlayerManager().player;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Listen for playback time
    _player.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });

    // Listen for track duration
    _player.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() => _duration = duration);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Song?>(
      valueListenable: PlayerManager().currentSongNotifier,
      builder: (context, song, _) {
        if (song == null) return const SizedBox.shrink();

        double progress =
            (_duration.inMilliseconds > 0)
                ? _position.inMilliseconds / _duration.inMilliseconds
                : 0.0;

        return GestureDetector(
          onTap: () {
            final current = PlayerManager().currentSongNotifier.value;
            final playlist = PlayerManager().currentPlaylist;

            if (current != null && playlist.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => PlayerPage(
                        song: current,
                        playlist: playlist,
                        album: song.album,
                      ),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[looliFirst, looliSecond],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Progress bar
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(25),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Song info and controls
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          song.image,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(
                                color: looliSixth,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              song.artist,
                              style: const TextStyle(
                                color: looliThird,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _player.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: looliSixth,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_player.playing) {
                              _player.pause();
                            } else {
                              _player.play();
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
