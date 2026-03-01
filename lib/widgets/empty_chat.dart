import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shown when no messages exist yet.
class EmptyChat extends StatefulWidget {
  final ValueChanged<String>? onSuggestionClick;

  const EmptyChat({super.key, this.onSuggestionClick});

  @override
  State<EmptyChat> createState() => _EmptyChatState();
}

class _EmptyChatState extends State<EmptyChat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fadeAnimation = Tween<double>(
      begin: 0.5,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Animated Logo ──────────────────────────────
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Ring
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryBrand.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    // Middle Ring
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryBrand.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    // Core Glow
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryBrand.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBrand.withOpacity(0.4),
                            blurRadius: 40 * _scaleAnimation.value,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    // Icon
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // ── Welcome Text ───────────────────────────────
            Text(
              'How can I help you today?',
              textAlign: TextAlign.center,
              style: AppTheme.titleMedium,
            ),

            const SizedBox(height: 48),

            // ── Suggestions ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _SuggestionChip(
                    label: 'Creative writing',
                    icon: Icons.edit_note_rounded,
                    onTap: () => widget.onSuggestionClick?.call(
                      'Help me with creative writing...',
                    ),
                  ),
                  _SuggestionChip(
                    label: 'Plan a trip',
                    icon: Icons.flight_takeoff_rounded,
                    onTap: () =>
                        widget.onSuggestionClick?.call('Plan a trip to...'),
                  ),
                  _SuggestionChip(
                    label: 'Code helper',
                    icon: Icons.code_rounded,
                    onTap: () => widget.onSuggestionClick?.call(
                      'Can you check this code?',
                    ),
                  ),
                  _SuggestionChip(
                    label: 'Brainstorming',
                    icon: Icons.lightbulb_outline_rounded,
                    onTap: () => widget.onSuggestionClick?.call(
                      'Brainstorm ideas for...',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
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
