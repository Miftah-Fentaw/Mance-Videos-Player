import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_manager/photo_manager.dart';

class AudiosPage extends StatefulWidget {
  const AudiosPage({super.key});

  @override
  State<AudiosPage> createState() => _AudiosPageState();
}

class _AudiosPageState extends State<AudiosPage> {
  bool _isGridView = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;
  List<AssetEntity> _audioAssets = [];
  final PanelController _panelController = PanelController();
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadAudios();
  }

  Future<void> _requestPermissionAndLoadAudios() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        setState(() => _loading = false);
        return;
      }

      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.audio,
        onlyAll: true,
      ).timeout(const Duration(seconds: 10));

      if (albums.isNotEmpty) {
        List<AssetEntity> audios = await albums[0]
            .getAssetListRange(start: 0, end: 10000)
            .timeout(const Duration(seconds: 10));
        setState(() {
          _audioAssets = audios;
          _loading = false;
        });
      } else {
        setState(() {
          _audioAssets = [];
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Failed to load audios: $e';
      });
    }
  }

  Future<void> _playAudio(AssetEntity audio) async {
    try {
      File? file = await audio.file;
      if (file != null) {
        await _audioPlayer.setAudioSource(AudioSource.uri(file.uri));
        _audioPlayer.play();
        setState(() {
          _currentlyPlaying = file.path.split('/').last;
        });
      }
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  Future<bool> checkAudioPermission() async {
    final perm = await PhotoManager.requestPermissionExtend();
    if (!perm.isAuth) {
      PhotoManager.openSetting();
      return false;
    }
    return true;
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
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
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
            IconButton(
              icon: const Icon(
                Icons.skip_previous,
                color: Colors.black,
                size: 36,
              ),
              onPressed: () {},
            ),
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
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.black, size: 36),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAudioList() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          _currentlyPlaying != null ? 70 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                  'All Audios',
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
            const SizedBox(height: 25),
            _loading
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
                          onPressed: _requestPermissionAndLoadAudios,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: _audioAssets.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("No audio files found."),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: _requestPermissionAndLoadAudios,
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
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 3,
                                ),
                            itemCount: _audioAssets.length,
                            itemBuilder: (context, index) {
                              final audio = _audioAssets[index];
                              return FutureBuilder<File?>(
                                future: audio.file,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return Container();
                                  final fileName = snapshot.data!.path
                                      .split('/')
                                      .last;
                                  return InkWell(
                                    onTap: () => _playAudio(audio),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.music_note,
                                            color: Colors.black54,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              fileName,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        : ListView.builder(
                            itemCount: _audioAssets.length,
                            itemBuilder: (context, index) {
                              final audio = _audioAssets[index];
                              return FutureBuilder<File?>(
                                future: audio.file,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return Container();
                                  final fileName = snapshot.data!.path
                                      .split('/')
                                      .last;
                                  return ListTile(
                                    leading: const Icon(
                                      Icons.music_note,
                                      color: Colors.black54,
                                    ),
                                    title: Text(fileName),
                                    onTap: () => _playAudio(audio),
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
                icon: Icon(
                  playing ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
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
              setState(() => _currentlyPlaying = null);
            },
          ),
        ],
      ),
    );
  }
}
