import 'package:flutter/material.dart';
import 'package:mance/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isNotificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader(theme, 'Appearance'),
          _buildSettingsTile(
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            title: 'Dark Mode',
            trailing: Switch(
              value: isDark,
              activeColor: theme.primaryColor,
              onChanged: (value) {
                themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
              },
            ),
            onTap: () {},
          ),
          const Divider(indent: 52),
          _buildSectionHeader(theme, 'General'),
          _buildSettingsTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'New media alerts',
            trailing: Switch(
              value: _isNotificationEnabled,
              activeColor: theme.primaryColor,
              onChanged: (value) =>
                  setState(() => _isNotificationEnabled = value),
            ),
            onTap: () {},
          ),
          const Divider(indent: 52),
          _buildSettingsTile(
            icon: Icons.language_rounded,
            title: 'Language',
            trailing: Text(
              'English',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            onTap: () {},
          ),
          const Divider(indent: 52),
          _buildSectionHeader(theme, 'Information'),
          _buildSettingsTile(
            icon: Icons.security_rounded,
            title: 'Privacy Policy',
            onTap: () => _showPrivacyDialog(context),
          ),
          const Divider(indent: 52),
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'About Mance Player',
            onTap: () => _showAboutDialog(context),
          ),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                const Text(
                  'MANCE PLAYER',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.bodySmall?.copyWith(
          letterSpacing: 2,
          fontWeight: FontWeight.w900,
          color: theme.primaryColor.withOpacity(0.7),
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.grey[600]),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            )
          : null,
      trailing:
          trailing ??
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Privacy Policy"),
        content: const SingleChildScrollView(
          child: Text(
            "Your privacy is important to us. This app only accesses local media files to play them. No data is collected or shared.",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Mance Player',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.play_circle_fill,
        size: 50,
        color: Colors.indigo,
      ),
      children: [
        const Text(
          "A modern, sleek video and audio player built with Flutter.",
        ),
      ],
    );
  }
}
