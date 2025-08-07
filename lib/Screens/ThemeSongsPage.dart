import 'package:flutter/material.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/widgets/mini_player.dart';
import 'package:looli_app/widgets/audio_manager.dart';
import 'package:looli_app/widgets/Song_Options.dart';

class ThemeSongsPage extends StatefulWidget {
  final String themeTitle;
  final List<Song> songs;

  const ThemeSongsPage({
    super.key,
    required this.themeTitle,
    required this.songs,
  });

  @override
  State<ThemeSongsPage> createState() => _ThemeSongsPageState();
}

class _ThemeSongsPageState extends State<ThemeSongsPage> {
  final _playerManager = PlayerManager();
  final TextEditingController _searchController = TextEditingController();
  List<Song> _filteredSongs = [];
  String _selectedLanguage = 'All';
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _filteredSongs = widget.songs;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    List<Song> filtered = widget.songs.where((song) {
      final title = song.title.toLowerCase();
      final artist = song.artist.toLowerCase();
      final matchesSearch = title.contains(query) || artist.contains(query);
      final matchesLanguage =
          _selectedLanguage == 'All' || song.language == _selectedLanguage;
      return matchesSearch && matchesLanguage;
    }).toList();

    filtered.sort((a, b) => _isAscending
        ? a.title.compareTo(b.title)
        : b.title.compareTo(a.title));

    setState(() {
      _filteredSongs = filtered;
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
          widget.themeTitle,
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
          // Language filter dropdown
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.black87,
              value: _selectedLanguage,
              icon: const Icon(Icons.language, color: Colors.white),
              style: const TextStyle(color: Colors.white),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                  _onSearchChanged();
                }
              },
              items: <String>['All', 'English', 'Tamil', 'Hindi']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),

          // Sort order toggle
          IconButton(
            icon: Icon(
              _isAscending ? Icons.sort_by_alpha : Icons.sort,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isAscending = !_isAscending;
              });
              _onSearchChanged();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search songs...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Song list
                Expanded(
                  child: ValueListenableBuilder<Song?>(
                    valueListenable: _playerManager.currentSongNotifier,
                    builder: (context, currentSong, _) {
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        itemCount: _filteredSongs.length,
                        itemBuilder: (context, index) {
                          final song = _filteredSongs[index];
                          final isPlaying = currentSong?.id == song.id;

                          return GestureDetector(
                            onTap: () async {
                              await _playerManager.playSong(song, widget.songs);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isPlaying
                                    ? Colors.white.withOpacity(0.15)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isPlaying ? Colors.white30 : Colors.white10,
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
                                            fontWeight: isPlaying
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          song.artist,
                                          style: TextStyle(
                                            color: isPlaying
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
                    },
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(),
          ),
        ],
      ),
    );
  }
}
