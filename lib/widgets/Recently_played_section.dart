import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/Screens/AlbumSongsPage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecentlyPlayedSection extends StatelessWidget {
  final List<Album> allAlbums;
  final Song song;

  const RecentlyPlayedSection({
    super.key,
    required this.allAlbums,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('player_state').listenable(),
      builder: (context, Box box, _) {
        final dynamicList = box.get('last_playlist') ?? [];
        List<Song> recentSongs = List<Song>.from(dynamicList);

        final Map<String, Album> albumMap = {
          for (var album in allAlbums) album.title: album,
        };

        final List<Album> displayedAlbums = [];
        final Set<String> addedAlbumTitles = {};

        // Show recently played albums (most recent first)
        for (var song in recentSongs.reversed) {
          final album = albumMap[song.album];
          if (album != null && addedAlbumTitles.add(album.title)) {
            displayedAlbums.add(album);
            if (displayedAlbums.length == 4) break;
          }
        }

        // Fill up remaining with albums not already in the list
        // Fill up remaining with albums not already in the list
        if (displayedAlbums.length < 4) {
          for (int i = 1; i < allAlbums.length; i++) {
            final album = allAlbums[i];
            if (addedAlbumTitles.add(album.title)) {
              displayedAlbums.add(album);
              if (displayedAlbums.length == 4) break;
            }
          }
        }

        if (displayedAlbums.isEmpty) return const SizedBox();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Loop your Grooves',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 12.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedAlbums.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                ),
                itemBuilder: (context, index) {
                  final album = displayedAlbums[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => AlbumSongsPage(
                                albumTitle: album.title,
                                songs: album.songs,
                                allSongs:
                                    allAlbums.expand((a) => a.songs).toList(),
                              ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(16.r),
                            ),
                            child: Image.network(
                              album.image,
                              width: 60.w,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    width: 60.w,
                                    height: double.infinity,
                                    color: Colors.black26,
                                    child: Icon(
                                      Icons.music_note,
                                      color: Colors.white70,
                                      size: 28,
                                    ),
                                  ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    album.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    album.songs.first.artist,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
