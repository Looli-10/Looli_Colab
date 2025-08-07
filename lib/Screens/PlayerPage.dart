import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:like_button/like_button.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/services/Liked_songs_service.dart';
import 'package:looli_app/widgets/audio_manager.dart';
import 'package:looli_app/services/queue_service.dart';
import 'package:looli_app/widgets/up_next_drawer.dart';
import 'package:simple_waveform_progressbar/simple_waveform_progressbar.dart'; // ✅ Added import

class PlayerPage extends StatefulWidget {
  final Song song;
  final List<Song> playlist;

  const PlayerPage({
    super.key,
    required this.song,
    required this.playlist,
    required album,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final _manager = PlayerManager();
  late final _player = _manager.player;

  bool isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _init();
    _listenToPlayer();
  }

  void _init() async {
    if (_player.playing) return;

    await _manager.setPlaylist(
      widget.playlist,
      startIndex: widget.playlist.indexWhere((s) => s.id == widget.song.id),
    );

    final queue = await QueueService().getQueue();
    if (queue.isNotEmpty) {
      await _manager.appendToQueue(queue);
    }
  }

  void _listenToPlayer() {
    _player.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() => _duration = duration);
      }
    });

    _player.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });

    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() => isPlaying = state.playing);
      }
    });
  }

  void _togglePlayback() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  void _toggleRepeat() => _manager.toggleRepeat();
  void _toggleShuffle() => _manager.toggleShuffle();
  void _nextSong() => _manager.playNext();
  void _previousSong() => _manager.playPrevious();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: looliThird,
      extendBodyBehindAppBar: true,
      body: ValueListenableBuilder<Song?>(
        valueListenable: _manager.currentSongNotifier,
        builder: (context, currentSong, _) {
          if (currentSong == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(currentSong.image, fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(color: Colors.black.withOpacity(0.5)),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10.h),
                      Text(
                        "Playing from\n${currentSong.album}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          currentSong.image,
                          height: 320.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 30.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  currentSong.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  currentSong.artist,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Container(
                                  width: double.infinity,
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.transparent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.transparent,
                                        offset: const Offset(0, 4),
                                        spreadRadius: 5,
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: WaveformProgressbar(
                                    color: Colors.grey,
                                    progressColor: looliFirst,
                                    progress:
                                        _duration.inSeconds > 0
                                            ? _position.inSeconds /
                                                _duration.inSeconds
                                            : 0.0,
                                    onTap: (prgs) {
                                      final newPosition =
                                          (_duration.inSeconds * prgs).toInt();
                                      _player.seek(
                                        Duration(seconds: newPosition),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(_position),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(_duration),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.skip_previous),
                                      color: Colors.white,
                                      iconSize: 38,
                                      onPressed: _previousSong,
                                    ),
                                    SizedBox(width: 20.w),
                                    Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 10,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                        ),
                                        color: looliSixth,
                                        iconSize: 38,
                                        onPressed: _togglePlayback,
                                      ),
                                    ),
                                    SizedBox(width: 20.w),
                                    IconButton(
                                      icon: const Icon(Icons.skip_next),
                                      color: Colors.white,
                                      iconSize: 38,
                                      onPressed: _nextSong,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Repeat Button
                                    ValueListenableBuilder(
                                      valueListenable:
                                          _manager.repeatModeNotifier,
                                      builder: (_, mode, __) {
                                        IconData icon =
                                            mode == LoopMode.one
                                                ? Icons.repeat_one
                                                : Icons.repeat;
                                        return IconButton(
                                          icon: Icon(icon),
                                          color:
                                              mode == LoopMode.off
                                                  ? looliFourth
                                                  : looliFirst,
                                          onPressed: _toggleRepeat,
                                        );
                                      },
                                    ),

                                    // Like Button
                                    ValueListenableBuilder<Song?>(
                                      valueListenable:
                                          _manager.currentSongNotifier,
                                      builder: (context, currentSong, _) {
                                        if (currentSong == null)
                                          return const SizedBox();

                                        final isInitiallyLiked =
                                            LikedSongsService.isLiked(
                                              currentSong.id,
                                            );

                                        return LikeButton(
                                          isLiked: isInitiallyLiked,
                                          size: 30,
                                          circleColor: const CircleColor(
                                            start: Color(0xff00ddff),
                                            end: Color(0xff0099cc),
                                          ),
                                          bubblesColor: const BubblesColor(
                                            dotPrimaryColor: Colors.pink,
                                            dotSecondaryColor: Colors.white,
                                          ),
                                          likeBuilder: (bool isLiked) {
                                            return Icon(
                                              Icons.favorite,
                                              color:
                                                  isLiked
                                                      ? Colors.red
                                                      : Colors.white
                                                          .withOpacity(0.5),
                                              size: 30,
                                            );
                                          },
                                          onTap: (bool isCurrentlyLiked) async {
                                            if (isCurrentlyLiked) {
                                              await LikedSongsService.unlikeSong(
                                                currentSong.id,
                                              );
                                            } else {
                                              await LikedSongsService.likeSong(
                                                currentSong,
                                              );
                                            }

                                            // Optionally update the notifier if you rely on external listeners
                                            _manager.currentSongNotifier.value =
                                                _manager
                                                    .currentSongNotifier
                                                    .value;

                                            return !isCurrentlyLiked;
                                          },
                                        );
                                      },
                                    ),

                                    // Queue Icon Button (Newly Moved Here)
                                    IconButton(
                                      icon: const Icon(Icons.queue_music),
                                      color: Colors.white,
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          backgroundColor: Colors.transparent,
                                          isScrollControlled: true,
                                          builder: (_) => const UpNextDrawer(),
                                        );
                                      },
                                    ),

                                    // Shuffle Button
                                    ValueListenableBuilder(
                                      valueListenable:
                                          _manager.shuffleModeNotifier,
                                      builder: (_, isShuffled, __) {
                                        return IconButton(
                                          icon: const Icon(Icons.shuffle),
                                          color:
                                              isShuffled
                                                  ? looliFirst
                                                  : looliFourth,
                                          onPressed: _toggleShuffle,
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
