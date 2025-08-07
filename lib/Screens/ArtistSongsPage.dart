import 'package:flutter/material.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/widgets/Song_Options.dart';
import 'package:looli_app/widgets/audio_manager.dart';
import 'package:looli_app/widgets/mini_player.dart';

class ArtistSongsPage extends StatefulWidget {
  final String artist;
  final List<Song> songs;
  final String artistImage;

  const ArtistSongsPage({
    super.key,
    required this.artist,
    required this.songs,
    required this.artistImage,
  });

  @override
  State<ArtistSongsPage> createState() => _ArtistSongsPageState();
}

class _ArtistSongsPageState extends State<ArtistSongsPage>
    with TickerProviderStateMixin {
  final PlayerManager _playerManager = PlayerManager();
  final TextEditingController _searchController = TextEditingController();
  List<Song> _filteredSongs = [];
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _filteredSongs = widget.songs;
    _searchController.addListener(_applyFilters);
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSongs =
          widget.songs.where((song) {
            return song.title.toLowerCase().contains(query) ||
                song.album.toLowerCase().contains(query);
          }).toList();

      _filteredSongs.sort(
        (a, b) =>
            _isAscending
                ? a.title.compareTo(b.title)
                : b.title.compareTo(a.title),
      );
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
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                backgroundColor: Colors.black,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  collapseMode: CollapseMode.parallax,
                  title: Text(
                    widget.artist,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(widget.artistImage, fit: BoxFit.cover),
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

              // Play Button below AppBar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Align(
                    alignment:
                        Alignment
                            .bottomCenter, // Or Alignment.center if you want center alignment
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_filteredSongs.isNotEmpty) {
                          _playerManager.playSong(
                            _filteredSongs[0],
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

              // Search Field
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search songs...',
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isAscending
                              ? Icons.sort_by_alpha
                              : Icons.sort_by_alpha_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() => _isAscending = !_isAscending);
                          _applyFilters();
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Song List
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = _filteredSongs[index];
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
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  song.image,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.music_note,
                                            color: Colors.white54,
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
                                      song.album,
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
                }, childCount: _filteredSongs.length),
              ),

              // Add spacing at bottom so MiniPlayer doesn't overlap
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // Mini Player at the bottom
          const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
        ],
      ),
    );
  }
}
