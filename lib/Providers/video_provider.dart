import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class VideoProvider extends ChangeNotifier {
  List<AssetEntity> _videos = [];
  List<AssetEntity> _filteredVideos = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = "";
  String _currentFilter = "All";

  List<AssetEntity> get videos => _videos;
  List<AssetEntity> get filteredVideos => _filteredVideos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;

  VideoProvider() {
    loadVideos();
  }

  Future<void> loadVideos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.hasAccess) {
        _isLoading = false;
        _errorMessage = "Permission denied to access videos.";
        notifyListeners();
        return;
      }

      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        onlyAll: true,
      );

      if (paths.isNotEmpty) {
        final List<AssetEntity> entities = await paths[0].getAssetListRange(
          start: 0,
          end: 1000,
        );
        _videos = entities;
        _applyFilter();
      } else {
        _videos = [];
        _filteredVideos = [];
      }
    } catch (e) {
      _errorMessage = "Error loading videos: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchVideos(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void filterVideos(String filter) {
    _currentFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    List<AssetEntity> source = _videos;

    // Apply category filter
    if (_currentFilter != "All") {
      source = source.where((video) {
        if (_currentFilter == "Recent") {
          final now = DateTime.now();
          return now.difference(video.createDateTime).inDays < 7;
        } else if (_currentFilter == "Large") {
          // Approximate large videos (> 10 minutes)
          return video.duration > 600;
        } else if (_currentFilter == "Short") {
          // Less than 1 minute
          return video.duration < 60;
        }
        return true;
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isEmpty) {
      _filteredVideos = source;
    } else {
      _filteredVideos = source.where((video) {
        final title = video.title?.toLowerCase() ?? '';
        return title.contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  Future<bool> deleteVideo(AssetEntity video) async {
    final result = await PhotoManager.editor.deleteWithIds([video.id]);
    if (result.isNotEmpty) {
      _videos.removeWhere((item) => item.id == video.id);
      _applyFilter();
      notifyListeners();
      return true;
    }
    return false;
  }
}
