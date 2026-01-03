import 'package:flutter/material.dart';
import 'package:mance/Providers/video_provider.dart';
import 'package:mance/Screens/PlayerScreen.dart';
import 'package:mance/Widgets/video_card.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:mance/Widgets/Video/video_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isDark = theme.brightness == Brightness.dark;
    final videoProvider = context.watch<VideoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MANCE PLAYER'),
        actions: [
          IconButton(
            onPressed: videoProvider.loadVideos,
            icon: const Icon(Icons.refresh_rounded, size: 20),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          VideoSearchBar(
            theme: theme,
            provider: videoProvider,
            isDark: isDark,
            isGridView: _isGridView,
            onToggleView: () => setState(() => _isGridView = !_isGridView),
          ),
          Expanded(
            child: videoProvider.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.primaryColor,
                    ),
                  )
                : videoProvider.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          videoProvider.errorMessage!,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: videoProvider.loadVideos,
                          child: const Text('RETRY'),
                        ),
                      ],
                    ),
                  )
                : videoProvider.filteredVideos.isEmpty
                ? const Center(child: Text('No videos found'))
                : RefreshIndicator(
                    onRefresh: videoProvider.loadVideos,
                    child: _isGridView
                        ? GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isTablet ? 3 : 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.85,
                                ),
                            itemCount: videoProvider.filteredVideos.length,
                            itemBuilder: (context, index) => VideoCard(
                              video: videoProvider.filteredVideos[index],
                              isGrid: true,
                              onTap: () => _openPlayer(
                                videoProvider.filteredVideos[index],
                              ),
                              onDelete: () => _deleteVideo(
                                context,
                                videoProvider.filteredVideos[index],
                              ),
                              onShare: () => _shareVideo(
                                videoProvider.filteredVideos[index],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: videoProvider.filteredVideos.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: VideoCard(
                                video: videoProvider.filteredVideos[index],
                                isGrid: false,
                                onTap: () => _openPlayer(
                                  videoProvider.filteredVideos[index],
                                ),
                                onDelete: () => _deleteVideo(
                                  context,
                                  videoProvider.filteredVideos[index],
                                ),
                                onShare: () => _shareVideo(
                                  videoProvider.filteredVideos[index],
                                ),
                              ),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  void _openPlayer(AssetEntity video) async {
    final file = await video.file;
    if (file != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlayerScreen(videoFile: file)),
      );
    }
  }

  void _shareVideo(AssetEntity video) async {
    final file = await video.file;
    if (file != null) {
      Share.shareXFiles([XFile(file.path)]);
    }
  }

  Future<void> _deleteVideo(BuildContext context, AssetEntity video) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Video?"),
        content: Text("Are you sure you want to delete '${video.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<VideoProvider>().deleteVideo(video);
      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Video deleted")));
      }
    }
  }
}
