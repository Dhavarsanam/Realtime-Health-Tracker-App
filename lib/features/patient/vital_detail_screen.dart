import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';

class VitalDetailScreen extends StatefulWidget {
  final Vital vital;
  const VitalDetailScreen({super.key, required this.vital});

  @override
  State<VitalDetailScreen> createState() => _VitalDetailScreenState();
}

class _VitalDetailScreenState extends State<VitalDetailScreen> {
  int _range = 0;

  List<double> get _data {
    final base = widget.vital.trend;
    if (_range == 0) return base;
    final r = math.Random(_range * 7 + widget.vital.key.length);
    final n = _range == 1 ? 12 : 12;
    final avg = base.reduce((a, b) => a + b) / base.length;
    return List.generate(n, (i) => avg * (0.9 + r.nextDouble() * 0.2));
  }

  List<String> get _labels => switch (_range) {
        0 => MockData.weekDays,
        1 => List.generate(12, (i) => i.isEven ? 'W${i + 1}' : ''),
        _ => const ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'],
      };

  @override
  Widget build(BuildContext context) {
    final v = widget.vital;
    final d = _data;
    final avg = d.reduce((a, b) => a + b) / d.length;
    final mn = d.reduce(math.min), mx = d.reduce(math.max);
    String f(double x) => x >= 100 ? x.round().toString() : x.toStringAsFixed(1);
    return Scaffold(
      body: AuroraBackground(
        colors: [v.gradient.colors.first, v.gradient.colors.last, AppColors.indigo],
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              PageHeader(title: v.name, subtitle: 'Detailed history & insights'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Hero(
                      tag: 'vital-${v.key}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Tilt3D(
                          maxAngle: 0.1,
                          child: GlassCard(
                            glow: v.gradient.colors.first,
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  IconOrb(icon: v.icon, gradient: v.gradient, size: 54, iconSize: 26),
                                  const Spacer(),
                                  StatusPill(v.status),
                                ]),
                                const SizedBox(height: 18),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    GradientText(v.value, gradient: v.gradient, style: Theme.of(context).textTheme.displayMedium),
                                    const SizedBox(width: 8),
                                    Text(v.unit, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                                  ],
                                ),
                                const Text('Latest reading · 08:12 AM today', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    GlassCard(
                      child: Column(
                        children: [
                          _Segmented(
                            items: const ['Week', 'Month', 'Year'],
                            index: _range,
                            gradient: v.gradient,
                            onChanged: (i) => setState(() => _range = i),
                          ),
                          const SizedBox(height: 18),
                          SmoothLineChart(data: d, labels: _labels, gradient: v.gradient, height: 220, unit: ''),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(child: _stat('Average', f(avg), v.gradient)),
                        const SizedBox(width: 12),
                        Expanded(child: _stat('Lowest', f(mn), v.gradient)),
                        const SizedBox(width: 12),
                        Expanded(child: _stat('Highest', f(mx), v.gradient)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    GlassCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const IconOrb(icon: Icons.lightbulb_rounded, gradient: AppColors.sunset, size: 40, iconSize: 20),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Healthy range', style: TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(_rangeText(v.key), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.45)),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _rangeText(String k) => switch (k) {
        'hr' => 'Resting heart rate of 60–80 bpm is considered optimal for most adults.',
        'bp' => 'Below 120/80 mmHg is optimal. 120–129 systolic is elevated.',
        'gl' => 'Fasting glucose 70–99 mg/dL is normal; 100–125 indicates prediabetes.',
        'wt' => 'Aim for 2.5–3.5 L of water daily depending on activity and climate.',
        'sl' => '7–9 hours of quality sleep supports recovery and heart health.',
        _ => '1,800–2,500 kcal/day for moderately active adults.',
      };

  Widget _stat(String k, String v, Gradient g) => GlassCard(
        radius: 20,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(children: [
          Text(k, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
          const SizedBox(height: 6),
          GradientText(v, gradient: g, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ]),
      );
}

class _Segmented extends StatelessWidget {
  final List<String> items;
  final int index;
  final Gradient gradient;
  final ValueChanged<int> onChanged;
  const _Segmented({required this.items, required this.index, required this.gradient, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(14)),
      child: LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth / items.length;
        return Stack(children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            left: w * index,
            top: 0,
            bottom: 0,
            width: w,
            child: Container(decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(10))),
          ),
          Row(
            children: List.generate(
              items.length,
              (i) => Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: Center(
                    child: Text(items[i], style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: i == index ? Colors.white : AppColors.textSecondary)),
                  ),
                ),
              ),
            ),
          ),
        ]);
      }),
    );
  }
}

/// Public reusable segmented control.
class SegmentedTabs extends StatelessWidget {
  final List<String> items;
  final int index;
  final Gradient gradient;
  final ValueChanged<int> onChanged;
  const SegmentedTabs({super.key, required this.items, required this.index, this.gradient = AppColors.brand, required this.onChanged});

  @override
  Widget build(BuildContext context) => _Segmented(items: items, index: index, gradient: gradient, onChanged: onChanged);
}
