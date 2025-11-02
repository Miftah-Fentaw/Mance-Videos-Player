import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:mance/Screens/PlayerScreen.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  List<AssetEntity> _videos = [];
  bool _isGridView = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final PermissionState result =
          await PhotoManager.requestPermissionExtend();

      if (!result.isAuth) {
        _showPermissionDialog();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        onlyAll: true,
      ).timeout(const Duration(seconds: 10));

      if (albums.isNotEmpty) {
        List<AssetEntity> media = await albums[0]
            .getAssetListRange(start: 0, end: 10000)
            .timeout(const Duration(seconds: 10));
        setState(() {
          _videos = media;
          _isLoading = false;
        });
      } else {
        setState(() {
          _videos = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load videos: $e';
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "To access videos and audio, please allow media access in settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              PhotoManager.openSetting();
              Navigator.pop(context);
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Widget _videoTile(AssetEntity video) {
    return FutureBuilder<Uint8List?>(
      future: video.thumbnailDataWithSize(
        const ThumbnailSize(200, 120),
      ),
      builder: (context, snapshot) {
        final thumbnail = snapshot.data;
        return InkWell(
          onTap: () async {
            final file = await video.file;
            if (file != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayerScreen(videoFile: file),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(
                  width: 120,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    image: thumbnail != null
                        ? DecorationImage(
                            image: MemoryImage(thumbnail),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: thumbnail == null
                      ? const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 30,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: FutureBuilder<File?>(
                    future: video.file,
                    builder: (context, fileSnapshot) {
                      final fileName =
                          fileSnapshot.data?.path.split('/').last ?? '';
                      return Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
                const Icon(Icons.more_vert, color: Colors.black45),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:  [
                  Text(
                    'Mance Player',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Tap a video to play it. Use the toggle to switch between grid/list view.',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: Icon(Icons.help_outline, color: Colors.black, size: 28),
                ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Videos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isGridView
                          ? Icons.filter_list_outlined
                          : Icons.grid_view_outlined,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: LoadingAnimationWidget.inkDrop(
                          color: Colors.black,
                          size: 30,
                        ),
                      )
                    : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage!),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _loadVideos,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _videos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("No videos found."),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _loadVideos,
                              child: const Text('Refresh'),
                            ),
                          ],
                        ),
                      )
                    : _isGridView
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio:
                                  0.8,
                            ),
                        itemCount: _videos.length,
                        itemBuilder: (context, index) {
                          final video = _videos[index];
                          return FutureBuilder<Uint8List?>(
                            future: video.thumbnailDataWithSize(
                              const ThumbnailSize(200, 120),
                            ),
                            builder: (context, snapshot) {
                              final thumb = snapshot.data;
                              final fileName = video.title ?? 'Video';

                              return InkWell(
                                onTap: () async {
                                  final file = await video.file;
                                  if (file != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            PlayerScreen(videoFile: file),
                                      ),
                                    );
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 120,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                        image: thumb != null
                                            ? DecorationImage(
                                                image: MemoryImage(thumb),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: thumb == null
                                          ? const Center(
                                              child: Icon(
                                                Icons.play_circle_fill,
                                                color: Colors.white,
                                                size: 40,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      fileName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: _videos.length,
                        itemBuilder: (context, index) {
                          return _videoTile(_videos[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
