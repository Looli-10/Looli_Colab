import 'package:flutter/material.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/Screens/PlayerPage.dart';
import 'package:looli_app/services/liked_songs_service.dart';
import 'package:looli_app/widgets/audio_manager.dart';
import 'package:looli_app/widgets/dialog_utils.dart';
import 'package:looli_app/widgets/mini_player.dart';

class LikedSongsPage extends StatefulWidget {
  const LikedSongsPage({super.key});

  @override
  State<LikedSongsPage> createState() => _LikedSongsPageState();
}

class _LikedSongsPageState extends State<LikedSongsPage> {
  List<Song> likedSongs = [];
  List<Song> filteredSongs = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isAscending = true;
  String _selectedLanguage = 'All';

  final List<String> _languages = ['All', 'english', 'tamil', 'hindi', 'telugu', 'kannada', 'malayalam'];

  @override
  void initState() {
    super.initState();
    likedSongs = LikedSongsService.getAllLiked();
    _searchController.addListener(_applyFilters);
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredSongs = likedSongs.where((song) {
        final matchSearch = song.title.toLowerCase().contains(query) || song.album.toLowerCase().contains(query);
        final matchLang = _selectedLanguage == 'All' || song.language.toLowerCase() == _selectedLanguage.toLowerCase();
        return matchSearch && matchLang;
      }).toList();

      filteredSongs.sort((a, b) => _isAscending ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
    });
  }

  void _playSong(Song song) async {
    await PlayerManager().playSong(song, likedSongs);
    PlayerManager().currentSongNotifier.value = song;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerPage(
          song: song,
          playlist: likedSongs,
          album: song.album,
        ),
      ),
    );
  }

  void _unlikeSong(Song song) {
    LikedSongsService.toggleLike(song);
    setState(() {
      likedSongs.removeWhere((s) => s.id == song.id);
      _applyFilters();
    });
  }

  void _unlikeAll() {
    LikedSongsService.clearAllLiked();
    setState(() {
      likedSongs.clear();
      filteredSongs.clear();
    });
  }

  void _showLanguageMenu() {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 16, 0),
      items: _languages.map((lang) {
        return PopupMenuItem<String>(
          value: lang,
          child: Text(lang),
        );
      }).toList(),
    ).then((value) {
      if (value != null && value != _selectedLanguage) {
        setState(() {
          _selectedLanguage = value;
          _applyFilters();
        });
      }
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
      backgroundColor: looliThird,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: looliFourth),
        backgroundColor: looliThird,
        title: const Text("Liked Songs", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_by_alpha, color: Colors.white),
            tooltip: "Sort",
            onPressed: () {
              setState(() {
                _isAscending = !_isAscending;
              });
              _applyFilters();
            },
          ),
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            tooltip: "Filter by Language",
            onPressed: _showLanguageMenu,
          ),
          if (likedSongs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              tooltip: "Unlike all",
              onPressed: () {
                showAnimatedConfirmDialog(
                  context: context,
                  message: "Are you sure you want to unlike all songs?",
                  onConfirmed: _unlikeAll,
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: looliThird,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search songs...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                filteredSongs.isEmpty
                    ? const Center(
                        child: Text(
                          "No liked songs found.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filteredSongs.length,
                        itemBuilder: (context, index) {
                          final song = filteredSongs[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(song.image, width: 60, height: 60, fit: BoxFit.cover),
                            ),
                            title: Text(
                              song.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              song.artist,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.redAccent),
                              onPressed: () => _unlikeSong(song),
                            ),
                            onTap: () => _playSong(song),
                          );
                        },
                      ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: MiniPlayer(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
