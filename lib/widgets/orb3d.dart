import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// A real-time rendered 3D wireframe sphere (projected lat/long lines),
/// with depth-shaded strokes, orbiting particles and a breathing glow.
class HoloOrb extends StatefulWidget {
  final double size;
  final List<Color> colors;
  final Widget? child;
  final double speed;
  const HoloOrb({super.key, this.size = 220, this.colors = const [AppColors.cyan, AppColors.violet], this.child, this.speed = 1});

  @override
  State<HoloOrb> createState() => _HoloOrbState();
}

class _HoloOrbState extends State<HoloOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Duration(milliseconds: (14000 / widget.speed).round()))..repeat();
  Offset _drag = Offset.zero;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (d) => setState(() => _drag += d.delta * 0.01),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, child) => CustomPaint(
              painter: _OrbPainter(_c.value, widget.colors, _drag),
              child: child,
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double t;
  final List<Color> colors;
  final Offset drag;
  _OrbPainter(this.t, this.colors, this.drag);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * 0.36;
    final rotY = t * 2 * math.pi + drag.dx;
    final rotX = -0.45 + math.sin(t * 2 * math.pi) * 0.15 + drag.dy;
    final breath = 0.5 + 0.5 * math.sin(t * 2 * math.pi * 4);

    // outer glow
    canvas.drawCircle(
        c,
        r * 1.45,
        Paint()
          ..shader = RadialGradient(colors: [colors[0].withValues(alpha: 0.28 + breath * 0.08), colors[1].withValues(alpha: 0.08), Colors.transparent], stops: const [0.0, 0.55, 1.0])
              .createShader(Rect.fromCircle(center: c, radius: r * 1.45)));

    // glass body
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.35, -0.45),
            radius: 1.1,
            colors: [Colors.white.withValues(alpha: 0.22), colors[1].withValues(alpha: 0.22), AppColors.bg.withValues(alpha: 0.6)],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(Rect.fromCircle(center: c, radius: r)));

    Offset project(double lat, double lon) {
      // sphere point
      var x = math.cos(lat) * math.cos(lon);
      var y = math.sin(lat);
      var z = math.cos(lat) * math.sin(lon);
      // rotate Y
      final x1 = x * math.cos(rotY) + z * math.sin(rotY);
      final z1 = -x * math.sin(rotY) + z * math.cos(rotY);
      // rotate X
      final y2 = y * math.cos(rotX) - z1 * math.sin(rotX);
      final z2 = y * math.sin(rotX) + z1 * math.cos(rotX);
      x = x1;
      y = y2;
      z = z2;
      final persp = 1 / (1.9 - z * 0.35);
      return Offset(c.dx + x * r * persp * 1.2, c.dy + y * r * persp * 1.2);
    }

    double depth(double lat, double lon) {
      final x = math.cos(lat) * math.cos(lon);
      final y = math.sin(lat);
      final z = math.cos(lat) * math.sin(lon);
      final z1 = -x * math.sin(rotY) + z * math.cos(rotY);
      return y * math.sin(rotX) + z1 * math.cos(rotX);
    }

    void segment(double lat1, double lon1, double lat2, double lon2, Color col) {
      final d = (depth(lat1, lon1) + 1) / 2; // 0 back .. 1 front
      final p = Paint()
        ..strokeWidth = 0.6 + d * 1.4
        ..strokeCap = StrokeCap.round
        ..color = col.withValues(alpha: 0.08 + d * 0.62);
      canvas.drawLine(project(lat1, lon1), project(lat2, lon2), p);
    }

    const steps = 48;
    // latitudes
    for (var i = -3; i <= 3; i++) {
      final lat = i * math.pi / 8;
      for (var s = 0; s < steps; s++) {
        final a = s * 2 * math.pi / steps, b = (s + 1) * 2 * math.pi / steps;
        segment(lat, a, lat, b, Color.lerp(colors[0], colors[1], (i + 3) / 6)!);
      }
    }
    // longitudes
    for (var j = 0; j < 8; j++) {
      final lon = j * math.pi / 8;
      for (var s = 0; s < steps; s++) {
        final a = -math.pi / 2 + s * math.pi / steps * 2, b = -math.pi / 2 + (s + 1) * math.pi / steps * 2;
        segment(a, lon, b, lon, colors[0]);
      }
    }

    // nodes
    final rnd = math.Random(7);
    for (var k = 0; k < 26; k++) {
      final lat = (rnd.nextDouble() - 0.5) * math.pi;
      final lon = rnd.nextDouble() * 2 * math.pi;
      final d = (depth(lat, lon) + 1) / 2;
      if (d < 0.45) continue;
      final p = project(lat, lon);
      final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi * 3 + k);
      canvas.drawCircle(p, 2 + d * 2.5, Paint()..color = Colors.white.withValues(alpha: 0.4 + 0.5 * d * pulse));
      canvas.drawCircle(p, 6 + d * 4, Paint()..color = colors[k % 2].withValues(alpha: 0.18 * d * pulse));
    }

    // orbit ring (tilted ellipse) with satellites
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-0.35);
    final orbit = Rect.fromCenter(center: Offset.zero, width: r * 3.0, height: r * 0.9);
    canvas.drawOval(
        orbit,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..shader = SweepGradient(colors: [colors[0].withValues(alpha: 0), colors[0], colors[1], colors[1].withValues(alpha: 0)]).createShader(orbit));
    for (var s = 0; s < 3; s++) {
      final a = t * 2 * math.pi * 1.5 + s * 2 * math.pi / 3;
      final p = Offset(math.cos(a) * orbit.width / 2, math.sin(a) * orbit.height / 2);
      final front = math.sin(a) > 0;
      canvas.drawCircle(p, front ? 5 : 3, Paint()..color = (s.isEven ? colors[0] : colors[1]).withValues(alpha: front ? 1 : 0.4));
      if (front) canvas.drawCircle(p, 12, Paint()..color = colors[s % 2].withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }
    canvas.restore();

    // specular
    canvas.drawCircle(
        c + Offset(-r * 0.35, -r * 0.42),
        r * 0.35,
        Paint()
          ..shader = RadialGradient(colors: [Colors.white.withValues(alpha: 0.35), Colors.transparent])
              .createShader(Rect.fromCircle(center: c + Offset(-r * 0.35, -r * 0.42), radius: r * 0.35)));
  }

  @override
  bool shouldRepaint(covariant _OrbPainter o) => o.t != t || o.drag != drag;
}

/// Heart that beats with a two-phase "lub-dub" and emits ripple rings.
class BeatingHeart extends StatefulWidget {
  final double size;
  final int bpm;
  const BeatingHeart({super.key, this.size = 64, this.bpm = 72});

  @override
  State<BeatingHeart> createState() => _BeatingHeartState();
}

class _BeatingHeartState extends State<BeatingHeart> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Duration(milliseconds: (60000 / widget.bpm).round()))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _scale(double v) {
    if (v < 0.12) return 1 + 0.18 * math.sin(v / 0.12 * math.pi);
    if (v > 0.22 && v < 0.36) return 1 + 0.12 * math.sin((v - 0.22) / 0.14 * math.pi);
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final v = _c.value;
        return SizedBox(
          width: widget.size * 1.8,
          height: widget.size * 1.8,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 2; i++)
                Builder(builder: (_) {
                  final p = (v + i * 0.5) % 1.0;
                  return Container(
                    width: widget.size * (0.9 + p * 0.9),
                    height: widget.size * (0.9 + p * 0.9),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.rose.withValues(alpha: (1 - p) * 0.5), width: 1.5),
                    ),
                  );
                }),
              Transform.scale(
                scale: _scale(v),
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (b) => AppColors.heart.createShader(b),
                  child: Icon(Icons.favorite_rounded, size: widget.size, shadows: const [Shadow(color: AppColors.rose, blurRadius: 24)]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Expanding radar pulses, used for the SOS button.
class PulseRings extends StatefulWidget {
  final double size;
  final Color color;
  final Widget child;
  final int count;
  const PulseRings({super.key, required this.child, this.size = 260, this.color = AppColors.rose, this.count = 3});

  @override
  State<PulseRings> createState() => _PulseRingsState();
}

class _PulseRingsState extends State<PulseRings> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Stack(
          alignment: Alignment.center,
          children: [
            for (var i = 0; i < widget.count; i++)
              Builder(builder: (_) {
                final p = (_c.value + i / widget.count) % 1.0;
                final s = widget.size * (0.45 + p * 0.55);
                return Container(
                  width: s,
                  height: s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: (1 - p) * 0.16),
                    border: Border.all(color: widget.color.withValues(alpha: (1 - p) * 0.6), width: 1.5),
                  ),
                );
              }),
            child!,
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
