import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = MockData.goals;
    return Scaffold(
      body: AuroraBackground(
        colors: const [AppColors.amber, AppColors.pink, AppColors.violet],
        child: SafeArea(
          child: Column(
            children: [
              PageHeader(
                title: 'Health goals',
                subtitle: 'Personalized daily targets',
                actions: [GlassIconButton(icon: Icons.add_rounded, onTap: () => _showAdd(context))],
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                  children: [
                    Entrance(
                      child: Tilt3D(
                        child: GlassCard(
                          glow: AppColors.amber,
                          padding: const EdgeInsets.all(22),
                          child: Row(
                            children: [
                              ActivityRings(
                                size: 124,
                                stroke: 8,
                                rings: goals.map((g) => RingData(g.progress, g.gradient)).toList(),
                                center: const Text('3/4', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  const Text('3 of 4 goals on track', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  const Text('🔥 12-day streak', maxLines: 1, softWrap: false, overflow: TextOverflow.fade, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                  const SizedBox(height: 6),
                                  const Text('You\'ve hit your goals 12 days in a row. Keep the momentum!', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: List.generate(7, (i) {
                                      final done = i < 5;
                                      return Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.only(right: 4),
                                          height: 26,
                                          decoration: BoxDecoration(
                                            gradient: done ? AppColors.sunset : null,
                                            color: done ? null : Colors.white.withValues(alpha: 0.07),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(MockData.weekDays[i][0], style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                                        ),
                                      );
                                    }),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...goals.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Entrance(index: e.key + 1, child: _GoalTile(goal: e.value)),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
          decoration: const BoxDecoration(color: AppColors.bgElevated, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 18),
              Text('New goal', style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final g in [('Steps', Icons.directions_walk_rounded, AppColors.mint), ('Water', Icons.local_drink_rounded, AppColors.aqua), ('Sleep', Icons.bedtime_rounded, AppColors.night), ('Weight', Icons.monitor_weight_rounded, AppColors.sunset), ('Meditation', Icons.self_improvement_rounded, AppColors.brand)])
                    Container(
                      padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.stroke)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconOrb(icon: g.$2, gradient: g.$3, size: 30, iconSize: 15),
                        const SizedBox(width: 8),
                        Text(g.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ]),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const TextField(keyboardType: TextInputType.number, decoration: InputDecoration(hintText: 'Daily target', prefixIcon: Icon(Icons.flag_rounded))),
              const SizedBox(height: 18),
              GradientButton(label: 'Create goal', gradient: AppColors.sunset, onTap: () => Navigator.pop(ctx)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final Goal goal;
  const _GoalTile({required this.goal});

  @override
  Widget build(BuildContext context) {
    String fmt(double v) => v >= 100 ? v.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},') : v.toStringAsFixed(1);
    return GlassCard(
      child: Column(
        children: [
          Row(children: [
            IconOrb(icon: goal.icon, gradient: goal.gradient, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(goal.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text('${fmt(goal.current)} / ${fmt(goal.target)} ${goal.unit}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
              ]),
            ),
            GradientText('${(goal.progress * 100).round()}%', gradient: goal.gradient, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          ]),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 10,
              color: Colors.white.withValues(alpha: 0.07),
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: goal.progress),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => FractionallySizedBox(
                  widthFactor: v,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: goal.gradient,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: goal.gradient.colors.last.withValues(alpha: 0.6), blurRadius: 10)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
