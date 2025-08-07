import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/widgets/Song_Options.dart';
import 'package:looli_app/widgets/mini_player.dart';
import 'package:looli_app/widgets/audio_manager.dart';

class LanguageSongsPage extends StatefulWidget {
  final String languageTitle;
  final List<Song> songs;
  final List<Song> allSongs;

  const LanguageSongsPage({
    super.key,
    required this.languageTitle,
    required this.songs,
    required this.allSongs,
  });

  @override
  State<LanguageSongsPage> createState() => _LanguageSongsPageState();
}

class _LanguageSongsPageState extends State<LanguageSongsPage> {
  final _playerManager = PlayerManager();

  List<String> getAlbumsByArtist(String mainArtist) {
    final artistNormalized = mainArtist.trim().toLowerCase();
    final albums = <String>{};

    for (var song in widget.allSongs) {
      final firstArtist = song.artist.split(',').first.trim().toLowerCase();
      if (firstArtist == artistNormalized) {
        albums.add(song.album);
      }
    }

    final currentAlbum = widget.songs.first.album;
    albums.removeWhere(
      (album) =>
          album.trim().toLowerCase() == currentAlbum.trim().toLowerCase(),
    );

    return albums.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final fullArtistString = widget.songs.first.artist;
    final mainArtist = fullArtistString.split(',').first.trim();
    final albumsByArtist = getAlbumsByArtist(mainArtist);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.black,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  collapseMode: CollapseMode.parallax,
                  title: Text(
                    widget.languageTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.songs.first.image,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent,
                              Colors.black.withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (widget.songs.isNotEmpty) {
                          _playerManager.playSong(
                            widget.songs[0],
                            widget.songs,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("PLAY"),
                    ),
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = widget.songs[index];
                  return ValueListenableBuilder<Song?>(
                    valueListenable: _playerManager.currentSongNotifier,
                    builder: (context, currentSong, _) {
                      final isPlaying = currentSong?.id == song.id;
                      return GestureDetector(
                        onTap: () async {
                          await _playerManager.playSong(song, widget.songs);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 7,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isPlaying
                                    ? Colors.white.withOpacity(0.15)
                                    : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color:
                                  isPlaying ? Colors.white30 : Colors.white10,
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  song.image,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => const Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.white30,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight:
                                            isPlaying
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      song.artist,
                                      style: TextStyle(
                                        color:
                                            isPlaying
                                                ? Colors.white
                                                : Colors.white60,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SongOptionsPopup(
                                song: song,
                                playlist: widget.songs,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }, childCount: widget.songs.length),
              ),

              if (albumsByArtist.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: Colors.white24, thickness: 0.8),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'More albums by',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              mainArtist,
                              style: const TextStyle(
                                color: looliFirst,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Kola',
                                letterSpacing: 2.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Builder(
                          builder: (context) {
                            final shuffledAlbumsByArtist = [
                              ...albumsByArtist.where(
                                (a) => a != widget.languageTitle,
                              ),
                            ]..shuffle();

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: shuffledAlbumsByArtist.take(4).length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemBuilder: (context, index) {
                                final album = shuffledAlbumsByArtist[index];
                                final albumSongs =
                                    widget.allSongs
                                        .where(
                                          (song) =>
                                              song.album == album &&
                                              song.artist
                                                      .split(',')
                                                      .first
                                                      .trim()
                                                      .toLowerCase() ==
                                                  mainArtist.toLowerCase(),
                                        )
                                        .toList();

                                if (albumSongs.isEmpty) return const SizedBox();

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => LanguageSongsPage(
                                              languageTitle: album,
                                              songs: albumSongs,
                                              allSongs: widget.allSongs,
                                            ),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 10,
                                        sigmaY: 10,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.network(
                                                  albumSongs.first.image,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        _,
                                                        __,
                                                        ___,
                                                      ) => const Center(
                                                        child: Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          size: 60,
                                                          color: Colors.white54,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(1),
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(20),
                                                        bottomRight:
                                                            Radius.circular(20),
                                                      ),
                                                ),
                                                child: Text(
                                                  album,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
        ],
      ),
    );
  }
}
