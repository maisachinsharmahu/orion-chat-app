import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.black,
        leading: const BackButton(color: Colors.white),
      ),
      backgroundColor: AppTheme.black,
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette, color: Colors.white),
            title: Text('Theme', style: AppTheme.bodyLarge),
            subtitle: Text(
              'Dark Mode',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            trailing: Switch(
              value: true,
              onChanged: (v) {},
              activeThumbColor: AppTheme.primaryBrand,
            ),
          ),
          const Divider(color: AppTheme.dividerColor),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.white),
            title: Text('Notifications', style: AppTheme.bodyLarge),
            trailing: Switch(
              value: false,
              onChanged: (v) {},
              activeThumbColor: AppTheme.primaryBrand,
            ),
          ),
          const Divider(color: AppTheme.dividerColor),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: Text('About', style: AppTheme.bodyLarge),
            subtitle: Text(
              'Version 1.0.0',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
