import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mance/Screens/PlayerScreen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  late Future<List<File>>? _videoFilesFuture;

  void _pickVideos() {
    setState(() {
      _videoFilesFuture = _loadVideoFiles();
    });
  }

  Future<List<File>> _loadVideoFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );

    if (result != null) {
      return result.paths.map((path) => File(path!)).toList();
    } else {
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _videoFilesFuture = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mance Player',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Align(
                    alignment: AlignmentGeometry.topRight,
                    child: Icon(
                      Icons.help_outline,
                      color: Colors.black,
                      size: 28,
                    ),
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
                  Row(
                    children: const [
                      Icon(Icons.sort, color: Colors.black54),
                      SizedBox(width: 15),
                      Icon(Icons.grid_view_outlined, color: Colors.black54),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Expanded(
                child: _videoFilesFuture == null
                    ? Center(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              Colors.black45,
                            ),
                            foregroundColor: WidgetStatePropertyAll(
                              Colors.white,
                            ),
                          ),
                          onPressed: _pickVideos,
                          child: const Text("Import Videos"),
                        ),
                      )
                    : FutureBuilder<List<File>>(
                        future: _videoFilesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return  Center(
                              child: LoadingAnimationWidget.inkDrop(
                            color: Colors.black,
                            size: 30
                          )
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('No videos selected or found.'),
                            );
                          }

                          final videoFiles = snapshot.data!;

                          return ListView.builder(
                            itemCount: videoFiles.length,
                            itemBuilder: (context, index) {
                              final file = videoFiles[index];
                              final fileName = file.path.split('/').last;

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PlayerScreen(videoFile: file),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.play_circle_fill,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Text(
                                          fileName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.more_vert,
                                        color: Colors.black45,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
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
