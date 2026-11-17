import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';
import '../../widgets/orb3d.dart';
import '../shared/notifications_screen.dart';
import 'patient_detail_screen.dart';
import 'prescribe_screen.dart';

class DoctorDashboardScreen extends StatelessWidget {
  final ValueChanged<int> onOpenTab;
  const DoctorDashboardScreen({super.key, required this.onOpenTab});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final patients = MockData.patients;
    final critical = patients.where((p) => p.status == HealthStatus.critical).length;
    final warning = patients.where((p) => p.status == HealthStatus.warning).length;
    void go(Widget w) => Navigator.of(context).push(premiumRoute(w));
    final activeSos = MockData.sosAlerts.firstWhere((a) => a.active);

    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
        children: [
          Entrance(
            child: Row(children: [
              const Avatar(initials: 'SC', color: AppColors.teal, size: 50, ring: true, online: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Clinician workspace', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text(MockData.doctorName, style: t.titleLarge?.copyWith(fontSize: 21)),
                ]),
              ),
              GlassIconButton(icon: Icons.notifications_none_rounded, badge: 2, onTap: () => go(const NotificationsScreen())),
            ]),
          ),
          const SizedBox(height: 20),

          // Live SOS banner
          Entrance(
            index: 1,
            child: GlassCard(
              onTap: () => onOpenTab(2),
              glow: AppColors.rose,
              tint: LinearGradient(colors: [AppColors.rose.withValues(alpha: 0.32), AppColors.rose.withValues(alpha: 0.05)]),
              child: Row(children: [
                const PulseRings(size: 66, child: IconOrb(icon: Icons.sos_rounded, gradient: AppColors.danger3, size: 42)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Text('LIVE SOS', style: TextStyle(fontSize: 10.5, letterSpacing: 1.6, fontWeight: FontWeight.w900, color: AppColors.rose)),
                      const SizedBox(width: 8),
                      Flexible(child: Text(activeSos.time, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                    ]),
                    const SizedBox(height: 2),
                    Text(activeSos.patient.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    Text(activeSos.reason, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ]),
                ),
                const Icon(Icons.chevron_right_rounded),
              ]),
            ),
          ),
          const SizedBox(height: 18),

          // KPI
          Entrance(
            index: 2,
            child: Row(children: [
              Expanded(child: _kpi(Icons.people_alt_rounded, patients.length.toDouble(), 'Patients', AppColors.doctor)),
              const SizedBox(width: 12),
              Expanded(child: _kpi(Icons.warning_amber_rounded, critical.toDouble(), 'Critical', AppColors.danger3)),
              const SizedBox(width: 12),
              Expanded(child: _kpi(Icons.error_outline_rounded, warning.toDouble(), 'Attention', AppColors.sunset)),
            ]),
          ),
          const SizedBox(height: 18),

          // Population health chart
          Entrance(
            index: 3,
            child: Tilt3D(
              maxAngle: 0.08,
              child: GlassCard(
                glow: AppColors.teal,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Panel health index', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        Text('Average score across your patients', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ]),
                    ),
                    GradientText('72', gradient: AppColors.doctor, style: t.headlineMedium),
                  ]),
                  const SizedBox(height: 16),
                  const SmoothLineChart(
                    data: [64, 66, 63, 69, 71, 70, 72],
                    labels: MockData.weekDays,
                    gradient: AppColors.doctor,
                    height: 180,
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Entrance(
            index: 4,
            child: Row(children: [
              Expanded(child: _action(Icons.medication_liquid_rounded, 'New Rx', 'FDA drug data', AppColors.night, () => go(const PrescribeScreen()))),
              const SizedBox(width: 12),
              Expanded(child: _action(Icons.video_call_rounded, 'Consult', '3 scheduled', AppColors.mint, () {})),
            ]),
          ),
          const SizedBox(height: 22),

          Entrance(index: 5, child: SectionHeader('Needs attention', action: 'All patients', onAction: () => onOpenTab(1))),
          ...(List.of(patients)..sort((a, b) => a.score.compareTo(b.score))).take(3).toList().asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Entrance(index: 6 + e.key, child: PatientTile(patient: e.value, onTap: () => go(PatientDetailScreen(patient: e.value)))),
              )),
        ],
      ),
    );
  }

  Widget _kpi(IconData i, double v, String k, Gradient g) => GlassCard(
        radius: 22,
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconOrb(icon: i, gradient: g, size: 36, iconSize: 18),
          const SizedBox(height: 12),
          CountUp(v, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          Text(k, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ]),
      );

  Widget _action(IconData i, String t, String s, Gradient g, VoidCallback f) => GlassCard(
        onTap: f,
        radius: 22,
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          IconOrb(icon: i, gradient: g, size: 42),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(s, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
            ]),
          ),
        ]),
      );
}

class PatientTile extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;
  const PatientTile({super.key, required this.patient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = patient;
    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(children: [
        Row(children: [
          Hero(tag: 'pt-${p.id}', child: Avatar(initials: p.initials, color: p.avatarColor, size: 50)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text('${p.age}${p.gender} · ${p.condition}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
          ),
          StatusPill(p.status, compact: true),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _m(Icons.favorite_rounded, '${p.heartRate}', 'bpm', AppColors.rose, 4),
          const SizedBox(width: 6),
          _m(Icons.bloodtype_rounded, p.bp, 'mmHg', AppColors.violet, 5),
          const SizedBox(width: 6),
          _m(Icons.water_drop_rounded, '${p.glucose}', 'mg/dL', AppColors.amber, 4),
        ]),
      ]),
    );
  }

  Widget _m(IconData i, String v, String u, Color c, int flex) => Expanded(
        flex: flex,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Icon(i, size: 14, color: c),
            const SizedBox(width: 5),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(TextSpan(children: [
                  TextSpan(text: v, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  TextSpan(text: ' $u', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ])),
              ),
            ),
          ]),
        ),
      );
}
