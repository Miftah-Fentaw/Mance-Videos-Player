import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:photo_manager/photo_manager.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<AssetEntity> _audioAssets = [];
  AssetEntity? _currentAudioEntity;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isShuffle = false;
  LoopMode _loopMode = LoopMode.off;

  AudioPlayer get audioPlayer => _audioPlayer;
  List<AssetEntity> get audioAssets => _audioAssets;
  AssetEntity? get currentAudioEntity => _currentAudioEntity;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isShuffle => _isShuffle;
  LoopMode get loopMode => _loopMode;

  AudioProvider() {
    loadAudios();
  }

  Future<void> loadAudios() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.hasAccess) {
        _isLoading = false;
        _errorMessage = "Permission denied to access audios.";
        notifyListeners();
        return;
      }

      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.audio,
        onlyAll: true,
      );

      if (paths.isNotEmpty) {
        final List<AssetEntity> entities = await paths[0].getAssetListRange(
          start: 0,
          end: 1000,
        );
        _audioAssets = entities;
      } else {
        _audioAssets = [];
      }
    } catch (e) {
      _errorMessage = "Error loading audios: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> playAudio(AssetEntity asset) async {
    final file = await asset.file;
    if (file == null) return;

    try {
      // Create a playlist for skip next/previous functionality
      final List<AudioSource> sources = [];
      for (var a in _audioAssets) {
        final f = await a.file;
        if (f != null) {
          sources.add(
            AudioSource.uri(
              Uri.file(f.path),
              tag: MediaItem(
                id: a.id,
                title: a.title ?? "Unknown Audio",
                artist: "Mance Player",
              ),
            ),
          );
        }
      }

      final initialIndex = _audioAssets.indexOf(asset);
      final playlist = ConcatenatingAudioSource(children: sources);

      await _audioPlayer.setAudioSource(
        playlist,
        initialIndex: initialIndex >= 0 ? initialIndex : 0,
      );
      _audioPlayer.play();
      _currentAudioEntity = asset;
      notifyListeners();

      // Listen to sequence index changes to update _currentAudioEntity
      _audioPlayer.sequenceStateStream.listen((state) {
        if (state != null && state.currentIndex < _audioAssets.length) {
          _currentAudioEntity = _audioAssets[state.currentIndex];
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    _audioPlayer.setShuffleModeEnabled(_isShuffle);
    notifyListeners();
  }

  void cycleLoopMode() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.all;
    } else if (_loopMode == LoopMode.all) {
      _loopMode = LoopMode.one;
    } else {
      _loopMode = LoopMode.off;
    }
    _audioPlayer.setLoopMode(_loopMode);
    notifyListeners();
  }

  Future<bool> deleteAudio(AssetEntity audio) async {
    final result = await PhotoManager.editor.deleteWithIds([audio.id]);
    if (result.isNotEmpty) {
      if (_currentAudioEntity?.id == audio.id) {
        _audioPlayer.stop();
        _currentAudioEntity = null;
      }
      _audioAssets.removeWhere((item) => item.id == audio.id);
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
