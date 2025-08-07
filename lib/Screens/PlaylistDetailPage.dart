import 'dart:io';
import 'package:flutter/material.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Models/playlist.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/services/playlist_service.dart';
import 'package:looli_app/widgets/audio_manager.dart';
import 'package:looli_app/Screens/PlayerPage.dart';
import 'package:looli_app/widgets/mini_player.dart';
import 'package:looli_app/Screens/AddSongsToPlaylistPage.dart';

class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  String searchQuery = '';
  bool sortAscending = true;

  List<Song> get filteredSongs {
    final songs = widget.playlist.songs
        .where((s) => s.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    songs.sort((a, b) =>
        sortAscending ? a.title.compareTo(b.title) : b.title.compareTo(a.title));

    return songs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: looliThird,
      appBar: AppBar(
        title: Text(
          widget.playlist.name,
          style: const TextStyle(color: looliFourth),
        ),
        backgroundColor: looliThird,
        iconTheme: const IconThemeData(color: looliFourth),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_by_alpha, color: Colors.white),
            tooltip: "Sort",
            onPressed: () {
              setState(() {
                sortAscending = !sortAscending;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: "Add Songs",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddSongsToPlaylistPage(playlist: widget.playlist),
                ),
              );
              setState(() {}); // Reload after adding songs
            },
          ),
        ],
      ),
      body: Column(
        children: [
          /// 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                hintText: "Search songs...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// 🎵 Playlist Cover Image (if available)
          if (widget.playlist.imagePath != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.playlist.imagePath!),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          /// 🎶 Songs List
          Expanded(
            child: filteredSongs.isEmpty
                ? const Center(
                    child: Text(
                      'No songs found',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: filteredSongs.length,
                    itemBuilder: (context, index) {
                      final song = filteredSongs[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            color: looliFourth,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          song.artist,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                          onPressed: () async {
                            final box = PlaylistService.getBox();
                            final currentPlaylist = box.get(widget.playlist.key);
                            if (currentPlaylist != null) {
                              currentPlaylist.songs.removeWhere((s) => s.id == song.id);
                              await currentPlaylist.save();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PlaylistDetailPage(playlist: currentPlaylist),
                                ),
                              );
                            }
                          },
                        ),
                        onTap: () async {
                          final manager = PlayerManager();
                          await manager.playSong(song, widget.playlist.songs);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlayerPage(
                                song: song,
                                playlist: widget.playlist.songs,
                                album: widget.playlist.name,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),

          /// 🎧 Mini Player
          const MiniPlayer(),
        ],
      ),
    );
  }
}
