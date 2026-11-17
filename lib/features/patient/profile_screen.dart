import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';
import '../auth/role_select_screen.dart';
import 'goals_screen.dart';
import 'reminders_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool doctor;
  const ProfileScreen({super.key, this.doctor = false});

  @override
  Widget build(BuildContext context) {
    final g = doctor ? AppColors.doctor : AppColors.brand;
    final name = doctor ? MockData.doctorName : MockData.patientName;
    void go(Widget w) => Navigator.of(context).push(premiumRoute(w));
    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
        children: [
          Entrance(
            child: Tilt3D(
              child: GlassCard(
                glow: g.colors.first,
                padding: const EdgeInsets.all(22),
                tint: LinearGradient(colors: [g.colors.first.withValues(alpha: 0.25), g.colors.last.withValues(alpha: 0.08)]),
                child: Column(children: [
                  Avatar(initials: doctor ? 'SC' : 'AM', color: g.colors.first, size: 92, ring: true, online: true),
                  const SizedBox(height: 14),
                  Text(name, style: Theme.of(context).textTheme.headlineSmall),
                  Text(doctor ? 'Cardiologist · MD, FACC' : 'Patient ID · P-1024', style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 18),
                  Row(
                    children: doctor
                        ? [_stat('128', 'Patients'), _div(), _stat('4.9', 'Rating'), _div(), _stat('12y', 'Experience')]
                        : [_stat('34', 'Age'), _div(), _stat('72kg', 'Weight'), _div(), _stat('O+', 'Blood')],
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Entrance(index: 1, child: SectionHeader(doctor ? 'Workspace' : 'Health & app')),
          if (!doctor) ...[
            Entrance(index: 2, child: _tile(Icons.flag_rounded, 'Health goals', AppColors.sunset, () => go(const GoalsScreen()))),
            Entrance(index: 3, child: _tile(Icons.alarm_rounded, 'Reminders', AppColors.night, () => go(const RemindersScreen()))),
            Entrance(index: 4, child: _tile(Icons.description_rounded, 'Medical records', AppColors.aqua, () {})),
          ] else ...[
            Entrance(index: 2, child: _tile(Icons.calendar_month_rounded, 'Availability', AppColors.mint, () {})),
            Entrance(index: 3, child: _tile(Icons.receipt_long_rounded, 'Prescription history', AppColors.night, () {})),
          ],
          Entrance(index: 5, child: _tile(Icons.storage_rounded, 'Local data & backup', AppColors.brand, () {}, trailing: 'SQLite')),
          Entrance(index: 6, child: _tile(Icons.shield_rounded, 'Privacy & security', AppColors.mint, () {})),
          Entrance(index: 7, child: _tile(Icons.notifications_rounded, 'Notifications', AppColors.sunset, () {})),
          const SizedBox(height: 12),
          Entrance(
            index: 8,
            child: _tile(Icons.logout_rounded, 'Sign out', AppColors.danger3, () {
              Navigator.of(context).pushAndRemoveUntil(premiumRoute(const RoleSelectScreen()), (_) => false);
            }),
          ),
        ],
      ),
    );
  }

  Widget _stat(String v, String k) => Expanded(
        child: Column(children: [
          Text(v, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          Text(k, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
        ]),
      );

  Widget _div() => Container(width: 1, height: 30, color: AppColors.stroke);

  Widget _tile(IconData i, String t, Gradient g, VoidCallback onTap, {String? trailing}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassCard(
          radius: 20,
          padding: const EdgeInsets.all(12),
          onTap: onTap,
          child: Row(children: [
            IconOrb(icon: i, gradient: g, size: 40, iconSize: 19),
            const SizedBox(width: 14),
            Expanded(child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
            if (trailing != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(8)),
                child: Text(trailing, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ]),
        ),
      );
}
