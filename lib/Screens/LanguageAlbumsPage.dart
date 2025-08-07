import 'package:flutter/material.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/Screens/AlbumSongsPage.dart';
import 'package:looli_app/Screens/LanguageSongsPage.dart';
import 'package:looli_app/widgets/mini_player.dart';

class LanguageAlbumsPage extends StatefulWidget {
  final String language;
  final List<Song> songs;

  const LanguageAlbumsPage({
    super.key,
    required this.language,
    required this.songs,
  });

  @override
  State<LanguageAlbumsPage> createState() => _LanguageAlbumsPageState();
}

class _LanguageAlbumsPageState extends State<LanguageAlbumsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Album> _filteredAlbums = [];
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _groupSongsByAlbum();
    _searchController.addListener(_applyFilter);
  }

  void _groupSongsByAlbum() {
    final Map<String, List<Song>> albumMap = {};

    for (var song in widget.songs) {
      if (song.language.toLowerCase() == widget.language.toLowerCase()) {
        albumMap.putIfAbsent(song.album, () => []).add(song);
      }
    }

    _filteredAlbums =
        albumMap.entries.map((entry) {
          return Album(
            title: entry.key,
            image: entry.value.first.image,
            songs: entry.value,
          );
        }).toList();

    _applySorting();
  }

  void _applySorting() {
    _filteredAlbums.sort(
      (a, b) =>
          _isAscending
              ? a.title.compareTo(b.title)
              : b.title.compareTo(a.title),
    );
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();

    final Map<String, List<Song>> albumMap = {};
    for (var song in widget.songs) {
      if (song.language.toLowerCase() == widget.language.toLowerCase() &&
          song.album.toLowerCase().contains(query)) {
        albumMap.putIfAbsent(song.album, () => []).add(song);
      }
    }

    setState(() {
      _filteredAlbums =
          albumMap.entries.map((entry) {
            return Album(
              title: entry.key,
              image: entry.value.first.image,
              songs: entry.value,
            );
          }).toList();
      _applySorting();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.language,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => _isAscending = !_isAscending);
              _applyFilter();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search albums...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white54,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    itemCount: _filteredAlbums.length,
                    itemBuilder: (context, index) {
                      final album = _filteredAlbums[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => LanguageSongsPage(
                                    languageTitle:widget.language,
                                    songs: album.songs,
                                    allSongs:widget.songs,
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  album.image,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  album.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                "${album.songs.length} songs",
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
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
            ),
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
        ],
      ),
    );
  }
}
