import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isNotificationEnabled = false;

  @override
  Widget build(BuildContext context) {
    void showPrivacyDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              height: 300,
              child: SingleChildScrollView(
                child: const Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                  "Ut faucibus felis a arcu facilisis, in tincidunt metus bibendum. "
                  "Donec non lorem id urna interdum congue. Sed gravida, ipsum a luctus feugiat, "
                  "elit elit semper est, eget laoreet odio augue id ipsum. Vivamus volutpat, "
                  "nibh at hendrerit commodo, nisl nisi tincidunt mi, vitae auctor dolor lorem nec ex. "
                  "Phasellus consequat justo non nisl eleifend, non aliquet elit tincidunt. "
                  "In nec cursus sapien. Integer ultricies purus non eros euismod, ut cursus "
                  "erat hendrerit. Aenean luctus diam sed sapien mattis aliquet.",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    }

    void _showAboutDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "About This App",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Mance Player v1.0.0",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Developed by Miftah\n@Miftah_Fentaw",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.black54),
              title: const Text(
                'Enable Notifications',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              subtitle: const Text(
                'Turn on to receive updates',
                style: TextStyle(color: Colors.grey),
              ),
              trailing: Switch(
                value:
                    _isNotificationEnabled, // or your variable if you’re managing state
                onChanged: (value) {
                  setState(() {
                    _isNotificationEnabled = value;
                  });
                },
                activeColor: Colors.green,
                inactiveThumbColor: Colors.grey,
              ),
            ),

            _buildSettingsTile(
              icon: Icons.lock_outline,
              title: 'Privacy & Security',
              onTap: () => showPrivacyDialog(context),
            ),
            _buildSettingsDivider(),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'About Mance Player',
              subtitle: 'Version 1.0.0',
              onTap: () => _showAboutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Colors.grey))
          : null,
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
