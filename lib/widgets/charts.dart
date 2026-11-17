import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

// ───────────────────────────── Smooth animated area / line chart ─────────────
class SmoothLineChart extends StatefulWidget {
  final List<double> data;
  final List<String> labels;
  final Gradient gradient;
  final double height;
  final bool showGrid;
  final List<double>? secondary;
  final String unit;

  const SmoothLineChart({
    super.key,
    required this.data,
    this.labels = const [],
    this.gradient = AppColors.brand,
    this.height = 200,
    this.showGrid = true,
    this.secondary,
    this.unit = '',
  });

  @override
  State<SmoothLineChart> createState() => _SmoothLineChartState();
}

class _SmoothLineChartState extends State<SmoothLineChart> with SingleTickerProviderStateMixin {
  late final AnimationController _c =AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..forward();
  int? _selected;

  @override
  void didUpdateWidget(covariant SmoothLineChart old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) {
      _c.forward(from: 0);
      _selected = null;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _select(Offset p, double w) {
    final n = widget.data.length;
    final i = ((p.dx / w) * (n - 1)).round().clamp(0, n - 1);
    setState(() => _selected = i);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(builder: (context, c) {
        return GestureDetector(
          onPanDown: (d) => _select(d.localPosition, c.maxWidth),
          onPanUpdate: (d) => _select(d.localPosition, c.maxWidth),
          onPanEnd: (_) => setState(() => _selected = null),
          onTapUp: (_) => Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _selected = null);
          }),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              size: Size(c.maxWidth, widget.height),
              painter: _LinePainter(
                data: widget.data,
                secondary: widget.secondary,
                labels: widget.labels,
                gradient: widget.gradient,
                progress: Curves.easeOutCubic.transform(_c.value),
                showGrid: widget.showGrid,
                selected: _selected,
                unit: widget.unit,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> data;
  final List<double>? secondary;
  final List<String> labels;
  final Gradient gradient;
  final double progress;
  final bool showGrid;
  final int? selected;
  final String unit;

  _LinePainter({
    required this.data,
    required this.secondary,
    required this.labels,
    required this.gradient,
    required this.progress,
    required this.showGrid,
    required this.selected,
    required this.unit,
  });

  static const _bottomPad = 26.0;
  static const _topPad = 34.0;

  List<Offset> _points(List<double> d, Size size, double minV, double maxV) {
    final h = size.height - _bottomPad - _topPad;
    final range = (maxV - minV) == 0 ? 1 : (maxV - minV);
    return List.generate(d.length, (i) {
      final x = d.length == 1 ? size.width / 2 : i * size.width / (d.length - 1);
      final norm = (d[i] - minV) / range;
      final y = _topPad + h - norm * h * progress - (1 - progress) * h * 0.0;
      return Offset(x, y);
    });
  }

  Path _smooth(List<Offset> p) {
    final path = Path()..moveTo(p.first.dx, p.first.dy);
    for (var i = 0; i < p.length - 1; i++) {
      final p0 = i > 0 ? p[i - 1] : p[i];
      final p1 = p[i];
      final p2 = p[i + 1];
      final p3 = i + 2 < p.length ? p[i + 2] : p2;
      final c1 = p1 + (p2 - p0) / 6;
      final c2 = p2 - (p3 - p1) / 6;
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final all = [...data, ...?secondary];
    var minV = all.reduce(math.min);
    var maxV = all.reduce(math.max);
    final pad = (maxV - minV) * 0.25 + 0.001;
    minV -= pad;
    maxV += pad;

    // grid
    if (showGrid) {
      final g = Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..strokeWidth = 1;
      for (var i = 0; i < 4; i++) {
        final y = _topPad + i * (size.height - _bottomPad - _topPad) / 3;
        _dashed(canvas, Offset(0, y), Offset(size.width, y), g);
      }
    }

    final rect = Offset.zero & size;

    // secondary series
    if (secondary != null && secondary!.length > 1) {
      final sp = _points(secondary!, size, minV, maxV);
      final path = _smooth(sp);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.25 * progress),
      );
    }

    final pts = _points(data, size, minV, maxV);
    if (pts.length < 2) return;
    final line = _smooth(pts);

    // reveal clip
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress + 2, size.height));

    // fill
    final fill = Path.from(line)
      ..lineTo(pts.last.dx, size.height - _bottomPad)
      ..lineTo(pts.first.dx, size.height - _bottomPad)
      ..close();
    final baseColor = gradient.colors.first;
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [gradient.colors.last.withValues(alpha: 0.38), baseColor.withValues(alpha: 0.0)],
        ).createShader(rect),
    );

    // glow
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..shader = gradient.createShader(rect)
        ..color = Colors.white.withValues(alpha: 0.5),
    );
    // line
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..shader = gradient.createShader(rect),
    );
    canvas.restore();

    // labels
    if (labels.isNotEmpty) {
      for (var i = 0; i < pts.length && i < labels.length; i++) {
        final tp = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: TextStyle(
              color: selected == i ? Colors.white : AppColors.textMuted,
              fontSize: 11,
              fontWeight: selected == i ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        var x = pts[i].dx - tp.width / 2;
        x = x.clamp(0, size.width - tp.width);
        tp.paint(canvas, Offset(x, size.height - tp.height));
      }
    }

    // end point / selection
    final idx = selected ?? (progress > 0.98 ? pts.length - 1 : null);
    if (idx != null) {
      final p = pts[idx];
      if (selected != null) {
        _dashed(
          canvas,
          Offset(p.dx, _topPad - 6),
          Offset(p.dx, size.height - _bottomPad),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.3)
            ..strokeWidth = 1,
        );
      }
      canvas.drawCircle(p, 14, Paint()..color = baseColor.withValues(alpha: 0.18));
      canvas.drawCircle(p, 7, Paint()..color = Colors.white);
      canvas.drawCircle(p, 4, Paint()..shader = gradient.createShader(Rect.fromCircle(center: p, radius: 4)));

      // tooltip
      final v = data[idx];
      final txt = '${v % 1 == 0 ? v.toInt() : v.toStringAsFixed(1)}$unit';
      final tp = TextPainter(
        text: TextSpan(text: txt, style: const TextStyle(color: AppColors.bg, fontWeight: FontWeight.w800, fontSize: 12)),
        textDirection: TextDirection.ltr,
      )..layout();
      final w = tp.width + 18;
      var left = p.dx - w / 2;
      left = left.clamp(0, size.width - w);
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(left, p.dy - 40, w, 26), const Radius.circular(10));
      canvas.drawRRect(r, Paint()..color = Colors.white);
      tp.paint(canvas, Offset(left + 9, p.dy - 40 + (26 - tp.height) / 2));
    }
  }

  void _dashed(Canvas c, Offset a, Offset b, Paint p) {
    const dash = 4.0, gap = 5.0;
    final total = (b - a).distance;
    final dir = (b - a) / total;
    double d = 0;
    while (d < total) {
      final s = a + dir * d;
      final e = a + dir * math.min(d + dash, total);
      c.drawLine(s, e, p);
      d += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter o) => o.progress != progress || o.selected != selected || o.data != data;
}

// ───────────────────────────── Sparkline ─────────────────────────────────────
class Sparkline extends StatelessWidget {
  final List<double> data;
  final Gradient gradient;
  final double height;
  const Sparkline({super.key, required this.data, required this.gradient, this.height = 36});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => CustomPaint(size: Size(double.infinity, height), painter: _SparkPainter(data, gradient, t)),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> d;
  final Gradient g;
  final double t;
  _SparkPainter(this.d, this.g, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    if (d.length < 2) return;
    final mn = d.reduce(math.min), mx = d.reduce(math.max);
    final range = (mx - mn) == 0 ? 1 : mx - mn;
    final pts = List.generate(d.length, (i) => Offset(i * size.width / (d.length - 1), size.height - ((d[i] - mn) / range) * size.height * 0.8 - size.height * 0.1));
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final m = Offset((pts[i].dx + pts[i + 1].dx) / 2, (pts[i].dy + pts[i + 1].dy) / 2);
      path.quadraticBezierTo(pts[i].dx, pts[i].dy, m.dx, m.dy);
    }
    path.lineTo(pts.last.dx, pts.last.dy);
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, -10, size.width * t, size.height + 20));
    final rect = Offset.zero & size;
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [g.colors.first.withValues(alpha: 0.3), Colors.transparent]).createShader(rect));
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..shader = g.createShader(rect));
    canvas.restore();
    if (t > 0.97) {
      canvas.drawCircle(pts.last, 3.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter o) => o.t != t;
}

// ───────────────────────────── Animated bars ─────────────────────────────────
class GlowBarChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final Gradient gradient;
  final double height;
  final int? highlight;
  const GlowBarChart({super.key, required this.data, required this.labels, this.gradient = AppColors.brand, this.height = 170, this.highlight});

  @override
  Widget build(BuildContext context) {
    final mx = data.reduce(math.max);
    final mn = data.reduce(math.min);
    // Start bars above zero so small differences stay visible.
    final base = math.max(0.0, mn - (mx - mn) * 1.2);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (i) {
          final active = highlight == null || highlight == i;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: mx == base ? 1.0 : (data[i] - base) / (mx - base)),
                    duration: Duration(milliseconds: 900 + i * 90),
                    curve: Curves.easeOutBack,
                    builder: (context, v, _) => Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: v.clamp(0.02, 1.0),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: active
                                ? LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: gradient.colors)
                                : LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.white.withValues(alpha: 0.06), Colors.white.withValues(alpha: 0.14)]),
                            boxShadow: active ? [BoxShadow(color: gradient.colors.last.withValues(alpha: 0.45), blurRadius: 16, offset: const Offset(0, 6))] : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(labels[i], style: TextStyle(fontSize: 11, color: active ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ───────────────────────────── Concentric activity rings ─────────────────────
class RingData {
  final double progress;
  final Gradient gradient;
  const RingData(this.progress, this.gradient);
}

class ActivityRings extends StatelessWidget {
  final List<RingData> rings;
  final double size;
  final double stroke;
  final Widget? center;
  const ActivityRings({super.key, required this.rings, this.size = 170, this.stroke = 14, this.center});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingsPainter(rings, stroke, t),
          child: Center(child: center),
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final List<RingData> rings;
  final double stroke;
  final double t;
  _RingsPainter(this.rings, this.stroke, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (var i = 0; i < rings.length; i++) {
      final r = size.width / 2 - stroke / 2 - i * (stroke + 5);
      final rect = Rect.fromCircle(center: c, radius: r);
      canvas.drawCircle(
          c,
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..color = rings[i].gradient.colors.first.withValues(alpha: 0.12));
      final sweep = 2 * math.pi * rings[i].progress * t;
      final shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: [...rings[i].gradient.colors, rings[i].gradient.colors.first],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
      canvas.drawArc(
          rect,
          -math.pi / 2,
          sweep,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
            ..shader = shader);
      canvas.drawArc(
          rect,
          -math.pi / 2,
          sweep,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..strokeCap = StrokeCap.round
            ..shader = shader);
      // head dot
      final a = -math.pi / 2 + sweep;
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * r, stroke * 0.22, Paint()..color = Colors.white.withValues(alpha: 0.9));
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter o) => o.t != t;
}

// ───────────────────────────── Live ECG trace ────────────────────────────────
class EcgLine extends StatefulWidget {
  final Color color;
  final double height;
  final double speed;
  const EcgLine({super.key, this.color = AppColors.rose, this.height = 60, this.speed = 1});

  @override
  State<EcgLine> createState() => _EcgLineState();
}

class _EcgLineState extends State<EcgLine> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Duration(milliseconds: (2200 / widget.speed).round()))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(size: Size(double.infinity, widget.height), painter: _EcgPainter(_c.value, widget.color)),
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  final double t;
  final Color color;
  _EcgPainter(this.t, this.color);

  double _beat(double x) {
    // x in [0,1) one heartbeat
    double g(double mu, double sigma, double a) => a * math.exp(-math.pow(x - mu, 2) / (2 * sigma * sigma));
    return g(0.18, 0.025, 0.12) - g(0.36, 0.01, 0.15) + g(0.4, 0.012, 1.0) - g(0.44, 0.012, 0.28) + g(0.68, 0.05, 0.22);
  }

  @override
  void paint(Canvas canvas, Size size) {
    const beats = 2.5;
    final path = Path();
    final mid = size.height * 0.62;
    for (double px = 0; px <= size.width; px += 1.5) {
      final phase = (px / size.width * beats + t * beats) % 1.0;
      final y = mid - _beat(phase) * size.height * 0.55;
      if (px == 0) {
        path.moveTo(px, y);
      } else {
        path.lineTo(px, y);
      }
    }
    final rect = Offset.zero & size;
    final shader = LinearGradient(colors: [color.withValues(alpha: 0), color, color]).createShader(rect);
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..shader = shader);
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeJoin = StrokeJoin.round
          ..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _EcgPainter o) => o.t != t;
}

// ───────────────────────────── Semi gauge ────────────────────────────────────
class ArcGauge extends StatelessWidget {
  final double value; // 0..1
  final Gradient gradient;
  final double size;
  final Widget? center;
  const ArcGauge({super.key, required this.value, this.gradient = AppColors.brand, this.size = 140, this.center});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 1600),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox(
        width: size,
        height: size * 0.62,
        child: CustomPaint(painter: _GaugePainter(v, gradient), child: Align(alignment: const Alignment(0, 0.6), child: center)),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double v;
  final Gradient g;
  _GaugePainter(this.v, this.g);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - 10;
    final c = Offset(size.width / 2, size.height - 6);
    final rect = Rect.fromCircle(center: c, radius: r);
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.08);
    canvas.drawArc(rect, math.pi, math.pi, false, bg);
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..shader = g.createShader(rect);
    canvas.drawArc(rect, math.pi, math.pi * v, false, fg);
    // ticks
    final tick = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1.5;
    for (var i = 0; i <= 10; i++) {
      final a = math.pi + math.pi * i / 10;
      final o = c + Offset(math.cos(a), math.sin(a)) * (r - 16);
      final ii = c + Offset(math.cos(a), math.sin(a)) * (r - 22);
      canvas.drawLine(o, ii, tick);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter o) => o.v != v;
}
