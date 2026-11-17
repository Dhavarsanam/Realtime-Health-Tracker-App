import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/common.dart';
import '../../widgets/orb3d.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..forward();

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(premiumRoute(const OnboardingScreen()));
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final orbIn = Curves.easeOutBack.transform((_c.value / 0.45).clamp(0, 1));
              final textIn = Curves.easeOutCubic.transform(((_c.value - 0.3) / 0.4).clamp(0, 1));
              return Column(
                children: [
                  const Spacer(flex: 3),
                  Transform.scale(
                    scale: 0.4 + orbIn * 0.6,
                    child: Opacity(
                      opacity: orbIn.clamp(0, 1),
                      child: const HoloOrb(size: 280, child: BeatingHeart(size: 54, bpm: 66)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Opacity(
                    opacity: textIn,
                    child: Transform.translate(
                      offset: Offset(0, 24 * (1 - textIn)),
                      child: Column(
                        children: [
                          GradientText('VitalSync', style: t.displayMedium?.copyWith(fontSize: 46)),
                          const SizedBox(height: 8),
                          Text('REMOTE HEALTH · MONITORING · CARE',
                              style: t.labelSmall?.copyWith(color: AppColors.textSecondary, letterSpacing: 3, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  Opacity(
                    opacity: textIn,
                    child: Container(
                      width: 160,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4)),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _c.value,
                        child: Container(decoration: BoxDecoration(gradient: AppColors.brand, borderRadius: BorderRadius.circular(4))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Opacity(
                    opacity: textIn * 0.7,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_rounded, size: 13, color: AppColors.textMuted),
                        SizedBox(width: 6),
                        Text('End-to-end private · data stays on device', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
