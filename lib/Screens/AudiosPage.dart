import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';

class AudiosPage extends StatefulWidget {
  const AudiosPage({super.key});

  @override
  State<AudiosPage> createState() => _AudiosPageState();
}

class _AudiosPageState extends State<AudiosPage> {
  late Future<List<File>> _audioFilesFuture;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;

  @override
  void initState() {
    super.initState();
    _audioFilesFuture = _loadAudioFiles();
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
      backgroundColor: Colors.white,
      bottomSheet: _currentlyPlaying != null ? _buildMiniPlayer() : null,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, _currentlyPlaying != null ? 70 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Music',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: FutureBuilder<List<File>>(
                  future: _audioFilesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.black));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No audio files selected or found.'));
                    }

                    final audioFiles = snapshot.data!;

                    return ListView.builder(
                      itemCount: audioFiles.length,
                      itemBuilder: (context, index) {
                        final file = audioFiles[index];
                        final fileName = file.path.split('/').last;

                        return InkWell(
                          onTap: () => _playAudio(file),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.music_note, color: Colors.black54, size: 28),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    fileName,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.more_vert, color: Colors.black45),
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

  Widget _buildMiniPlayer() {
    return Container(
      height: 60,
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            const Icon(Icons.music_note, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _currentlyPlaying!,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            StreamBuilder<PlayerState>(
              stream: _audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final playing = playerState?.playing;
                if (playing != true) {
                  return IconButton(icon: const Icon(Icons.play_arrow, color: Colors.white), onPressed: _audioPlayer.play);
                } else {
                  return IconButton(icon: const Icon(Icons.pause, color: Colors.white), onPressed: _audioPlayer.pause);
                }
              },
            ),
            IconButton(icon: const Icon(Icons.stop, color: Colors.white), onPressed: () {
              _audioPlayer.stop();
              setState(() { _currentlyPlaying = null; });
            }),
          ],
        ),
      ),
    );
  }
}
