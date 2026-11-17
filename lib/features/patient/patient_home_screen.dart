import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';
import '../../widgets/orb3d.dart';
import '../shared/notifications_screen.dart';
import 'add_vitals_screen.dart';
import 'goals_screen.dart';
import 'reminders_screen.dart';
import 'sos_screen.dart';
import 'steps_screen.dart';
import 'vital_detail_screen.dart';

class PatientHomeScreen extends StatelessWidget {
  final ValueChanged<int> onOpenTab;
  const PatientHomeScreen({super.key, required this.onOpenTab});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    void go(Widget w) => Navigator.of(context).push(premiumRoute(w));
    var i = 0;
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
            sliver: SliverList.list(children: [
              // Header
              Entrance(
                index: i++,
                child: Row(
                  children: [
                    const Avatar(initials: 'AM', color: AppColors.cyan, size: 50, ring: true),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$_greeting 👋', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          Text(MockData.patientName, style: t.titleLarge?.copyWith(fontSize: 21)),
                        ],
                      ),
                    ),
                    GlassIconButton(icon: Icons.notifications_none_rounded, badge: 3, onTap: () => go(const NotificationsScreen())),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Hero health score
              Entrance(index: i++, child: _HeroScoreCard(onLog: () => go(const AddVitalsScreen()))),
              const SizedBox(height: 22),

              // Quick actions
              Entrance(
                index: i++,
                child: Row(
                  children: [
                    _QuickAction(icon: Icons.add_chart_rounded, label: 'Log Vitals', gradient: AppColors.brand, onTap: () => go(const AddVitalsScreen())),
                    _QuickAction(icon: Icons.directions_walk_rounded, label: 'Steps', gradient: AppColors.mint, onTap: () => go(const StepsScreen())),
                    _QuickAction(icon: Icons.flag_rounded, label: 'Goals', gradient: AppColors.sunset, onTap: () => go(const GoalsScreen())),
                    _QuickAction(icon: Icons.alarm_rounded, label: 'Reminders', gradient: AppColors.night, onTap: () => go(const RemindersScreen())),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              Entrance(index: i++, child: SectionHeader('Today\'s vitals', action: 'Trends', onAction: () => onOpenTab(1))),
              GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: MockData.vitals.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.76),
                itemBuilder: (context, k) => Entrance(
                  index: i + k,
                  child: VitalCard(vital: MockData.vitals[k], onTap: () => go(VitalDetailScreen(vital: MockData.vitals[k]))),
                ),
              ),
              const SizedBox(height: 22),

              // AI insight
              Entrance(
                index: i + 6,
                child: GlassCard(
                  onTap: () => onOpenTab(2),
                  glow: AppColors.violet,
                  tint: LinearGradient(colors: [AppColors.violet.withValues(alpha: 0.22), AppColors.pink.withValues(alpha: 0.06)]),
                  child: Row(
                    children: [
                      const HoloOrb(size: 74, colors: [AppColors.violet, AppColors.pink], speed: 1.6),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Text('AI INSIGHT', style: TextStyle(fontSize: 10.5, letterSpacing: 1.6, fontWeight: FontWeight.w800, color: AppColors.pink)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                                child: const Text('Mistral‑7B', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700)),
                              ),
                            ]),
                            const SizedBox(height: 6),
                            const Text('Your glucose rose 4% this week. A 15-minute walk after dinner could bring it back to the optimal range.',
                                style: TextStyle(fontSize: 13, height: 1.45)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // SOS
              Entrance(
                index: i + 7,
                child: GlassCard(
                  onTap: () => go(const SosScreen()),
                  glow: AppColors.rose,
                  tint: LinearGradient(colors: [AppColors.rose.withValues(alpha: 0.25), AppColors.rose.withValues(alpha: 0.04)]),
                  child: Row(
                    children: [
                      const PulseRings(size: 74, child: IconOrb(icon: Icons.sos_rounded, gradient: AppColors.danger3, size: 44)),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Emergency SOS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            SizedBox(height: 3),
                            Text('Alert your doctor & share live location instantly', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(gradient: AppColors.danger3, borderRadius: BorderRadius.circular(14)),
                        child: const Text('Open', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),

              Entrance(index: i + 8, child: SectionHeader('Up next', action: 'All', onAction: () => go(const RemindersScreen()))),
              ...MockData.reminders.take(3).toList().asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Entrance(
                      index: i + 9 + e.key,
                      child: GlassCard(
                        padding: const EdgeInsets.all(14),
                        radius: 22,
                        child: Row(
                          children: [
                            IconOrb(icon: e.value.icon, gradient: e.value.gradient, size: 42, iconSize: 20),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(e.value.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text(e.value.subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ]),
                            ),
                            Text(e.value.time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  )),
            ]),
          ),
        ],
      ),
    );
  }
}

class _HeroScoreCard extends StatelessWidget {
  final VoidCallback onLog;
  const _HeroScoreCard({required this.onLog});

  @override
  Widget build(BuildContext context) {
    return Tilt3D(
      maxAngle: 0.14,
      child: GlassCard(
        glow: AppColors.cyan,
        padding: const EdgeInsets.all(20),
        tint: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.indigo.withValues(alpha: 0.35), AppColors.cyan.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.02)],
        ),
        child: Column(
          children: [
            Row(
              children: [
                ActivityRings(
                  size: 140,
                  stroke: 12,
                  rings: const [
                    RingData(0.92, AppColors.brand),
                    RingData(0.84, AppColors.mint),
                    RingData(0.63, AppColors.aqua),
                  ],
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CountUp(92, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 30, height: 1)),
                      const Text('score', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StatusPill(HealthStatus.optimal),
                      const SizedBox(height: 10),
                      Text('Health Score', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      const Text('You\'re in great shape — 5 of 6 vitals are optimal today.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4)),
                      const SizedBox(height: 12),
                      _legend(AppColors.brand, 'Vitals', '92%'),
                      _legend(AppColors.mint, 'Activity', '84%'),
                      _legend(AppColors.aqua, 'Hydration', '63%'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  const BeatingHeart(size: 22),
                  const SizedBox(width: 6),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('72', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1)),
                      Text('bpm · live', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: EcgLine(height: 44)),
                  const SizedBox(width: 8),
                  Pressable(
                    onTap: onLog,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(gradient: AppColors.brand, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(Gradient g, String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(gradient: g, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(k, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      );
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Pressable(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(color: AppColors.stroke),
              ),
              child: IconOrb(icon: icon, gradient: gradient, size: 54, iconSize: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class VitalCard extends StatelessWidget {
  final Vital vital;
  final VoidCallback onTap;
  const VitalCard({super.key, required this.vital, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final up = vital.delta.startsWith('+');
    return Hero(
      tag: 'vital-${vital.key}',
      child: Material(
        type: MaterialType.transparency,
        child: GlassCard(
          onTap: onTap,
          padding: const EdgeInsets.all(16),
          radius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconOrb(icon: vital.icon, gradient: vital.gradient, size: 38, iconSize: 19),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      Icon(up ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(vital.delta, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                    ]),
                  ),
                ],
              ),
              const Spacer(),
              Text(vital.name, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(vital.value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(vital.unit, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                ],
              ),
              const SizedBox(height: 8),
              Sparkline(data: vital.trend, gradient: vital.gradient, height: 30),
              const SizedBox(height: 8),
              StatusPill(vital.status, compact: true),
            ],
          ),
        ),
      ),
    );
  }
}
