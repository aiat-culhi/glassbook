// lib/widgets/animated_background.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _orb1;
  late AnimationController _orb2;
  late AnimationController _orb3;

  @override
  void initState() {
    super.initState();
    _orb1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    _orb2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
    _orb3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orb1.dispose();
    _orb2.dispose();
    _orb3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.bgDark,
                Color(0xFF0F1020),
                AppColors.bgMid,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Animated orbs
        AnimatedBuilder(
          animation: Listenable.merge([_orb1, _orb2, _orb3]),
          builder: (context, _) {
            final size = MediaQuery.of(context).size;
            return CustomPaint(
              painter: _OrbPainter(
                orb1Progress: _orb1.value,
                orb2Progress: _orb2.value,
                orb3Progress: _orb3.value,
                size: size,
              ),
              size: size,
            );
          },
        ),
        // Content
        widget.child,
      ],
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double orb1Progress;
  final double orb2Progress;
  final double orb3Progress;
  final Size size;

  _OrbPainter({
    required this.orb1Progress,
    required this.orb2Progress,
    required this.orb3Progress,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawOrb(
      canvas,
      center: Offset(
        size.width * 0.15 + size.width * 0.2 * orb1Progress,
        size.height * 0.15 +
            size.height * 0.1 * math.sin(orb1Progress * math.pi),
      ),
      radius: size.width * 0.4,
      color: AppColors.accentViolet.withOpacity(0.08),
    );

    _drawOrb(
      canvas,
      center: Offset(
        size.width * 0.7 + size.width * 0.15 * math.sin(orb2Progress * math.pi),
        size.height * 0.3 - size.height * 0.1 * orb2Progress,
      ),
      radius: size.width * 0.35,
      color: AppColors.accentCyan.withOpacity(0.06),
    );

    _drawOrb(
      canvas,
      center: Offset(
        size.width * 0.5 - size.width * 0.1 * orb3Progress,
        size.height * 0.75 +
            size.height * 0.08 * math.cos(orb3Progress * math.pi),
      ),
      radius: size.width * 0.45,
      color: AppColors.accentRose.withOpacity(0.05),
    );
  }

  void _drawOrb(Canvas canvas,
      {required Offset center, required double radius, required Color color}) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_OrbPainter oldDelegate) =>
      oldDelegate.orb1Progress != orb1Progress ||
      oldDelegate.orb2Progress != orb2Progress ||
      oldDelegate.orb3Progress != orb3Progress;
}
