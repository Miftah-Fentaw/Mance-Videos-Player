import 'package:flutter/material.dart';
import 'package:mance/Providers/audio_provider.dart';

class GlobalMiniPlayer extends StatelessWidget {
  final ThemeData theme;
  final AudioProvider provider;
  final VoidCallback onTap;

  const GlobalMiniPlayer({
    super.key,
    required this.theme,
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 0.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 44,
                height: 44,
                color: theme.primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.music_note_rounded,
                  color: theme.primaryColor,
                  size: 20,
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
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "TAP TO OPEN PLAYER",
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 9,
                      letterSpacing: 1,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
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
                    size: 24,
                  ),
                  onPressed: playing
                      ? provider.audioPlayer.pause
                      : provider.audioPlayer.play,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
