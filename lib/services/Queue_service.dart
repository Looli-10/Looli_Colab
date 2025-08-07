import 'package:hive/hive.dart';
import 'package:looli_app/Models/songs.dart';

class QueueService {
  final String _boxName = 'queue';

  Future<Box<Song>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Song>(_boxName);
    }
    return Hive.box<Song>(_boxName);
  }

  /// ✅ Add song to queue
  Future<void> addToQueue(Song song) async {
    final box = await _getBox();
    await box.put(song.id, song);
    print("✅ Song added to Hive queue: ${song.title}");
  }

  /// ✅ Get queue
  Future<List<Song>> getQueue() async {
    final box = await _getBox();
    return box.values.toList();
  }

  /// ✅ Clear queue
  Future<void> clearQueue() async {
    final box = await _getBox();
    await box.clear();
  }

  /// ✅ Remove from queue by ID
  Future<void> removeFromQueue(String songId) async {
    final box = await _getBox();
    await box.delete(songId);
  }
}
