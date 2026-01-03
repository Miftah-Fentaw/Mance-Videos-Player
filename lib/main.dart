import 'package:flutter/material.dart';
import 'package:mance/Screens/AudiosPage.dart';
import 'package:mance/Screens/BrowsePage.dart';
import 'package:mance/Screens/SettingsPage.dart';
import 'package:mance/Screens/VideosPage.dart';
import 'package:mance/Theme/app_theme.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:mance/Providers/video_provider.dart';
import 'package:mance/Providers/audio_provider.dart';
import 'package:mance/Widgets/Audio/global_mini_player.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.miftah.mance.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    );
  } catch (e) {
    debugPrint("JustAudioBackground init error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mance Player',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const MyHomePage(title: 'Mance Player'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;
  final List<Widget> pages = [
    const VideosPage(),
    const AudiosPage(),
    const BrowsePage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final audioProvider = context.watch<AudioProvider>();

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: index, children: pages),
          if (audioProvider.currentAudioEntity != null && index != 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GlobalMiniPlayer(
                theme: theme,
                provider: audioProvider,
                onTap: () => setState(() => index = 1),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white10 : Colors.black12,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              currentIndex: index,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: theme.primaryColor,
              unselectedItemColor: Colors.grey,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              onTap: (int tappedIndex) {
                setState(() {
                  index = tappedIndex;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_library_rounded, size: 22),
                  activeIcon: Icon(Icons.video_library_rounded, size: 24),
                  label: 'VIDEOS',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.music_note_outlined, size: 22),
                  activeIcon: Icon(Icons.music_note, size: 24),
                  label: 'AUDIOS',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.language_outlined, size: 22),
                  activeIcon: Icon(Icons.language, size: 24),
                  label: 'BROWSE',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.tune_outlined, size: 22),
                  activeIcon: Icon(Icons.tune, size: 24),
                  label: 'SETTINGS',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
