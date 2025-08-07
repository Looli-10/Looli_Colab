import 'package:flutter/material.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/Screens/AlbumSongsPage.dart';
import 'package:looli_app/widgets/audio_manager.dart';

class AlbumsGridSection extends StatelessWidget {
  final List<Album> albums;
  final List<Song> song;
  final PlayerManager playerManager = PlayerManager();

  AlbumsGridSection({super.key, required this.albums, required this.song});

  @override
  Widget build(BuildContext context) {
    final limitedAlbums = albums.take(5).toList();
    final currentSong = playerManager.currentSongNotifier.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Random Albums',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Card Container
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2E2C2F),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ValueListenableBuilder<Song?>(
              valueListenable: playerManager.currentSongNotifier,
              builder: (context, current, _) {
                return Column(
                  children: limitedAlbums.map((album) {
                    final isPlaying = current != null &&
                        album.songs.any((s) => s.id == current.id);

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AlbumSongsPage(
                              albumTitle: album.title,
                              songs: album.songs,
                              allSongs:song
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isPlaying ? looliFourth.withOpacity(0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: isPlaying
                              ? Border.all(color: looliFourth, width: 1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Album image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                album.image,
                                width: 45,
                                height: 45,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.music_note, color: Colors.white54),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Title + Artist
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    album.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    album.songs.first.artist,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 13,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Play Icon
                            IconButton(
                              icon: Icon(
                                isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_fill,
                                color: looliFourth,
                                size: 28,
                              ),
                              onPressed: () {
                                if (album.songs.isNotEmpty) {
                                  final firstSong = album.songs.first;
                                  playerManager.playSong(firstSong, album.songs);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
