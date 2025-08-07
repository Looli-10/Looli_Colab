import 'package:flutter/material.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/services/queue_service.dart';
import 'package:looli_app/widgets/audio_manager.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';

class UpNextDrawer extends StatefulWidget {
  const UpNextDrawer({Key? key}) : super(key: key);

  @override
  State<UpNextDrawer> createState() => _UpNextDrawerState();
}

class _UpNextDrawerState extends State<UpNextDrawer> {
  late Future<List<Song>> _queueFuture;

  @override
  void initState() {
    super.initState();
    _refreshQueue();
  }

  void _refreshQueue() {
    _queueFuture = QueueService().getQueue();
  }

  Future<void> _removeSong(Song song) async {
    await QueueService().removeFromQueue(song.id);
    _refreshQueue();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentId = PlayerManager().currentSongNotifier.value?.id;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: looliThird,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: FutureBuilder<List<Song>>(
        future: _queueFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Queue is empty',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final queue = snapshot.data!;

          return Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Up Next',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ReorderableListView.builder(
                  onReorder: (oldIndex, newIndex) async {
                    if (newIndex > oldIndex) newIndex--;

                    final updatedQueue = List<Song>.from(queue);
                    final song = updatedQueue.removeAt(oldIndex);
                    updatedQueue.insert(newIndex, song);

                    final service = QueueService();
                    await service.clearQueue();
                    for (final s in updatedQueue) {
                      await service.addToQueue(s);
                    }

                    setState(() => _refreshQueue());
                  },
                  itemCount: queue.length,
                  itemBuilder: (context, index) {
                    final song = queue[index];
                    final isPlaying = song.id == currentId;

                    return ListTile(
                      key: ValueKey(song.id),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          song.image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.music_note),
                        ),
                      ),
                      title: Text(
                        song.title,
                        style: TextStyle(
                          color: isPlaying ? looliSecond : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        song.artist,
                        style: const TextStyle(color: Colors.white60),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _removeSong(song),
                      ),
                      onTap: () async {
                        final player = PlayerManager();
                        final fullList = player.currentPlaylist;

                        final matchIndex = fullList.indexWhere((s) => s.id == song.id);
                        if (matchIndex != -1) {
                          await player.playSong(fullList[matchIndex], fullList);
                        } else {
                          await player.playSong(song, [song]);
                        }

                        player.currentSongNotifier.value = song;
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
