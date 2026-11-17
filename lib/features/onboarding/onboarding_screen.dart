import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';
import '../../widgets/orb3d.dart';
import '../auth/role_select_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  double _page = 0;

  static const _pages = [
    ('Track every vital,\nin real time', 'Log blood pressure, heart rate, glucose, sleep, water and calories — analyzed instantly against clinical ranges.', [AppColors.cyan, AppColors.violet]),
    ('AI insights powered\nby Mistral‑7B', 'Ask anything about your health. Get personalized, context-aware guidance in seconds.', [AppColors.violet, AppColors.pink]),
    ('Your doctor,\nalways one tap away', 'Secure chat, e-prescriptions with FDA drug data, and instant SOS alerts when it matters most.', [AppColors.teal, AppColors.sky]),
  ];

  @override
  void initState() {
    super.initState();
    _pc.addListener(() => setState(() => _page = _pc.page ?? 0));
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _next() {
    if (_page.round() < _pages.length - 1) {
      _pc.nextPage(duration: const Duration(milliseconds: 650), curve: Curves.easeOutQuart);
    } else {
      Navigator.of(context).pushReplacement(premiumRoute(const RoleSelectScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final idx = _page.round();
    return Scaffold(
      body: AuroraBackground(
        colors: [_pages[idx].$3[0], _pages[idx].$3[1], AppColors.indigo],
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
                child: Row(
                  children: [
                    const IconOrb(icon: Icons.monitor_heart_rounded, gradient: AppColors.brand, size: 36, iconSize: 18),
                    const SizedBox(width: 10),
                    Text('VitalSync', style: t.titleMedium),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacement(premiumRoute(const RoleSelectScreen())),
                      child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pc,
                  itemCount: _pages.length,
                  itemBuilder: (context, i) {
                    final delta = (i - _page);
                    final m = Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(delta * 0.9);
                    return Opacity(
                      opacity: (1 - delta.abs()).clamp(0, 1),
                      child: Column(
                        children: [
                          Expanded(
                            child: Transform(
                              alignment: delta > 0 ? Alignment.centerLeft : Alignment.centerRight,
                              transform: m,
                              child: Center(child: _visual(i)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Transform.translate(
                              offset: Offset(delta * 120, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_pages[i].$1, style: t.displaySmall?.copyWith(fontSize: 34, height: 1.1)),
                                  const SizedBox(height: 14),
                                  Text(_pages[i].$2, style: t.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.5)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Row(
                  children: [
                    Row(
                      children: List.generate(_pages.length, (i) {
                        final active = (1 - (i - _page).abs()).clamp(0.0, 1.0);
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 8 + 24 * active,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: active > 0.5 ? AppColors.brand : null,
                            color: active > 0.5 ? null : Colors.white.withValues(alpha: 0.2),
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: idx == _pages.length - 1 ? 180 : 150,
                      child: GradientButton(
                        label: idx == _pages.length - 1 ? 'Get started' : 'Next',
                        icon: Icons.arrow_forward_rounded,
                        onTap: _next,
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

  Widget _visual(int i) {
    switch (i) {
      case 0:
        return SizedBox(
          width: 340,
          height: 340,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const HoloOrb(size: 300, child: BeatingHeart(size: 46)),
              _FloatChip(alignment: const Alignment(-0.95, -0.7), phase: 0, icon: Icons.favorite_rounded, gradient: AppColors.heart, text: '72 bpm'),
              _FloatChip(alignment: const Alignment(0.95, -0.35), phase: 1.4, icon: Icons.bloodtype_rounded, gradient: AppColors.night, text: '118/76'),
              _FloatChip(alignment: const Alignment(-0.85, 0.8), phase: 2.6, icon: Icons.water_drop_rounded, gradient: AppColors.sunset, text: '98 mg/dL'),
              _FloatChip(alignment: const Alignment(0.9, 0.75), phase: 3.8, icon: Icons.bedtime_rounded, gradient: AppColors.brand, text: '7.4 h'),
            ],
          ),
        );
      case 1:
        return SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HoloOrb(size: 170, colors: [AppColors.violet, AppColors.pink], child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 38)),
              const SizedBox(height: 12),
              _bubble('Is 108 mg/dL fasting glucose normal?', true),
              const SizedBox(height: 10),
              _bubble('It\'s slightly above the optimal range (70–99). Try reducing refined carbs and a 15‑min walk after meals.', false),
            ],
          ),
        );
      default:
        return SizedBox(
          width: 320,
          child: Tilt3D(
            child: GlassCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    children: [
                      Avatar(initials: 'SC', color: AppColors.teal, size: 52, online: true, ring: true),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dr. Sophia Carter', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            Text('Cardiologist · Online', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconOrb(icon: Icons.videocam_rounded, gradient: AppColors.doctor, size: 40, iconSize: 20),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const EcgLine(color: AppColors.teal, height: 56),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: _miniStat('Rx', 'Amlodipine', Icons.medication_rounded, AppColors.night)),
                      const SizedBox(width: 10),
                      Expanded(child: _miniStat('SOS', 'Ready', Icons.sos_rounded, AppColors.danger3)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  Widget _miniStat(String k, String v, IconData icon, Gradient g) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            IconOrb(icon: icon, gradient: g, size: 32, iconSize: 16),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(k, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Text(v, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ]),
          ],
        ),
      );

  Widget _bubble(String text, bool mine) => Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 260),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: mine ? AppColors.brand : null,
            color: mine ? null : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(mine ? 20 : 6),
              bottomRight: Radius.circular(mine ? 6 : 20),
            ),
            border: mine ? null : Border.all(color: AppColors.stroke),
          ),
          child: Text(text, style: const TextStyle(fontSize: 13.5, height: 1.45)),
        ),
      );
}

class _FloatChip extends StatefulWidget {
  final Alignment alignment;
  final double phase;
  final IconData icon;
  final Gradient gradient;
  final String text;
  const _FloatChip({required this.alignment, required this.phase, required this.icon, required this.gradient, required this.text});

  @override
  State<_FloatChip> createState() => _FloatChipState();
}

class _FloatChipState extends State<_FloatChip> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, math.sin(_c.value * 2 * math.pi + widget.phase) * 8),
          child: child,
        ),
        child: GlassCard(
          radius: 18,
          padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconOrb(icon: widget.icon, gradient: widget.gradient, size: 30, iconSize: 15),
              const SizedBox(width: 8),
              Text(widget.text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
