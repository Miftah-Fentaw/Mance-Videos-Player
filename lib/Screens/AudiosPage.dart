import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AudiosPage extends StatefulWidget {
  const AudiosPage({super.key});

  @override
  State<AudiosPage> createState() => _AudiosPageState();
}

class _AudiosPageState extends State<AudiosPage> {
   final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;
  late Future<List<File>>? _audioFilesFuture;
  final PanelController _panelController = PanelController();

  @override
  void initState() {
    super.initState();
    _audioFilesFuture = null;
  }

  void _pickAudios() {
    setState(() {
      _audioFilesFuture = _loadAudioFiles();
    });
  }

  Future<List<File>> _loadAudioFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null) {
      return result.paths.map((path) => File(path!)).toList();
    } else {
      return [];
    }
  }

  void _playAudio(File audioFile) {
    try {
      _audioPlayer.setAudioSource(AudioSource.uri(audioFile.uri));
      _audioPlayer.play();
      setState(() {
        _currentlyPlaying = audioFile.path.split('/').last;
      });
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }


@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: _currentlyPlaying != null ? 60 : 0,
        maxHeight: MediaQuery.of(context).size.height,
        panel: _buildFullPlayer(),
        collapsed: _currentlyPlaying != null ? _buildMiniPlayer() : Container(),
        body: _buildAudioList(),
      ),
    );
  }

  Widget _buildFullPlayer() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
          color: Colors.black87,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                onPressed: () => _panelController.close(),
              ),
              Expanded(
                child: Text(
                  _currentlyPlaying ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Icon(Icons.music_note, size: 120, color: Colors.black),
        StreamBuilder<Duration>(
          stream: _audioPlayer.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final total = _audioPlayer.duration ?? Duration.zero;
            return Slider(
              value: position.inSeconds.toDouble(),
              max: total.inSeconds.toDouble(),
              onChanged: (value) {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: const Icon(Icons.skip_previous, color: Colors.black, size: 36), onPressed: () {}),
            StreamBuilder<PlayerState>(
              stream: _audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;
                return IconButton(
                  icon: Icon(
                    playing ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.black,
                    size: 56,
                  ),
                  onPressed: () {
                    playing ? _audioPlayer.pause() : _audioPlayer.play();
                  },
                );
              },
            ),
            IconButton(icon: const Icon(Icons.skip_next, color: Colors.black, size: 36), onPressed: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildAudioList() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, _currentlyPlaying != null ? 70 : 20),
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
              child: _audioFilesFuture == null
                  ? Center(
                      child: ElevatedButton(
                        onPressed: _pickAudios,
                        child: const Text("Import Audios"),
                      ),
                    )
                  : FutureBuilder<List<File>>(
                      future: _audioFilesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return  Center(child: LoadingAnimationWidget.inkDrop(
                            color: Colors.black,
                            size: 30
                          ));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No audio files found.'));
                        }
                        final audioFiles = snapshot.data!;
                        return ListView.builder(
                          itemCount: audioFiles.length,
                          itemBuilder: (context, index) {
                            final file = audioFiles[index];
                            final name = file.path.split('/').last;
                            return ListTile(
                              leading: const Icon(Icons.music_note),
                              title: Text(name),
                              onTap: () => _playAudio(file),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return Container(
      height: 60,
      color: Colors.black,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentlyPlaying ?? '',
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          StreamBuilder<PlayerState>(
            stream: _audioPlayer.playerStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              return IconButton(
                icon: Icon(playing ? Icons.pause : Icons.play_arrow, color: Colors.white),
                onPressed: () {
                  playing ? _audioPlayer.pause() : _audioPlayer.play();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.stop, color: Colors.white),
            onPressed: () {
              _audioPlayer.stop();
              setState(() {
                _currentlyPlaying = null;
              });
            },
          ),
        ],
      ),
    );
  }
}