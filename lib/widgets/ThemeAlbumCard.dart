import 'package:flutter/material.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/Screens/ThemeSongsPage.dart';

class ThemeAlbumCardSection extends StatelessWidget {
  final List<Song> allSongs;
  final Map<String, String> themeImageMap;

  const ThemeAlbumCardSection({
    super.key,
    required this.allSongs,
    required this.themeImageMap,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Song>> themeGroups = {};

    for (var song in allSongs) {
      final theme = song.theme?.toLowerCase().trim();
      if (theme == null || theme.isEmpty) continue;
      themeGroups.putIfAbsent(theme, () => []).add(song);
    }

    final limitedThemes = themeGroups.entries.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            "How’s your mood?",
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
            itemCount: limitedThemes.length,
            itemBuilder: (context, index) {
              final entry = limitedThemes[index];
              final theme = entry.key;
              final themeSongs = entry.value;
              final image = themeImageMap[theme] ??
                  themeImageMap['default'] ??
                  'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_960_720.jpg';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ThemeSongsPage(
                        themeTitle: theme[0].toUpperCase() + theme.substring(1),
                        songs: themeSongs,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.cover,
                    ),
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
                                Colors.black.withOpacity(0.6),
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
                          theme[0].toUpperCase() + theme.substring(1),
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
