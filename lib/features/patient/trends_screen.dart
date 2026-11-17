import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';
import 'vital_detail_screen.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  int _metric = 0;

  @override
  Widget build(BuildContext context) {
    final v = MockData.vitals[_metric];
    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
        children: [
          Entrance(
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Health trends', style: Theme.of(context).textTheme.headlineMedium),
                  const Text('Your last 7 days at a glance', style: TextStyle(color: AppColors.textSecondary)),
                ]),
              ),
              GlassIconButton(icon: Icons.ios_share_rounded, onTap: () {}),
            ]),
          ),
          const SizedBox(height: 18),
          Entrance(
            index: 1,
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: MockData.vitals.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final active = i == _metric;
                  final m = MockData.vitals[i];
                  return Pressable(
                    onTap: () => setState(() => _metric = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        gradient: active ? m.gradient : null,
                        color: active ? null : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: active ? Colors.transparent : AppColors.stroke),
                      ),
                      child: Row(children: [
                        Icon(m.icon, size: 17, color: Colors.white),
                        const SizedBox(width: 7),
                        Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          Entrance(
            index: 2,
            child: GlassCard(
              glow: v.gradient.colors.first,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    IconOrb(icon: v.icon, gradient: v.gradient, size: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(v.name, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text('${v.value} ${v.unit}', key: ValueKey(v.key), style: Theme.of(context).textTheme.headlineSmall),
                        ),
                      ]),
                    ),
                    StatusPill(v.status),
                  ]),
                  const SizedBox(height: 20),
                  SmoothLineChart(
                    key: ValueKey(v.key),
                    data: v.trend,
                    secondary: v.trend.reversed.map((e) => e * 0.97).toList(),
                    labels: MockData.weekDays,
                    gradient: v.gradient,
                    height: 220,
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    _legend(v.gradient, 'This week'),
                    const SizedBox(width: 16),
                    _legend(LinearGradient(colors: [Colors.white.withValues(alpha: 0.3), Colors.white.withValues(alpha: 0.3)]), 'Last week'),
                    const Spacer(),
                    Pressable(
                      onTap: () => Navigator.of(context).push(premiumRoute(VitalDetailScreen(vital: v))),
                      child: const Text('Details →', style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Entrance(
            index: 3,
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Text('Weekly activity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    Spacer(),
                    Text('avg 7,940 steps', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ]),
                  const SizedBox(height: 18),
                  GlowBarChart(
                    data: const [6200, 8400, 7100, 9800, 5600, 10400, 8432],
                    labels: MockData.weekDays,
                    gradient: AppColors.mint,
                    highlight: DateTime.now().weekday - 1,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Entrance(
            index: 4,
            child: Row(
              children: [
                Expanded(child: _summary('Sleep quality', '86%', Icons.bedtime_rounded, AppColors.night, 0.86)),
                const SizedBox(width: 14),
                Expanded(child: _summary('Hydration', '63%', Icons.local_drink_rounded, AppColors.aqua, 0.63)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Gradient g, String t) => Row(children: [
        Container(width: 14, height: 4, decoration: BoxDecoration(gradient: g, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(t, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
      ]);

  Widget _summary(String k, String v, IconData i, Gradient g, double p) => GlassCard(
        child: Column(children: [
          ActivityRings(
            size: 96,
            stroke: 9,
            rings: [RingData(p, g)],
            center: Icon(i, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 12),
          GradientText(v, gradient: g, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          Text(k, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ]),
      );
}
