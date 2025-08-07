import 'package:flutter/material.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Screens/AlbumSongsPage.dart';
import 'package:looli_app/widgets/audio_manager.dart';
import '../Models/songs.dart';

class LatestReleaseCard extends StatelessWidget {
  final Album album;

  const LatestReleaseCard({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    // Extract first artist name
    String artistName = '';
    if (album.songs.isNotEmpty) {
      final firstArtist = album.songs.first.artist.trim();
      artistName = firstArtist.split(',').first.trim();
    }

    final PlayerManager playerManager = PlayerManager();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title above the card
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
            child: Text(
              'Latest Release',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          // Card with increased height
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AlbumSongsPage(
                        albumTitle: album.title,
                        songs: album.songs,
                        allSongs: [],
                      ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Card(
              color: const Color(0xFF2E2C2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                height: 120, // Increased height here
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Album Image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Image.network(
                        album.image,
                        width: 120,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Info + Play
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Album info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[850],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Text(
                                    album.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    artistName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Play button
                            IconButton(
                              icon: const Icon(
                                Icons.play_circle_fill,
                                color: looliFirst,
                                size: 46,
                              ),
                              onPressed: () {
                                if (album.songs.isNotEmpty) {
                                  final firstSong = album.songs.first;
                                  playerManager.playSong(
                                    firstSong,
                                    album.songs,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
