import 'package:flutter/material.dart';

class VideoControlsCenter extends StatelessWidget {
  final bool isPlaying;
  final bool isFinished;
  final VoidCallback onPlayPause;
  final VoidCallback onReplay;
  final VoidCallback onSeekForward;
  final VoidCallback onSeekBackward;

  const VideoControlsCenter({
    super.key,
    required this.isPlaying,
    required this.isFinished,
    required this.onPlayPause,
    required this.onReplay,
    required this.onSeekForward,
    required this.onSeekBackward,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.replay_10_rounded,
            color: Colors.white,
            size: 40,
          ),
          onPressed: onSeekBackward,
        ),
        const SizedBox(width: 40),
        GestureDetector(
          onTap: isFinished ? onReplay : onPlayPause,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFinished
                  ? Icons.replay_rounded
                  : (isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded),
              color: Colors.white,
              size: 45,
            ),
          ),
        ),
        const SizedBox(width: 40),
        IconButton(
          icon: const Icon(
            Icons.forward_10_rounded,
            color: Colors.white,
            size: 40,
          ),
          onPressed: onSeekForward,
        ),
      ],
    );
  }
}
