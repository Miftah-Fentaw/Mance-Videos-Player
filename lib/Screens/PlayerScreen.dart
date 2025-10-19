import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayerScreen extends StatefulWidget {
  final File videoFile;

  const PlayerScreen({super.key, required this.videoFile});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  @override
  Widget build(BuildContext context) {
    final videoTitle = widget.videoFile.path.split('/').last;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          videoTitle,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                );
              } else {
                return Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * (9 / 16),
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 10),

          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, VideoPlayerValue value, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2.0,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 15.0),
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.grey[700],
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: value.position.inSeconds.toDouble(),
                        min: 0.0,
                        max: value.duration.inSeconds.toDouble(),
                        onChanged: (newValue) {
                          _controller.seekTo(Duration(seconds: newValue.toInt()));
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(value.position), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(_formatDuration(value.duration), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.shuffle, color: Colors.white70, size: 28),
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
                  onPressed: () async {
                    final position = await _controller.position;
                    if (position != null) {
                        _controller.seekTo(position - const Duration(seconds: 10));
                    }
                  },
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.value.isPlaying ? _controller.pause() : _controller.play();
                    });
                  },
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(
                      _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: 45,
                    ),
                  ),
                ),
                 IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
                  onPressed: () async {
                    final position = await _controller.position;
                     if (position != null) {
                        _controller.seekTo(position + const Duration(seconds: 10));
                    }
                  },
                ),
                const Icon(Icons.repeat, color: Colors.white70, size: 28),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
