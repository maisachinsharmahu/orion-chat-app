import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LikeButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onTap;

  const LikeButton({super.key, required this.isLiked, required this.onTap});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorAnimation = ColorTween(
      begin: AppTheme.textSecondary,
      end: AppTheme.primaryBrand,
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked != oldWidget.isLiked) {
      if (widget.isLiked) {
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(
              widget.isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
              color: widget.isLiked
                  ? AppTheme.primaryBrand
                  : AppTheme.dividerColor,
              size: 20,
            ),
          );
        },
      ),
    );
  }
}

class DislikeButton extends StatefulWidget {
  final bool isDisliked;
  final VoidCallback onTap;

  const DislikeButton({
    super.key,
    required this.isDisliked,
    required this.onTap,
  });

  @override
  State<DislikeButton> createState() => _DislikeButtonState();
}

class _DislikeButtonState extends State<DislikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));
  }

  @override
  void didUpdateWidget(DislikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDisliked != oldWidget.isDisliked) {
      if (widget.isDisliked) {
        _controller.forward(from: 0.0).then((_) => _controller.reverse());
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotateAnimation.value, // Slight shake
            child: Icon(
              widget.isDisliked
                  ? Icons.thumb_down_alt
                  : Icons.thumb_down_alt_outlined,
              color: widget.isDisliked
                  ? Colors.redAccent
                  : AppTheme.dividerColor,
              size: 20,
            ),
          );
        },
      ),
    );
  }
}

class CopyButton extends StatefulWidget {
  final String text;
  final Function(String) onCopy;

  const CopyButton({super.key, required this.text, required this.onCopy});

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _isCopied = false;

  void _handleTap() {
    widget.onCopy(widget.text);
    setState(() => _isCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: _isCopied
            ? const Icon(
                Icons.check_circle_outline,
                key: ValueKey('check'),
                color: Colors.green,
                size: 20,
              )
            : const Icon(
                Icons.copy_rounded,
                key: ValueKey('copy'),
                color: AppTheme.dividerColor,
                size: 20,
              ),
      ),
    );
  }
}
