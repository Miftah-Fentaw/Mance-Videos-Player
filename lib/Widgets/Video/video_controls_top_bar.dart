import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class VideoControlsTopBar extends StatelessWidget {
  final String title;
  final String videoPath;
  final VoidCallback onBack;

  const VideoControlsTopBar({
    super.key,
    required this.title,
    required this.videoPath,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: onBack,
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.share_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Share.shareXFiles([XFile(videoPath)]),
            ),
          ],
        ),
      ),
    );
  }
}
