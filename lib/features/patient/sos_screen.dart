import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';
import '../../widgets/orb3d.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _hold = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _hold.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        setState(() => _sent = true);
      }
    });
  }

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        colors: const [AppColors.rose, Color(0xFF9F1239), AppColors.orange],
        child: SafeArea(
          child: Column(
            children: [
              const PageHeader(title: 'Emergency SOS', subtitle: 'Hold the button for 2 seconds'),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: c)),
                child: _sent ? _sentView() : _holdButton(),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(children: [
                  _contact(Icons.medical_services_rounded, 'Dr. Sophia Carter', 'Primary physician', AppColors.doctor),
                  const SizedBox(height: 12),
                  _contact(Icons.family_restroom_rounded, 'Riya Mehta', 'Emergency contact · Sister', AppColors.night),
                  const SizedBox(height: 12),
                  _contact(Icons.location_on_rounded, 'Live location', '5th Ave, New York · shared on alert', AppColors.danger3),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _holdButton() {
    return GestureDetector(
      key: const ValueKey('hold'),
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
        _hold.forward();
      },
      onTapUp: (_) {
        if (!_sent) _hold.reverse();
      },
      onTapCancel: () {
        if (!_sent) _hold.reverse();
      },
      child: AnimatedBuilder(
        animation: _hold,
        builder: (context, _) => PulseRings(
          size: 300,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: _hold.value,
                strokeWidth: 6,
                color: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                strokeCap: StrokeCap.round,
              ),
            ),
            Transform.scale(
              scale: 1 - _hold.value * 0.08,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(center: Alignment(-0.3, -0.4), colors: [Color(0xFFFF8FA3), AppColors.rose, Color(0xFF881337)], stops: [0, 0.5, 1]),
                  boxShadow: [
                    BoxShadow(color: AppColors.rose.withValues(alpha: 0.6), blurRadius: 50, spreadRadius: 4),
                    const BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 16)),
                  ],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('SOS', style: TextStyle(fontSize: 46, fontWeight: FontWeight.w900, letterSpacing: 4)),
                  Text(_hold.value > 0 ? 'Keep holding…' : 'Hold to alert', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _sentView() {
    return Column(
      key: const ValueKey('sent'),
      children: [
        const PulseRings(
          size: 240,
          color: AppColors.emerald,
          child: IconOrb(icon: Icons.check_rounded, gradient: AppColors.mint, size: 110, iconSize: 56),
        ),
        const SizedBox(height: 10),
        Text('Help is on the way', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        const Text('Your doctor and emergency contacts were alerted\nwith your live location and latest vitals.',
            textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
            _hold.reset();
            setState(() => _sent = false);
          },
          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
          label: const Text('Cancel alert', style: TextStyle(color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _contact(IconData i, String t, String s, Gradient g) => GlassCard(
        radius: 20,
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          IconOrb(icon: i, gradient: g, size: 40, iconSize: 19),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(s, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 20),
        ]),
      );
}
