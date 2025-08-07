import 'package:flutter/material.dart';

Future<void> showAnimatedConfirmDialog({
  required BuildContext context,
  String title = "Confirm",
  required String message,
  required VoidCallback onConfirmed,
}) async {
  Color startColor = const Color(0xff750E6B); // looliFirst
  Color endColor = const Color(0xffF65407);  // looliSecond

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return _AnimatedConfirmDialog(
            title: title,
            message: message,
            startColor: startColor,
            endColor: startColor,
            onConfirmed: onConfirmed,
          );
        },
      );
    },
  );
}

class _AnimatedConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final Color startColor;
  final Color endColor;
  final VoidCallback onConfirmed;

  const _AnimatedConfirmDialog({
    required this.title,
    required this.message,
    required this.startColor,
    required this.endColor,
    required this.onConfirmed,
  });

  @override
  State<_AnimatedConfirmDialog> createState() => _AnimatedConfirmDialogState();
}

class _AnimatedConfirmDialogState extends State<_AnimatedConfirmDialog> {
  late Color _backgroundColor;

  @override
  void initState() {
    super.initState();
    _backgroundColor = widget.startColor;

    Future.delayed(Duration.zero, () {
      setState(() {
        _backgroundColor = widget.endColor;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      content: AnimatedContainer(
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              widget.message,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onConfirmed();
                  },
                  child: const Text("Yes", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
