import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Animated, slowly drifting aurora blobs behind content, with a subtle
/// noise-like grid for depth.
class AuroraBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final bool showGrid;

  const AuroraBackground({
    super.key,
    required this.child,
    this.colors = const [AppColors.violet, AppColors.cyan, AppColors.pink],
    this.showGrid = true,
  });

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: AppColors.bg)),
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final t = _c.value * 2 * math.pi;
                return ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                  child: CustomPaint(painter: _BlobPainter(t, widget.colors)),
                );
              },
            ),
          ),
        ),
        if (widget.showGrid) const Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _GridPainter()))),
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double t;
  final List<Color> colors;
  _BlobPainter(this.t, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final blobs = [
      (Offset(w * (0.15 + 0.12 * math.sin(t)), h * (0.12 + 0.06 * math.cos(t * 1.3))), w * 0.55, colors[0]),
      (Offset(w * (0.9 + 0.08 * math.cos(t * 0.8)), h * (0.35 + 0.08 * math.sin(t))), w * 0.5, colors[1]),
      (Offset(w * (0.4 + 0.15 * math.sin(t * 0.6)), h * (0.85 + 0.05 * math.cos(t))), w * 0.6, colors[2 % colors.length]),
    ];
    for (final b in blobs) {
      final paint = Paint()
        ..shader = RadialGradient(colors: [b.$3.withValues(alpha: 0.45), b.$3.withValues(alpha: 0)])
            .createShader(Rect.fromCircle(center: b.$1, radius: b.$2));
      canvas.drawCircle(b.$1, b.$2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BlobPainter old) => old.t != t;
}

class _GridPainter extends CustomPainter {
  const _GridPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    // vignette
    final v = Paint()
      ..shader = RadialGradient(
        radius: 1.1,
        colors: [Colors.transparent, AppColors.bg.withValues(alpha: 0.7)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, v);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
