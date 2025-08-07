import 'dart:io';
import 'package:flutter/material.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Screens/AddSongsToPlaylistPage.dart';
import 'package:looli_app/Screens/PlaylistDetailPage.dart';
import 'package:looli_app/services/liked_songs_service.dart';
import 'package:looli_app/widgets/dialog_utils.dart';
import 'package:looli_app/widgets/mini_player.dart';
import 'package:looli_app/Screens/LikedSongsPage.dart';
import 'package:looli_app/Screens/CreatePlaylistPage.dart';
import 'package:looli_app/services/playlist_service.dart';
import 'package:looli_app/Models/playlist.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<Playlist> playlists = [];

  @override
  void initState() {
    super.initState();
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    playlists = await PlaylistService.getAllPlaylists();
    setState(() {});
  }
  Future<void> _refreshPlaylists() async {
  final updatedPlaylists = await PlaylistService.getAllPlaylists();
  setState(() {
    playlists = updatedPlaylists;
  });
}


  @override
  Widget build(BuildContext context) {
    final likedSongs = LikedSongsService.getAllLiked();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Library",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 85),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 16),
                sectionHeader("Your Collection"),

                /// 💜 Liked Songs Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LikedSongsPage()),
                    );
                  },
                  child: containerCard(
                    child: Row(
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [looliFirst, looliSecond],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Liked Songs",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 4),
                              ValueListenableBuilder<int>(
                                valueListenable:
                                    LikedSongsService.likedCountNotifier,
                                builder: (context, value, _) {
                                  return Text(
                                    "$value songs",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.white54,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                sectionHeader("Playlists"),

                /// 📂 Playlist List
                if (playlists.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "No playlists created yet.",
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                else
                  ListView.builder(
                    itemCount: playlists.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return GestureDetector(
                        onTap: () {
                          final result = Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => PlaylistDetailPage(playlist: playlist),
                            ),
                          );
                          if(result==true){
                            _refreshPlaylists();
                          }
                        },
                        child: containerCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white12,
                                ),
                                child:
                                    playlist.imagePath != null
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            File(playlist.imagePath!),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                        : const Icon(
                                          Icons.queue_music,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  playlist.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white70,
                                ),
                                color: looliFourth,
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => AddSongsToPlaylistPage(
                                              playlist: playlist,
                                            ),
                                      ),
                                    );
                                  } else if (value == 'delete') {
                                    showAnimatedConfirmDialog(
                                      context: context,
                                      title: "Delete Playlist",
                                      message:
                                          "Are you sure you want to delete this playlist?",
                                      onConfirmed: () async {
                                        final box = PlaylistService.getBox();
                                        await box.delete(playlist.key);
                                        setState(() {
                                          playlists.removeAt(index);
                                        });
                                      },
                                    );
                                  }
                                },
                                itemBuilder:
                                    (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit Playlist'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete Playlist'),
                                      ),
                                    ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 24),

                /// ➕ Create Playlist
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreatePlaylistPage(),
                      ),
                    );
                    loadPlaylists(); // Reload on return
                  },
                  child: containerCard(
                    border: Border.all(color: Colors.white12),
                    child: Row(
                      children: const [
                        Icon(Icons.playlist_add, color: Colors.white, size: 26),
                        SizedBox(width: 12),
                        Text(
                          "Create Playlist",
                          style: TextStyle(color: Colors.white, fontSize: 16,fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          /// 🎵 Mini Player
          const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
        ],
      ),
    );
  }

  /// Section Header Widget
  Widget sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: looliFourth,
        fontFamily: 'Poppins',
      ),
    );
  }

  /// Reusable container card
  Widget containerCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    BoxBorder? border,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: border,
      ),
      child: child,
    );
  }
}
