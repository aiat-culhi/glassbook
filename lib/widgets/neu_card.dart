// lib/widgets/neu_card.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum NeuStyle { flat, pressed, convex, concave }

/// Neumorphism card with soft shadows (dark theme variant)
class NeuCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final NeuStyle style;
  final VoidCallback? onTap;
  final Color? color;

  const NeuCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.style = NeuStyle.flat,
    this.onTap,
    this.color,
  });

  List<BoxShadow> _getShadows() {
    final base = color ?? AppColors.neuBase;
    switch (style) {
      case NeuStyle.pressed:
        return [
          BoxShadow(
            color: AppColors.neuShadowDark.withOpacity(0.8),
            offset: const Offset(4, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.neuShadowLight.withOpacity(0.6),
            offset: const Offset(-4, -4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ];
      case NeuStyle.convex:
        return [
          BoxShadow(
            color: AppColors.neuShadowDark.withOpacity(0.9),
            offset: const Offset(8, 8),
            blurRadius: 20,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.neuShadowLight.withOpacity(0.7),
            offset: const Offset(-8, -8),
            blurRadius: 20,
            spreadRadius: -2,
          ),
        ];
      case NeuStyle.concave:
        return [
          BoxShadow(
            color: AppColors.neuShadowLight.withOpacity(0.5),
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
          BoxShadow(
            color: AppColors.neuShadowDark.withOpacity(0.9),
            offset: const Offset(-4, -4),
            blurRadius: 10,
          ),
        ];
      case NeuStyle.flat:
      default:
        return [
          BoxShadow(
            color: AppColors.neuShadowDark.withOpacity(0.9),
            offset: const Offset(6, 6),
            blurRadius: 16,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.neuShadowLight.withOpacity(0.6),
            offset: const Offset(-6, -6),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ];
    }
  }

  Gradient? _getGradient() {
    if (style == NeuStyle.convex) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF232548),
          Color(0xFF1A1C38),
        ],
      );
    }
    if (style == NeuStyle.concave) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A1C38),
          Color(0xFF232548),
        ],
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? AppColors.neuBase,
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: _getGradient(),
          boxShadow: _getShadows(),
        ),
        child: child,
      ),
    );
  }
}

/// Neumorphic toggle / icon button
class NeuIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool isActive;
  final double size;

  const NeuIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.isActive = false,
    this.size = 48,
  });

  @override
  State<NeuIconButton> createState() => _NeuIconButtonState();
}

class _NeuIconButtonState extends State<NeuIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: AppColors.neuBase,
          borderRadius: BorderRadius.circular(widget.size / 3),
          boxShadow: _pressed || widget.isActive
              ? [
                  BoxShadow(
                    color: AppColors.neuShadowDark.withOpacity(0.9),
                    offset: const Offset(3, 3),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: AppColors.neuShadowLight.withOpacity(0.6),
                    offset: const Offset(-3, -3),
                    blurRadius: 8,
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.neuShadowDark.withOpacity(0.9),
                    offset: const Offset(5, 5),
                    blurRadius: 14,
                  ),
                  BoxShadow(
                    color: AppColors.neuShadowLight.withOpacity(0.7),
                    offset: const Offset(-5, -5),
                    blurRadius: 14,
                  ),
                ],
        ),
        child: Center(
          child: Icon(
            widget.icon,
            color: widget.isActive
                ? AppColors.accentViolet
                : (widget.iconColor ?? AppColors.textSecondary),
            size: widget.size * 0.45,
          ),
        ),
      ),
    );
  }
}

/// Neumorphic progress/rating bar
class NeuRatingBar extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;

  const NeuRatingBar({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Padding(
          padding: const EdgeInsets.only(right: 3),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.neuBase,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neuShadowDark.withOpacity(0.9),
                  offset: const Offset(2, 2),
                  blurRadius: 5,
                ),
                BoxShadow(
                  color: AppColors.neuShadowLight.withOpacity(0.7),
                  offset: const Offset(-2, -2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                filled
                    ? Icons.star_rounded
                    : half
                        ? Icons.star_half_rounded
                        : Icons.star_outline_rounded,
                size: size * 0.75,
                color: filled || half
                    ? AppColors.accentAmber
                    : AppColors.textMuted,
              ),
            ),
          ),
        );
      }),
    );
  }
}
