import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';

class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  bool _tracking = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        colors: const [AppColors.emerald, AppColors.teal, AppColors.sky],
        child: SafeArea(
          child: Column(
            children: [
              const PageHeader(title: 'Step tracker', subtitle: 'GPS-based activity tracking'),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                  children: [
                    Entrance(
                      child: Center(
                        child: ActivityRings(
                          size: 230,
                          stroke: 18,
                          rings: const [RingData(0.84, AppColors.mint)],
                          center: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.directions_walk_rounded, color: AppColors.emerald, size: 30),
                            CountUp(8432, style: Theme.of(context).textTheme.displaySmall),
                            const Text('of 10,000 steps', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Entrance(
                      index: 1,
                      child: Row(children: [
                        Expanded(child: _metric(Icons.route_rounded, '6.2', 'km', AppColors.mint)),
                        const SizedBox(width: 12),
                        Expanded(child: _metric(Icons.local_fire_department_rounded, '420', 'kcal', AppColors.sunset)),
                        const SizedBox(width: 12),
                        Expanded(child: _metric(Icons.timer_rounded, '74', 'min', AppColors.aqua)),
                      ]),
                    ),
                    const SizedBox(height: 18),
                    Entrance(
                      index: 2,
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            const SizedBox(height: 260, child: _LiveRouteMap()),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(children: [
                                const IconOrb(icon: Icons.my_location_rounded, gradient: AppColors.mint, size: 40, iconSize: 20),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text('Central Park Loop', style: TextStyle(fontWeight: FontWeight.w700)),
                                    Text('Live location · accuracy ±4 m', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ]),
                                ),
                                Switch(
                                  value: _tracking,
                                  activeThumbColor: Colors.white,
                                  activeTrackColor: AppColors.emerald,
                                  onChanged: (v) => setState(() => _tracking = v),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Entrance(
                      index: 3,
                      child: GlassCard(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('This week', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 16),
                          GlowBarChart(
                            data: const [6200, 8400, 7100, 9800, 5600, 10400, 8432],
                            labels: MockData.weekDays,
                            gradient: AppColors.mint,
                            height: 150,
                            highlight: DateTime.now().weekday - 1,
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(IconData i, String v, String u, Gradient g) => GlassCard(
        radius: 20,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(children: [
          IconOrb(icon: i, gradient: g, size: 36, iconSize: 18),
          const SizedBox(height: 10),
          Text(v, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text(u, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ]),
      );
}

/// Stylized dark map with an animated GPS route and a pulsing location puck.
class _LiveRouteMap extends StatefulWidget {
  const _LiveRouteMap();

  @override
  State<_LiveRouteMap> createState() => _LiveRouteMapState();
}

class _LiveRouteMapState extends State<_LiveRouteMap> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(painter: _MapPainter(_c.value), size: Size.infinite),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final double t;
  _MapPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0A1226));
    // park blocks
    final park = Paint()..color = const Color(0xFF0F2A22);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.18, size.height * 0.15, size.width * 0.55, size.height * 0.6), const Radius.circular(18)), park);
    final water = Paint()..color = const Color(0xFF0B2440);
    canvas.drawOval(Rect.fromLTWH(size.width * 0.36, size.height * 0.3, size.width * 0.2, size.height * 0.18), water);
    // streets
    final street = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 6;
    for (var i = 0; i < 6; i++) {
      final x = size.width * i / 5;
      canvas.drawLine(Offset(x, 0), Offset(x + 40, size.height), street);
    }
    for (var i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 20), street..strokeWidth = 4);
    }

    // route
    final pts = <Offset>[];
    for (var i = 0; i <= 100; i++) {
      final a = i / 100 * 2 * math.pi;
      pts.add(Offset(
        size.width * (0.45 + 0.24 * math.cos(a) + 0.04 * math.sin(3 * a)),
        size.height * (0.45 + 0.28 * math.sin(a) + 0.03 * math.cos(5 * a)),
      ));
    }
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = Colors.white.withValues(alpha: 0.08));

    final metric = path.computeMetrics().first;
    final len = metric.length * 0.84;
    final done = metric.extractPath(0, len);
    final rect = Offset.zero & size;
    canvas.drawPath(
        done,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
          ..shader = AppColors.mint.createShader(rect));
    canvas.drawPath(
        done,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..shader = AppColors.mint.createShader(rect));

    // traveling dash
    final dashPos = metric.getTangentForOffset(len * t)!.position;
    canvas.drawCircle(dashPos, 3, Paint()..color = Colors.white.withValues(alpha: 0.8));

    // start marker
    canvas.drawCircle(pts.first, 7, Paint()..color = Colors.white);
    canvas.drawCircle(pts.first, 4, Paint()..color = AppColors.emerald);

    // puck
    final puck = metric.getTangentForOffset(len)!.position;
    final pulse = (t * 2) % 1.0;
    canvas.drawCircle(puck, 10 + pulse * 26, Paint()..color = AppColors.sky.withValues(alpha: (1 - pulse) * 0.35));
    canvas.drawCircle(puck, 11, Paint()..color = Colors.white);
    canvas.drawCircle(puck, 7.5, Paint()..color = AppColors.sky);
  }

  @override
  bool shouldRepaint(covariant _MapPainter o) => o.t != t;
}
