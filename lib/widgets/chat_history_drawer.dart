import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_session.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../screens/settings_screen.dart';
import '../screens/profile_screen.dart';

/// A sidebar drawer to switch between chat sessions.
class ChatHistoryDrawer extends StatelessWidget {
  const ChatHistoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surfaceDark,
      surfaceTintColor: Colors.transparent,
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.of(context).padding.top + 32,
              24,
              24,
            ),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppTheme.primaryBrand, AppTheme.luxeGold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Orion Chat',
                  style: AppTheme.titleMedium.copyWith(
                    color: Colors.white,
                    letterSpacing: 0, // Resetting spacing to match context
                  ),
                ),
              ],
            ),
          ),

          // ── New Chat Button ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBrand.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<ChatProvider>().startNewChat();
                  Navigator.pop(context); // Close drawer
                },
                icon: const Icon(Icons.add_rounded, size: 22),
                label: const Text('New Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrand,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 52),
                  alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  textStyle: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'RECENT',
                  style: AppTheme.bodyMedium.copyWith(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.history_rounded,
                  size: 14,
                  color: AppTheme.textSecondary.withOpacity(0.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── History List ───────────────────────────────
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chat, _) {
                if (chat.sessions.isEmpty) {
                  return const Center(child: Text(""));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: chat.sessions.length,
                  itemBuilder: (context, index) {
                    final session = chat.sessions[index];
                    final isActive = session.id == chat.currentSessionId;

                    return _HistoryItem(
                      session: session,
                      isActive: isActive,
                      onTap: () {
                        chat.loadSession(session.id);
                        Navigator.pop(context);
                      },
                      onRename: (newTitle) {
                        chat.renameSession(session.id, newTitle);
                      },
                      onDelete: () {
                        chat.deleteSession(session.id);
                      },
                    );
                  },
                );
              },
            ),
          ),

          // ── Footer ─────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Column(
              children: [
                Divider(color: AppTheme.dividerColor.withOpacity(0.5)),
                ListTile(
                  leading: const Icon(
                    Icons.settings_outlined,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                  title: Text('Settings', style: AppTheme.bodyMedium),
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.person_outline,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                  title: Text('Profile', style: AppTheme.bodyMedium),
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final ChatSession session;
  final bool isActive;
  final VoidCallback onTap;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;

  const _HistoryItem({
    required this.session,
    required this.isActive,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: session.title);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Rename',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rename Chat', style: AppTheme.titleMedium),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  style: AppTheme.bodyLarge,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'New title...',
                    hintStyle: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    filled: true,
                    fillColor: AppTheme.black.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryBrand,
                        width: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final newTitle = controller.text.trim();
                        if (newTitle.isNotEmpty) {
                          onRename(newTitle);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrand,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Rename'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Delete',
      barrierColor: Colors.black.withOpacity(0.8), // Cinematic dark overlay
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.black, // Solid Pitch Black like home
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.redAccent.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.1),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 30,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Danger Icon Removed (per request) ───────
                const SizedBox(height: 12),

                // ── Text Content ────────────────────────────
                Text(
                  'Delete Chat?',
                  style: AppTheme.titleMedium.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This will permanently erase all messages. You cannot undo this action.',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),

                // ── Buttons ─────────────────────────────────
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          onDelete();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Delete Permanently',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.surfaceLight : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        title: Text(
          session.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.bodyMedium.copyWith(
            color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
        trailing: isActive
            ? PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_horiz,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                color: AppTheme.surfaceDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: AppTheme.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Rename',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteDialog(context);
                  } else if (value == 'rename') {
                    _showRenameDialog(context);
                  }
                },
              )
            : null,
      ),
    );
  }
}
