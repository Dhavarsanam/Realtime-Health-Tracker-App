import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';
import '../../widgets/orb3d.dart';
import 'patient_detail_screen.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final _acknowledged = <String>{};

  @override
  Widget build(BuildContext context) {
    final alerts = MockData.sosAlerts;
    final live = alerts.where((a) => a.active && !_acknowledged.contains(a.patient.id)).length;
    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
        children: [
          Entrance(child: Text('SOS alerts', style: Theme.of(context).textTheme.headlineMedium)),
          Entrance(index: 1, child: Text('$live active · responses are logged', style: const TextStyle(color: AppColors.textSecondary))),
          const SizedBox(height: 20),
          if (live > 0)
            Entrance(
              index: 2,
              child: Center(
                child: PulseRings(
                  size: 200,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.danger3,
                      boxShadow: [BoxShadow(color: AppColors.rose.withValues(alpha: 0.6), blurRadius: 40)],
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('$live', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                      const Text('LIVE', style: TextStyle(fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          ...alerts.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Entrance(index: 3 + e.key, child: _card(e.value)),
              )),
        ],
      ),
    );
  }

  Widget _card(SosAlert a) {
    final active = a.active && !_acknowledged.contains(a.patient.id);
    final c = active ? AppColors.rose : AppColors.textMuted;
    return GlassCard(
      glow: active ? AppColors.rose : null,
      tint: active ? LinearGradient(colors: [AppColors.rose.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.02)]) : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Avatar(initials: a.patient.initials, color: a.patient.avatarColor, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.patient.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              Text(a.time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Text(active ? 'ACTIVE' : 'RESOLVED', style: TextStyle(color: c, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ),
        ]),
        const SizedBox(height: 14),
        _row(Icons.monitor_heart_rounded, a.reason, AppColors.rose),
        const SizedBox(height: 8),
        _row(Icons.location_on_rounded, a.location, AppColors.sky),
        if (active) ...[
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: GradientButton(
                label: 'Respond',
                icon: Icons.call_rounded,
                height: 48,
                gradient: AppColors.danger3,
                onTap: () => setState(() => _acknowledged.add(a.patient.id)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GradientButton(
                label: 'View',
                height: 48,
                gradient: AppColors.doctor,
                onTap: () => Navigator.of(context).push(premiumRoute(PatientDetailScreen(patient: a.patient))),
              ),
            ),
          ]),
        ],
      ]),
    );
  }

  Widget _row(IconData i, String t, Color c) => Row(children: [
        Icon(i, size: 16, color: c),
        const SizedBox(width: 8),
        Expanded(child: Text(t, style: const TextStyle(fontSize: 13))),
      ]);
}
