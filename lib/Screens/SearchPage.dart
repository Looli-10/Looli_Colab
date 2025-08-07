import 'package:flutter/material.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/Screens/PlayerPage.dart';
import 'package:looli_app/widgets/ArtistListSection.dart';
import 'package:looli_app/widgets/FullAlbumGridSection.dart';
import 'package:looli_app/widgets/Song_Options.dart';
import 'package:looli_app/widgets/audio_manager.dart';
import 'package:looli_app/widgets/mini_player.dart';

class SearchPage extends StatefulWidget {
  final List<Song> allSongs;
  final VoidCallback onBackToHome;
  final Map<String, String> artistImageMap;

  const SearchPage({
    super.key,
    required this.allSongs,
    required this.onBackToHome,
    required this.artistImageMap,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  int selectedTabIndex = 0;
  List<Song> filteredSongs = [];
  List<String> filteredAlbums = [];
  List<MapEntry<String, String>> filteredArtists = [];

  @override
  void initState() {
    super.initState();
    filteredSongs = widget.allSongs;
    filteredAlbums = widget.allSongs.map((song) => song.album).toSet().toList();
    filteredArtists = widget.artistImageMap.entries.toList();
  }

  void updateSearch(String newQuery) {
    setState(() {
      query = newQuery.toLowerCase();

      if (selectedTabIndex == 0) {
        filteredSongs =
            widget.allSongs.where((song) {
              return song.title.toLowerCase().contains(query) ||
                  song.artist.toLowerCase().contains(query) ||
                  song.album.toLowerCase().contains(query);
            }).toList();
      } else if (selectedTabIndex == 1) {
        filteredAlbums =
            widget.allSongs
                .map((song) => song.album)
                .where((album) => album.toLowerCase().contains(query))
                .toSet()
                .toList();
      } else if (selectedTabIndex == 2) {
        filteredArtists =
            widget.artistImageMap.entries
                .where((entry) => entry.key.toLowerCase().contains(query))
                .toList();
      }
    });
  }

  void onTabChanged(int index) {
    FocusScope.of(context).unfocus();
    setState(() {
      selectedTabIndex = index;
      updateSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          widget.onBackToHome();
          return false;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Column(
                children: [
                  /// 🔍 Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          offset: Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: widget.onBackToHome,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.white,
                              decoration: const InputDecoration(
                                hintText: 'Search songs, artists, albums',
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                                icon: Icon(Icons.search, color: Colors.white54),
                              ),
                              onChanged: updateSearch,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// 🗂 Tabs
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: Colors.black,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _tabButton("Songs", 0),
                        const SizedBox(width: 12),
                        _tabButton("Albums", 1),
                        const SizedBox(width: 12),
                        _tabButton("Artists", 2),
                      ],
                    ),
                  ),

                  /// 📋 Content
                  Expanded(
                    child: Container(
                      color: Colors.black,
                      child:
                          selectedTabIndex == 0
                              ? buildSongsList()
                              : selectedTabIndex == 1
                              ? FullAlbumGridSection(
                                albums:
                                    filteredAlbums.map((albumTitle) {
                                      return Album(
                                        title: albumTitle,
                                        image:
                                            widget.allSongs
                                                .firstWhere(
                                                  (s) => s.album == albumTitle,
                                                )
                                                .image,
                                        songs:
                                            widget.allSongs
                                                .where(
                                                  (s) => s.album == albumTitle,
                                                )
                                                .toList(),
                                      );
                                    }).toList(), allSongs: widget.allSongs,
                              )
                              : ArtistListSection(
                                allSongs: widget.allSongs,
                                artistImageMap: Map.fromEntries(
                                  filteredArtists,
                                ),
                              ),
                    ),
                  ),
                ],
              ),

              /// 🎵 Mini Player
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MiniPlayer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎶 Songs Tab List
  Widget buildSongsList() {
    if (filteredSongs.isEmpty) {
      return const Center(
        child: Text("No songs found", style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.builder(
      itemCount: filteredSongs.length,
      padding: const EdgeInsets.only(bottom: 90),
      itemBuilder: (context, index) {
        final song = filteredSongs[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                song.image,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              song.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins'
              ),
            ),
            subtitle: Text(
              '${song.artist} • ${song.album}',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () async {
              FocusScope.of(context).unfocus();
              await PlayerManager().playSong(song, filteredSongs);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => PlayerPage(
                        song: song,
                        playlist: filteredSongs,
                        album: song.album,
                      ),
                ),
              );
            },
            trailing: SongOptionsPopup(song: song, playlist: filteredSongs),
          ),
        );
      },
    );
  }

  /// 🏷 Pill-style Tab Button
  Widget _tabButton(String label, int index) {
    final isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? looliFirst : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}
