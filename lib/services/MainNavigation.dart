import 'dart:async';
import 'package:flutter/material.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/Screens/HomePage.dart';
import 'package:looli_app/Screens/SearchPage.dart';
import 'package:looli_app/Screens/LibraryPage.dart';
import 'package:looli_app/services/song_service.dart';
import 'package:looli_app/services/connectivity_service.dart';
import 'package:looli_app/widgets/Bottom_nav.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late Future<List<Song>> _songsFuture;
  late Future<Map<String, String>> _artistImagesFuture;

  late List<Song> allSongs;
  late Map<String, String> artistImageMap;

  late ConnectivityService _connectivityService;
  late StreamSubscription<bool> _connectivitySubscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    final songService = SongService();
    _songsFuture = songService.fetchSongsFromGitHub();
    _artistImagesFuture = songService.fetchArtistImageMap();

    // Initialize connectivity service
    _connectivityService = ConnectivityService();
    _connectivitySubscription = _connectivityService.connectivityStream.listen((connected) {
      if (!connected && _isConnected != false) {
        _showOfflineSnackbar();
      }
      setState(() {
        _isConnected = connected;
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _showOfflineSnackbar() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('You are offline. Some features may not work.'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Song>>(
      future: _songsFuture,
      builder: (context, songSnapshot) {
        if (songSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        } else if (songSnapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                "Error loading songs: ${songSnapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        allSongs = songSnapshot.data ?? [];

        return FutureBuilder<Map<String, String>>(
          future: _artistImagesFuture,
          builder: (context, artistSnapshot) {
            if (artistSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(child: CircularProgressIndicator(color: Colors.white)),
              );
            } else if (artistSnapshot.hasError) {
              return Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: Text(
                    "Error loading artist images: ${artistSnapshot.error}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }

            artistImageMap = artistSnapshot.data ?? {};

            return Scaffold(
              backgroundColor: looliThird,
              body: IndexedStack(
                index: _currentIndex,
                children: [
                  const Homepage(),
                  SearchPage(
                    allSongs: allSongs,
                    artistImageMap: artistImageMap,
                    onBackToHome: () {
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                  ),
                  const LibraryPage(),
                ],
              ),
              bottomNavigationBar: BottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}
