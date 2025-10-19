import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                'Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),

            _buildSettingsTile(
              icon: Icons.color_lens_outlined,
              title: 'Appearance',
              subtitle: 'Theme, colors, and style',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.music_note_outlined,
              title: 'Audio',
              subtitle: 'Equalizer, crossfade, playback quality',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.videocam_outlined,
              title: 'Video',
              subtitle: 'Subtitles, playback speed, gestures',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.folder_open_outlined,
              title: 'Library',
              subtitle: 'Manage media folders and scans',
              onTap: () {},
            ),
            _buildSettingsDivider(),
            _buildSettingsTile(
              icon: Icons.notifications_none_outlined,
              title: 'Notifications',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.lock_outline,
              title: 'Privacy & Security',
              onTap: () {},
            ),
             _buildSettingsDivider(),
             _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'About Mance Player',
              subtitle: 'Version 1.0.0',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey)) : null,
      onTap: onTap,
    );
  }

  Widget _buildSettingsDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Divider(color: Colors.black12, height: 1),
    );
  }
}
