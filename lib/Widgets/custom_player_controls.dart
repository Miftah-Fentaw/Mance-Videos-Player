import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:mance/Widgets/Video/video_controls_top_bar.dart';
import 'package:mance/Widgets/Video/video_controls_center.dart';
import 'package:mance/Widgets/Video/video_controls_bottom_bar.dart';
import 'dart:async';

class CustomVideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final String title;
  final String filePath;
  final VoidCallback onToggleFullScreen;

  const CustomVideoControls({
    super.key,
    required this.controller,
    required this.title,
    required this.filePath,
    required this.onToggleFullScreen,
  });

  @override
  State<CustomVideoControls> createState() => _CustomVideoControlsState();
}

class _CustomVideoControlsState extends State<CustomVideoControls> {
  bool _showControls = true;
  Timer? _hideTimer;
  double _playbackSpeed = 1.0;
  double _volume = 1.0;
  double _brightness = 1.0;
  String? _overlayText;
  IconData? _overlayIcon;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
    _volume = widget.controller.value.volume;
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) _startHideTimer();
    });
  }

  void _showOverlay(String text, IconData icon) {
    setState(() {
      _overlayText = text;
      _overlayIcon = icon;
    });
    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _overlayText = null);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _toggleControls,
      onVerticalDragUpdate: (details) {
        if (details.localPosition.dx < MediaQuery.of(context).size.width / 2) {
          _brightness = (_brightness - details.delta.dy / 200).clamp(0.0, 1.0);
          _showOverlay(
            "Brightness: ${(_brightness * 100).toInt()}%",
            Icons.brightness_6_rounded,
          );
        } else {
          _volume = (_volume - details.delta.dy / 200).clamp(0.0, 1.0);
          widget.controller.setVolume(_volume);
          _showOverlay(
            "Volume: ${(_volume * 100).toInt()}%",
            _volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          );
        }
      },
      onHorizontalDragUpdate: (details) {
        final position = widget.controller.value.position;
        final delta = details.delta.dx * 100;
        widget.controller.seekTo(
          position + Duration(milliseconds: delta.toInt()),
        );
        _showOverlay(
          delta > 0 ? "Forward" : "Rewind",
          delta > 0 ? Icons.fast_forward_rounded : Icons.fast_rewind_rounded,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              color: Colors.black26,
              child: Column(
                children: [
                  VideoControlsTopBar(
                    title: widget.title,
                    videoPath: widget.filePath,
                    onBack: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  VideoControlsCenter(
                    isPlaying: widget.controller.value.isPlaying,
                    isFinished:
                        widget.controller.value.position >=
                        widget.controller.value.duration,
                    onPlayPause: () {
                      setState(() {
                        widget.controller.value.isPlaying
                            ? widget.controller.pause()
                            : widget.controller.play();
                      });
                      _startHideTimer();
                    },
                    onReplay: () {
                      widget.controller.seekTo(Duration.zero);
                      widget.controller.play();
                      _startHideTimer();
                    },
                    onSeekBackward: () {
                      final position = widget.controller.value.position;
                      widget.controller.seekTo(
                        position - const Duration(seconds: 10),
                      );
                      _startHideTimer();
                    },
                    onSeekForward: () {
                      final position = widget.controller.value.position;
                      widget.controller.seekTo(
                        position + const Duration(seconds: 10),
                      );
                      _startHideTimer();
                    },
                  ),
                  const Spacer(),
                  ValueListenableBuilder(
                    valueListenable: widget.controller,
                    builder: (context, VideoPlayerValue value, child) {
                      return VideoControlsBottomBar(
                        position: _formatDuration(value.position),
                        duration: _formatDuration(value.duration),
                        playbackSpeed: _playbackSpeed,
                        isFullscreen: false, // This state is managed externally
                        onToggleFullscreen: widget.onToggleFullScreen,
                        onPlaybackSpeedTap: _showPlaybackSpeedDialog,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_overlayText != null)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_overlayIcon, color: Colors.white, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      _overlayText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showPlaybackSpeedDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Playback Speed",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...[0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map(
              (speed) => ListTile(
                title: Text("${speed}x", textAlign: TextAlign.center),
                onTap: () {
                  widget.controller.setPlaybackSpeed(speed);
                  setState(() => _playbackSpeed = speed);
                  Navigator.pop(context);
                },
                selected: _playbackSpeed == speed,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
