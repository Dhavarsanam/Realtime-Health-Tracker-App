import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _items = [
    (Icons.medication_rounded, 'New prescription', 'Dr. Carter prescribed Amlodipine 5 mg once daily.', '5 min', AppColors.night, true),
    (Icons.water_drop_rounded, 'Hydration reminder', 'Time for a glass of water — you\'re 1.1 L behind.', '42 min', AppColors.aqua, true),
    (Icons.insights_rounded, 'Weekly report ready', 'Your health score went up 4 points this week.', '2 h', AppColors.brand, true),
    (Icons.warning_amber_rounded, 'Glucose above range', '108 mg/dL logged this morning. Tap for tips.', 'Yesterday', AppColors.sunset, false),
    (Icons.event_available_rounded, 'Appointment confirmed', 'Video consult Friday, 10:30 AM.', 'Mon', AppColors.mint, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Column(children: [
            PageHeader(title: 'Notifications', subtitle: '3 unread', actions: [GlassIconButton(icon: Icons.done_all_rounded, onTap: () {})]),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final n = _items[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Entrance(
                      index: i,
                      child: Dismissible(
                        key: ValueKey(n.$2),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(color: AppColors.rose.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(22)),
                          child: const Icon(Icons.delete_outline_rounded, color: AppColors.rose),
                        ),
                        child: GlassCard(
                          radius: 22,
                          padding: const EdgeInsets.all(14),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            IconOrb(icon: n.$1, gradient: n.$5, size: 44),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Expanded(child: Text(n.$2, style: const TextStyle(fontWeight: FontWeight.w700))),
                                  Text(n.$4, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                ]),
                                const SizedBox(height: 4),
                                Text(n.$3, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4)),
                              ]),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 6),
                              decoration: BoxDecoration(color: n.$6 ? AppColors.cyan : Colors.transparent, shape: BoxShape.circle),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
