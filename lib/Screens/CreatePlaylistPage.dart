import 'dart:io';

import 'package:flutter/material.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/Models/playlist.dart';
import 'package:looli_app/services/song_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CreatePlaylistPage extends StatefulWidget {
  const CreatePlaylistPage({super.key});

  @override
  State<CreatePlaylistPage> createState() => _CreatePlaylistPageState();
}

class _CreatePlaylistPageState extends State<CreatePlaylistPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<Song> _allSongs = [];
  List<Song> _filteredSongs = [];
  final List<Song> _selectedSongs = [];
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadSongs() async {
    final songs = await SongService().fetchSongsFromGitHub();
    setState(() {
      _allSongs = songs;
      _filteredSongs = songs;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSongs =
          _allSongs
              .where(
                (song) =>
                    song.title.toLowerCase().contains(query) ||
                    song.artist.toLowerCase().contains(query),
              )
              .toList();
    });
  }

  void _toggleSongSelection(Song song) {
    setState(() {
      if (_selectedSongs.contains(song)) {
        _selectedSongs.remove(song);
      } else {
        _selectedSongs.add(song);
      }
    });
  }

  void _savePlaylist() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedSongs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter name and select songs.")),
      );
      return;
    }

    final playlist = Playlist(
      name: name,
      songs: _selectedSongs,
      imagePath: _pickedImage?.path,
    );
    final box = Hive.box<Playlist>('custom_playlists');
    await box.add(playlist);

    Navigator.pop(context); // go back to Library
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final savedImage = await File(
        pickedFile.path,
      ).copy('${appDir.path}/$fileName.jpg');

      setState(() {
        _pickedImage = savedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: looliThird,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: looliFourth),
        backgroundColor: looliThird,
        elevation: 0,
        title: const Text(
          "Create Playlist",
          style: TextStyle(color: looliFourth),
        ),
        actions: [
          TextButton(
            onPressed: _savePlaylist,
            child: const Text("SAVE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Playlist name
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child:
                  _pickedImage != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_pickedImage!, fit: BoxFit.cover),
                      )
                      : const Icon(Icons.image, color: Colors.white30),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter playlist name",
                hintStyle: const TextStyle(color: Colors.white38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white12,
              ),
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search songs...",
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Song list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredSongs.length,
              itemBuilder: (context, index) {
                final song = _filteredSongs[index];
                final isSelected = _selectedSongs.contains(song);

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(song.image, width: 50, height: 50),
                  ),
                  title: Text(
                    song.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    song.artist,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: Icon(
                    isSelected ? Icons.check_circle : Icons.add_circle_outline,
                    color: isSelected ? Colors.green : Colors.white30,
                  ),
                  onTap: () => _toggleSongSelection(song),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
