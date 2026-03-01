import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/message.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import 'animated_actions.dart';

/// A single message bubble — styled differently for user vs. AI.
class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // Determine align and user status
    final isUser = message.isUser;

    if (isUser) {
      // ── User Message ────────────────────────────────
      return Padding(
        padding: const EdgeInsets.fromLTRB(64, 12, 16, 12),
        child: Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (message.imageUrl != null)
                _buildImageAttachment(message.imageUrl!),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppTheme.borderRadiusL),
                    topRight: const Radius.circular(AppTheme.borderRadiusS),
                    bottomLeft: const Radius.circular(AppTheme.borderRadiusL),
                    bottomRight: const Radius.circular(2),
                  ),
                ),
                child: Text(
                  message.text,
                  style: AppTheme.bodyLarge.copyWith(
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // ── AI Message ──────────────────────────────────
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 18,
                color: AppTheme.primaryBrand,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Model Name Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      message.modelName,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  // Text (Using Markdown for professional formatting)
                  MarkdownBody(
                    data: message.text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textPrimary.withOpacity(0.95),
                      ),
                      strong: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      listBullet: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.primaryBrand,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Actions
                  Row(
                    children: [
                      CopyButton(
                        text: message.text,
                        onCopy: (text) =>
                            context.read<ChatProvider>().copyMessage(text),
                      ),
                      const SizedBox(width: 16),
                      LikeButton(
                        isLiked: message.isLiked,
                        onTap: () =>
                            context.read<ChatProvider>().toggleLike(message.id),
                      ),
                      const SizedBox(width: 16),
                      DislikeButton(
                        isDisliked: message.isUnliked,
                        onTap: () => context.read<ChatProvider>().toggleUnlike(
                          message.id,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildImageAttachment(String path) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(path),
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (ctx, _, __) => Container(
            width: 200,
            height: 200,
            color: AppTheme.surfaceLight,
            child: const Icon(Icons.broken_image, color: Colors.white24),
          ),
        ),
      ),
    );
  }
}
