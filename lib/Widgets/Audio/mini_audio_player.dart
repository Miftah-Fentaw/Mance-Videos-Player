import 'package:flutter/material.dart';
import 'package:mance/Providers/audio_provider.dart';

class MiniAudioPlayer extends StatelessWidget {
  final ThemeData theme;
  final AudioProvider provider;

  const MiniAudioPlayer({
    super.key,
    required this.theme,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 48,
              height: 48,
              color: theme.primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.music_note_rounded,
                color: theme.primaryColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.currentAudioEntity?.title ?? "Unknown",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "NOW PLAYING",
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    letterSpacing: 1,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder<bool>(
            stream: provider.audioPlayer.playingStream,
            builder: (context, snapshot) {
              final playing = snapshot.data ?? false;
              return IconButton(
                icon: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 28,
                ),
                onPressed: playing
                    ? provider.audioPlayer.pause
                    : provider.audioPlayer.play,
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
