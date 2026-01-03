import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class AudioCard extends StatelessWidget {
  final AssetEntity audio;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const AudioCard({
    super.key,
    required this.audio,
    required this.isPlaying,
    required this.onTap,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isPlaying
              ? theme.primaryColor.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPlaying
                ? theme.primaryColor.withOpacity(0.2)
                : isDark
                ? Colors.white10
                : Colors.black12,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isPlaying
                    ? theme.primaryColor
                    : isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  isPlaying
                      ? Icons.graphic_eq_rounded
                      : Icons.audiotrack_rounded,
                  color: isPlaying ? Colors.white : Colors.grey,
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
                    audio.title ?? 'Unknown Audio',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 15,
                      fontWeight: isPlaying ? FontWeight.bold : FontWeight.w600,
                      color: isPlaying ? theme.primaryColor : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDuration(audio.duration),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isPlaying)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.volume_up_rounded,
                  color: theme.primaryColor,
                  size: 18,
                ),
              )
            else
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: Colors.grey,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 4,
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                  if (value == 'share') onShare();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'share',
                    height: 40,
                    child: Row(
                      children: [
                        Icon(
                          Icons.share_rounded,
                          color: theme.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        const Text('Share', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    height: 40,
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Delete',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
