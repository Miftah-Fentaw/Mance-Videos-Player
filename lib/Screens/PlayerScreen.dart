import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PlayerScreen extends StatefulWidget {
  final File videoFile;

  const PlayerScreen({Key? key, required this.videoFile}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile);

    _controller.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _controller,
        autoPlay: true,
        looping: false,
        showControls: true,
        allowFullScreen: true,
        allowMuting: true,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: Text(widget.videoFile.path.split('/').last,style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () async {
              final position = await _controller.position;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenPlayer(
                    videoFile: widget.videoFile,
                    startPosition: position,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
          ? Chewie(controller: _chewieController!)
          : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }
}







class FullScreenPlayer extends StatefulWidget {
  final File videoFile;
  final Duration? startPosition;

  const FullScreenPlayer({Key? key, required this.videoFile, this.startPosition}) : super(key: key);

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile);

    _controller.initialize().then((_) {
      if (widget.startPosition != null) {
        _controller.seekTo(widget.startPosition!);
      }
      _chewieController = ChewieController(
        videoPlayerController: _controller,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: Text(widget.videoFile.path.split('/').last,style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: const Icon(Icons.minimize),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
          ? Chewie(controller: _chewieController!)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
