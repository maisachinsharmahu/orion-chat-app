import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.black,
        leading: const BackButton(color: Colors.white),
      ),
      backgroundColor: AppTheme.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.surfaceLight,
              child: Icon(Icons.person, size: 50, color: AppTheme.accentDim),
            ),
            const SizedBox(height: 16),
            Text('User Profile', style: AppTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'user@example.com',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
