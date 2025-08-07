import 'package:flutter/material.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/Screens/ArtistSongsPage.dart';

class ArtistListSection extends StatelessWidget {
  final List<Song> allSongs;
  final Map<String, String> artistImageMap;

  const ArtistListSection({
    super.key,
    required this.allSongs,
    required this.artistImageMap,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Song>> artistGroups = {};

    for (var artistKey in artistImageMap.keys) {
      final matchedSongs = allSongs.where((song) {
        final songArtists = song.artist
            .split(',')
            .map((s) => s.trim().toLowerCase())
            .toList();
        return songArtists.contains(artistKey.toLowerCase());
      }).toList();

      if (matchedSongs.isNotEmpty) {
        artistGroups[artistKey] = matchedSongs;
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // disables GridView's own scrolling
            padding: const EdgeInsets.symmetric(horizontal: 16),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1,
            children: artistGroups.entries.map((entry) {
              final artist = entry.key;
              final artistSongs = entry.value;
              final image = artistImageMap[artist]!;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArtistSongsPage(
                        artist: artist,
                        songs: artistSongs,
                        artistImage: image,
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    ClipOval(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      artist,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16), // to add space at the bottom
        ],
      ),
    );
  }
}
