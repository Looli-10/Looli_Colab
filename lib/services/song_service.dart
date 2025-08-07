import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/songs.dart';

class SongService {
  static const String _jsonUrl =
      'https://raw.githubusercontent.com/Looli-10/Looli_Data/main/data.json';

  static const String _themeDataUrl =
      'https://raw.githubusercontent.com/Looli-10/Looli_Data/main/theme_data.json';

  static const String _artistDataUrl =
      'https://raw.githubusercontent.com/Looli-10/Looli_Data/main/artist_data.json';

  static const String _languageDataUrl =
      'https://raw.githubusercontent.com/Looli-10/Looli_Data/main/language.json';

  /// 🔹 Fetch all songs
  Future<List<Song>> fetchSongsFromGitHub() async {
    final response = await http.get(Uri.parse(_jsonUrl));

    if (response.statusCode == 200) {
      final List<dynamic> albumsJson = jsonDecode(response.body);
      List<Song> allSongs = [];

      for (var album in albumsJson) {
        final String albumTitle = album['title'] ?? 'Unknown Album';
        final List<dynamic> songs = album['songs'];

        allSongs.addAll(
          songs.map((json) {
            return Song.fromJson({...json, 'album': albumTitle});
          }).toList(),
        );
      }

      return allSongs;
    } else {
      throw Exception('Failed to load songs from GitHub');
    }
  }

  /// 🔹 Fetch all albums
  Future<List<Album>> fetchAlbumsFromGitHub() async {
    final response = await http.get(Uri.parse(_jsonUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Album.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load albums from GitHub');
    }
  }

  /// 🔹 Group songs by theme
  Future<Map<String, List<Song>>> fetchSongsGroupedByTheme() async {
    final allSongs = await fetchSongsFromGitHub();
    final Map<String, List<Song>> categorized = {};

    for (var song in allSongs) {
      final theme = song.theme?.trim().toLowerCase() ?? '';
      if (theme.isEmpty) continue;
      categorized.putIfAbsent(theme, () => []).add(song);
    }

    return categorized;
  }

  /// 🔹 Group songs by artist
  Future<Map<String, List<Song>>> fetchSongsGroupedByArtist() async {
    final allSongs = await fetchSongsFromGitHub();
    final Map<String, List<Song>> artistMap = {};

    for (var song in allSongs) {
      final artist = song.artist.trim();
      if (artist.isEmpty) continue;
      artistMap.putIfAbsent(artist, () => []).add(song);
    }

    return artistMap;
  }

  /// ✅ FIXED: Fetch theme image map from GitHub (corrected from List to Map)
  Future<Map<String, String>> fetchThemeImageMap() async {
    final response = await http.get(Uri.parse(_themeDataUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map(
        (key, value) => MapEntry(key.toLowerCase(), value.toString()),
      );
    } else {
      throw Exception('Failed to load theme image data');
    }
  }

  /// ✅ Fetch artist images map from GitHub (already correct)
  Future<Map<String, String>> fetchArtistImageMap() async {
    final response = await http.get(Uri.parse(_artistDataUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map(
        (key, value) => MapEntry(key.trim(), value.toString()),
      );
    } else {
      throw Exception('Failed to load artist image data');
    }
  }

  /// ✅ Fetch language color map from GitHub
  Future<Map<String, String>> fetchLanguageColorMap() async {
    final url = _languageDataUrl;
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return jsonData.map((key, value) => MapEntry(key, value.toString()));
    } else {
      throw Exception('Failed to load language color map');
    }
  }
}
