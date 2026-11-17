import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';
import '../../widgets/orb3d.dart';
import '../chat/chat_room_screen.dart';
import 'prescribe_screen.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final p = patient;
    final g = LinearGradient(colors: [p.avatarColor, Color.lerp(p.avatarColor, AppColors.indigo, 0.6)!]);
    void go(Widget w) => Navigator.of(context).push(premiumRoute(w));
    final hrTrend = List<double>.generate(7, (i) => p.heartRate + const [-6.0, 3.0, -2.0, 5.0, -4.0, 2.0, 0.0][i]);
    final glTrend = List<double>.generate(7, (i) => p.glucose + const [-12.0, 8.0, -4.0, 14.0, -6.0, 4.0, 0.0][i]);
    return Scaffold(
      body: AuroraBackground(
        colors: [p.avatarColor, AppColors.indigo, AppColors.teal],
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              PageHeader(title: 'Patient overview', subtitle: p.id, actions: [GlassIconButton(icon: Icons.more_horiz_rounded, onTap: () {})]),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  Entrance(
                    child: Tilt3D(
                      child: GlassCard(
                        glow: p.status.color,
                        padding: const EdgeInsets.all(20),
                        child: Column(children: [
                          Row(children: [
                            Hero(tag: 'pt-${p.id}', child: Avatar(initials: p.initials, color: p.avatarColor, size: 66, ring: true)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(p.name, style: Theme.of(context).textTheme.titleLarge),
                                Text('${p.age} yrs · ${p.gender == 'M' ? 'Male' : 'Female'}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                                const SizedBox(height: 6),
                                StatusPill(p.status, compact: true),
                              ]),
                            ),
                            ActivityRings(
                              size: 74,
                              stroke: 7,
                              rings: [RingData(p.score / 100, LinearGradient(colors: [p.status.color, AppColors.violet]))],
                              center: Text('${p.score}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(16)),
                            child: Row(children: [
                              BeatingHeart(size: 20, bpm: p.heartRate),
                              const SizedBox(width: 6),
                              Text('${p.heartRate}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                              const Text(' bpm', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              const SizedBox(width: 10),
                              Expanded(child: EcgLine(height: 38, color: p.status.color, speed: p.heartRate / 72)),
                            ]),
                          ),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Entrance(
                    index: 1,
                    child: Row(children: [
                      Expanded(child: _vital(Icons.bloodtype_rounded, p.bp, 'mmHg', AppColors.night)),
                      const SizedBox(width: 12),
                      Expanded(child: _vital(Icons.water_drop_rounded, '${p.glucose}', 'mg/dL', AppColors.sunset)),
                      const SizedBox(width: 12),
                      Expanded(child: _vital(Icons.monitor_heart_rounded, p.condition, 'condition', g)),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Entrance(
                    index: 2,
                    child: GlassCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Heart rate · 7 days', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        SmoothLineChart(data: hrTrend, labels: MockData.weekDays, gradient: AppColors.heart, height: 160),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Entrance(
                    index: 3,
                    child: GlassCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Glucose · 7 days', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        GlowBarChart(data: glTrend, labels: MockData.weekDays, gradient: AppColors.sunset, height: 140, highlight: 6),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Entrance(
                    index: 4,
                    child: GlassCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Active medications', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        for (final d in MockData.drugs.take(2))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(children: [
                              const IconOrb(icon: Icons.medication_rounded, gradient: AppColors.night, size: 36, iconSize: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('${d.brand} (${d.generic.split(' ').first})', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text(d.dosage, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                ]),
                              ),
                            ]),
                          ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Entrance(
                    index: 5,
                    child: Row(children: [
                      Expanded(
                        child: GradientButton(
                          label: 'Message',
                          icon: Icons.chat_rounded,
                          gradient: AppColors.brand,
                          onTap: () => go(ChatRoomScreen(
                            doctor: true,
                            conversation: Conversation(name: p.name, role: p.condition, lastMessage: '', time: '', unread: 0, online: true, color: p.avatarColor),
                          )),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: GradientButton(label: 'Prescribe', icon: Icons.medication_rounded, gradient: AppColors.doctor, onTap: () => go(PrescribeScreen(patient: p)))),
                    ]),
                  ),
                  const SizedBox(height: 30),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vital(IconData i, String v, String u, Gradient g) => GlassCard(
        radius: 20,
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconOrb(icon: i, gradient: g, size: 32, iconSize: 16),
          const SizedBox(height: 10),
          FittedBox(fit: BoxFit.scaleDown, child: Text(v, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17))),
          Text(u, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ]),
      );
}
