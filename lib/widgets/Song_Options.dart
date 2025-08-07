import 'package:flutter/material.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/services/Queue_service.dart';
import 'package:looli_app/widgets/audio_manager.dart';

class SongOptionsPopup extends StatelessWidget {
  final Song song;
  final List<Song> playlist;

  const SongOptionsPopup({
    super.key,
    required this.song,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) async {
        if (value == 'play') {
          await PlayerManager().playSong(song, playlist);
        } else if (value == 'queue') {
          await PlayerManager().appendToQueue([song]);
          // ✅ Save to Isar queue database
          await QueueService().addToQueue(song);
          print('Song added to queue: ${song.title}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${song.title} added to queue')),
          );
        }
      },
      itemBuilder:
          (context) => const [
            PopupMenuItem(value: 'play', child: Text('Play')),
            PopupMenuItem(value: 'queue', child: Text('Add to Queue')),
          ],
    );
  }
}
