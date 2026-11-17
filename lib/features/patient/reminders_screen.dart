import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _items = MockData.reminders;

  @override
  Widget build(BuildContext context) {
    final active = _items.where((e) => e.enabled).length;
    return Scaffold(
      body: AuroraBackground(
        colors: const [AppColors.indigo, AppColors.sky, AppColors.violet],
        child: SafeArea(
          child: Column(
            children: [
              PageHeader(title: 'Reminders', subtitle: '$active active schedules', actions: [GlassIconButton(icon: Icons.add_alarm_rounded, onTap: () {})]),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                  children: [
                    Entrance(
                      child: GlassCard(
                        glow: AppColors.sky,
                        tint: LinearGradient(colors: [AppColors.sky.withValues(alpha: 0.22), AppColors.indigo.withValues(alpha: 0.06)]),
                        child: Row(children: [
                          const IconOrb(icon: Icons.water_drop_rounded, gradient: AppColors.aqua, size: 56, iconSize: 26),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Next hydration in', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                              Text('42 min', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                              Text('1.1 L left to reach today\'s goal', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ]),
                          ),
                          Pressable(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(gradient: AppColors.aqua, borderRadius: BorderRadius.circular(14)),
                              child: const Text('+250ml', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const SectionHeader('Scheduled'),
                    ..._items.asMap().entries.map((e) {
                      final r = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Entrance(
                          index: e.key + 1,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: r.enabled ? 1 : 0.5,
                            child: GlassCard(
                              padding: const EdgeInsets.all(14),
                              radius: 22,
                              child: Row(children: [
                                IconOrb(icon: r.icon, gradient: r.gradient, size: 46),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                    const SizedBox(height: 2),
                                    Text(r.subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    Row(children: [
                                      const Icon(Icons.schedule_rounded, size: 13, color: AppColors.cyan),
                                      const SizedBox(width: 4),
                                      Text(r.time, style: const TextStyle(color: AppColors.cyan, fontSize: 12, fontWeight: FontWeight.w700)),
                                    ]),
                                  ]),
                                ),
                                Switch(
                                  value: r.enabled,
                                  activeThumbColor: Colors.white,
                                  activeTrackColor: r.gradient.colors.last,
                                  onChanged: (v) => setState(() => r.enabled = v),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
