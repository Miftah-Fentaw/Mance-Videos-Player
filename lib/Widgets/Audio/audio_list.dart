import 'package:flutter/material.dart';
import 'package:mance/Providers/audio_provider.dart';
import 'package:mance/Widgets/audio_card.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';

class AudioList extends StatelessWidget {
  final ThemeData theme;
  final AudioProvider provider;
  final bool isTablet;

  const AudioList({
    super.key,
    required this.theme,
    required this.provider,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Expanded(
          child: provider.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.primaryColor,
                  ),
                )
              : provider.errorMessage != null
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
                        provider.errorMessage!,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: provider.loadAudios,
                        child: const Text('RETRY'),
                      ),
                    ],
                  ),
                )
              : provider.audioAssets.isEmpty
              ? const Center(child: Text('No audios found'))
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    provider.currentAudioEntity != null ? 100 : 20,
                  ),
                  itemCount: provider.audioAssets.length,
                  itemBuilder: (context, index) {
                    final audio = provider.audioAssets[index];
                    final isPlaying =
                        provider.currentAudioEntity?.id == audio.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AudioCard(
                        audio: audio,
                        isPlaying: isPlaying,
                        onTap: () => provider.playAudio(audio),
                        onDelete: () => _handleDelete(context, audio),
                        onShare: () async {
                          final file = await audio.file;
                          if (file != null)
                            Share.shareXFiles([XFile(file.path)]);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _handleDelete(BuildContext context, AssetEntity audio) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Audio?"),
        content: Text("Are you sure you want to delete '${audio.title}'?"),
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

    if (confirmed == true) {
      final success = await provider.deleteAudio(audio);
      if (success && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Audio deleted")));
      }
    }
  }
}
