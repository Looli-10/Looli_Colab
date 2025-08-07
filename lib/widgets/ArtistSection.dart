import 'package:flutter/material.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/Screens/ArtistSongsPage.dart';

class ArtistAlbumCardSection extends StatelessWidget {
  final List<Song> allSongs;
  final Map<String, String> artistImageMap;

  const ArtistAlbumCardSection({
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

    final limitedArtists = artistGroups.entries.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            "Artists",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: limitedArtists.length,
            itemBuilder: (context, index) {
              final entry = limitedArtists[index];
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
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: Text(
                          artist,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
