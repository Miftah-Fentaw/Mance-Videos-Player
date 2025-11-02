import 'package:flutter/material.dart';
import 'package:mance/Screens/AudiosPage.dart';
import 'package:mance/Screens/BrowsePage.dart';
import 'package:mance/Screens/SettingsPage.dart';
import 'package:mance/Screens/VideosPage.dart';
import 'package:permission_handler/permission_handler.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Mance Player'),
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
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    var videoStatus = await Permission.videos.status;
    if (!videoStatus.isGranted) {
      await Permission.videos.request();
    }
    var audioStatus = await Permission.audio.status;
    if (!audioStatus.isGranted) {
      await Permission.audio.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 25,
        fixedColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        currentIndex: index,
        onTap: (int tappedIndex) {
          setState(() {
            index = tappedIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.audiotrack),
            label: 'Audios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.browse_gallery_sharp),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: Center(child: pages[index]),
    );
  }
}
