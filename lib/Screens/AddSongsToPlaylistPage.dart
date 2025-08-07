import 'package:flutter/material.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Models/playlist.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/services/playlist_service.dart';
import 'package:looli_app/services/song_service.dart';

class AddSongsToPlaylistPage extends StatefulWidget {
  final Playlist playlist;

  const AddSongsToPlaylistPage({super.key, required this.playlist});

  @override
  State<AddSongsToPlaylistPage> createState() => _AddSongsToPlaylistPageState();
}

class _AddSongsToPlaylistPageState extends State<AddSongsToPlaylistPage> {
  List<Song> allSongs = [];
  List<Song> filteredSongs = [];
  final TextEditingController searchController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.playlist.name;
    fetchSongs();
    searchController.addListener(_onSearch);
  }

  void fetchSongs() async {
    final songs = await SongService().fetchSongsFromGitHub();
    setState(() {
      allSongs = songs;
      filteredSongs = songs;
    });
  }

  void _onSearch() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredSongs = allSongs
          .where((s) => s.title.toLowerCase().contains(query) || s.artist.toLowerCase().contains(query))
          .toList();
    });
  }

  void _toggleSong(Song song) {
    setState(() {
      if (widget.playlist.songs.any((s) => s.id == song.id)) {
        widget.playlist.songs.removeWhere((s) => s.id == song.id);
      } else {
        widget.playlist.songs.add(song);
      }
    });
  }

  Future<void> _saveChanges() async {
    final newName = nameController.text.trim();
    final box = PlaylistService.getBox();

    widget.playlist.name = newName;
    await widget.playlist.save(); // Save changes to the Hive object

    Navigator.pop(context); // Go back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: looliThird,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: looliFourth),
        backgroundColor: looliThird,
        title: const Text("Edit Playlist", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text("SAVE", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        children: [
          // Playlist name field
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Playlist name",
                hintStyle: const TextStyle(color: Colors.white38),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.white10,
              ),
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search songs...",
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Song list
          Expanded(
            child: ListView.builder(
              itemCount: filteredSongs.length,
              itemBuilder: (context, index) {
                final song = filteredSongs[index];
                final isSelected = widget.playlist.songs.any((s) => s.id == song.id);

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(song.image, width: 50, height: 50),
                  ),
                  title: Text(song.title, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(song.artist, style: const TextStyle(color: Colors.white54)),
                  trailing: Icon(
                    isSelected ? Icons.check_circle : Icons.add_circle_outline,
                    color: isSelected ? Colors.green : Colors.white30,
                  ),
                  onTap: () => _toggleSong(song),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
