import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Navigate to ChatScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const ChatScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ── Background Glow ─────────────────────────────
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryBrand.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.luxeGold.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main Content ────────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Premium Constellation Logo ────────────────
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBrand.withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Subtle rotating outer ring (implied by design)
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(seconds: 10),
                          builder: (context, value, child) {
                            return Transform.rotate(
                              angle: value * 2 * 3.14159,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.primaryBrand.withOpacity(
                                      0.15,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Three stars constellation
                        CustomPaint(
                          size: const Size(120, 120),
                          painter: ConstellationPainter(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── ORION Text (Syne Bold) ──────────────────
                  Text(
                    'ORION',
                    style: AppTheme.titleMedium.copyWith(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: AppTheme.primaryBrand.withOpacity(0.8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Tagline (Subtle & Elegant) ──────────────
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white70, Colors.white38],
                    ).createShader(bounds),
                    child: Text(
                      'AI SO POWERFUL IT GUIDES YOU TO SUCCESS',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyMedium.copyWith(
                        fontSize: 12,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Loading/Branding ─────────────────────
          Positioned(
            bottom: 60,
            child: Column(
              children: [
                SizedBox(
                  width: 40,
                  height: 2,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white10,
                    color: AppTheme.primaryBrand,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'PREMIUM AI EXPERIENCE',
                  style: AppTheme.bodySmall.copyWith(
                    letterSpacing: 4,
                    fontSize: 10,
                    color: Colors.white24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for Orion constellation (three stars forming north)
class ConstellationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // ── Paint setup ──────────────────────────────
    final purplePaint = Paint()
      ..color =
          const Color(0xFF7C3AED) // Royal Purple
      ..style = PaintingStyle.fill;

    final goldPaint = Paint()
      ..color =
          const Color(0xFFFBBA72) // Luxe Gold
      ..style = PaintingStyle.fill;

    final linePaint = Paint()..strokeWidth = 1.0;

    // ── Star Positions ──────────────────────────
    // Center Gold (North Star)
    final centerStar = Offset(size.width * 0.5, size.height * 0.3);
    // Side Purple Stars
    final leftStar = Offset(size.width * 0.28, size.height * 0.65);
    final rightStar = Offset(size.width * 0.72, size.height * 0.65);

    // ── 1. Draw connecting lines with Gradient ─────
    final gradient = LinearGradient(
      colors: [
        const Color(0xFF7C3AED).withOpacity(0.0),
        const Color(0xFFFBBA72).withOpacity(0.4),
        const Color(0xFF7C3AED).withOpacity(0.0),
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

    linePaint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    final path = Path()
      ..moveTo(leftStar.dx, leftStar.dy)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.5,
        centerStar.dx,
        centerStar.dy,
      )
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.5,
        rightStar.dx,
        rightStar.dy,
      );

    canvas.drawPath(path, linePaint..style = PaintingStyle.stroke);

    // ── 2. Helper to draw "Pointy" stars ──────────
    void drawPremiumStar(
      Canvas canvas,
      Offset position,
      double radius,
      Paint starPaint,
      bool isMain,
    ) {
      final glowPaint = Paint()
        ..color = starPaint.color.withOpacity(0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isMain ? 15 : 8);

      // Outer Glow
      canvas.drawCircle(position, radius * 2.5, glowPaint);

      // Star Shape (Diamond/4-pointed star)
      final starPath = Path();
      final r = radius;
      final R = radius * (isMain ? 3.0 : 2.5); // Point length

      starPath.moveTo(position.dx, position.dy - R); // Top
      starPath.lineTo(position.dx + r * 0.6, position.dy - r * 0.6);
      starPath.lineTo(position.dx + R, position.dy); // Right
      starPath.lineTo(position.dx + r * 0.6, position.dy + r * 0.6);
      starPath.lineTo(position.dx, position.dy + R); // Bottom
      starPath.lineTo(position.dx - r * 0.6, position.dy + r * 0.6);
      starPath.lineTo(position.dx - R, position.dy); // Left
      starPath.lineTo(position.dx - r * 0.6, position.dy - r * 0.6);
      starPath.close();

      canvas.drawPath(starPath, starPaint);

      // Core Highlight
      final whitePaint = Paint()..color = Colors.white.withOpacity(0.9);
      canvas.drawCircle(position, radius * 0.3, whitePaint);
    }

    // ── 3. Render Stars ───────────────────────────
    // Side stars (Purple Diamonds)
    drawPremiumStar(canvas, leftStar, 4, purplePaint, false);
    drawPremiumStar(canvas, rightStar, 4, purplePaint, false);

    // North star (Gold Diamond - Large)
    drawPremiumStar(canvas, centerStar, 6, goldPaint, true);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
