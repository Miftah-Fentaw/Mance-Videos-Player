import 'package:flutter/material.dart';
import 'package:mance/Providers/audio_provider.dart';
import 'package:mance/Widgets/Audio/audio_list.dart';
import 'package:mance/Widgets/Audio/mini_audio_player.dart';
import 'package:mance/Widgets/Audio/full_audio_player.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AudiosPage extends StatefulWidget {
  const AudiosPage({super.key});

  @override
  State<AudiosPage> createState() => _AudiosPageState();
}

class _AudiosPageState extends State<AudiosPage> {
  final PanelController _panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final audioProvider = context.watch<AudioProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AUDIOS'),
        actions: [
          IconButton(
            onPressed: audioProvider.loadAudios,
            icon: const Icon(Icons.refresh_rounded, size: 20),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: audioProvider.currentAudioEntity != null ? 72 : 0,
        maxHeight: size.height,
        panel: FullAudioPlayer(theme: theme, provider: audioProvider),
        collapsed: audioProvider.currentAudioEntity != null
            ? MiniAudioPlayer(theme: theme, provider: audioProvider)
            : const SizedBox.shrink(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black38)],
        color: Colors.transparent,
        body: AudioList(theme: theme, provider: audioProvider, isTablet: isTablet),
      ),
    );
  }
}
