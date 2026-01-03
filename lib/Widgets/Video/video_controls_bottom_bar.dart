import 'package:flutter/material.dart';

class VideoControlsBottomBar extends StatelessWidget {
  final String position;
  final String duration;
  final double playbackSpeed;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onPlaybackSpeedTap;

  const VideoControlsBottomBar({
    super.key,
    required this.position,
    required this.duration,
    required this.playbackSpeed,
    required this.isFullscreen,
    required this.onToggleFullscreen,
    required this.onPlaybackSpeedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Text(
              "$position / $duration",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const Spacer(),
            TextButton(
              onPressed: onPlaybackSpeedTap,
              child: Text(
                "${playbackSpeed}x",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                isFullscreen
                    ? Icons.fullscreen_exit_rounded
                    : Icons.fullscreen_rounded,
                color: Colors.white,
              ),
              onPressed: onToggleFullscreen,
            ),
          ],
        ),
      ),
    );
  }
}
