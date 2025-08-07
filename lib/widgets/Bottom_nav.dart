import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
Widget build(BuildContext context) {
  final List<IconData> icons = [
    Icons.home,
    Icons.search,
    Icons.library_music,
  ];

  return CurvedNavigationBar(
    index: currentIndex,
    onTap: onTap,
    backgroundColor: Colors.transparent,
    color: looliFifth,
    height: 60,
    animationDuration: const Duration(milliseconds: 300),
    animationCurve: Curves.easeInOut,
    buttonBackgroundColor: looliFirst,
    items: List.generate(icons.length, (index) {
      return Icon(
        icons[index],
        color: index == currentIndex ? Colors.black : looliFourth,
      );
    }),
  );
}
}