import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';
import 'login_screen.dart';

enum UserRole { patient, doctor }

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  UserRole _role = UserRole.patient;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Entrance(child: Text('Welcome to', style: t.titleMedium?.copyWith(color: AppColors.textSecondary))),
                Entrance(index: 1, child: GradientText('VitalSync', style: t.displaySmall?.copyWith(fontSize: 42))),
                const SizedBox(height: 10),
                Entrance(
                  index: 2,
                  child: Text('Choose how you\'d like to continue. You can switch roles anytime from settings.',
                      style: t.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.5)),
                ),
                const SizedBox(height: 36),
                Entrance(
                  index: 3,
                  child: _RoleCard(
                    selected: _role == UserRole.patient,
                    title: 'I\'m a Patient',
                    subtitle: 'Track vitals, chat with AI & your doctor, set goals and get reminders.',
                    icon: Icons.person_rounded,
                    gradient: AppColors.brand,
                    features: const ['Vitals', 'AI Coach', 'SOS'],
                    onTap: () => setState(() => _role = UserRole.patient),
                  ),
                ),
                const SizedBox(height: 18),
                Entrance(
                  index: 4,
                  child: _RoleCard(
                    selected: _role == UserRole.doctor,
                    title: 'I\'m a Doctor',
                    subtitle: 'Monitor patients, prescribe with FDA drug data and respond to SOS alerts.',
                    icon: Icons.medical_services_rounded,
                    gradient: AppColors.doctor,
                    features: const ['Patients', 'Rx', 'Alerts'],
                    onTap: () => setState(() => _role = UserRole.doctor),
                  ),
                ),
                const SizedBox(height: 36),
                Entrance(
                  index: 5,
                  child: GradientButton(
                    label: 'Continue as ${_role == UserRole.patient ? 'Patient' : 'Doctor'}',
                    icon: Icons.arrow_forward_rounded,
                    gradient: _role == UserRole.patient ? AppColors.brand : AppColors.doctor,
                    onTap: () => Navigator.of(context).push(premiumRoute(LoginScreen(role: _role))),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final List<String> features;
  final VoidCallback onTap;
  const _RoleCard({required this.selected, required this.title, required this.subtitle, required this.icon, required this.gradient, required this.features, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(1.6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: selected ? gradient : null,
        boxShadow: selected ? [BoxShadow(color: gradient.colors.first.withValues(alpha: 0.35), blurRadius: 30, offset: const Offset(0, 12))] : null,
      ),
      child: Tilt3D(
        maxAngle: 0.12,
        idleFloat: false,
        child: GlassCard(
          radius: 26.5,
          onTap: onTap,
          padding: const EdgeInsets.all(20),
          tint: selected
              ? LinearGradient(colors: [gradient.colors.first.withValues(alpha: 0.18), AppColors.bgElevated.withValues(alpha: 0.6)])
              : null,
          child: Row(
            children: [
              IconOrb(icon: icon, gradient: gradient, size: 60, iconSize: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      children: features
                          .map((f) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(20)),
                                child: Text(f, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                child: selected
                    ? Container(
                        key: const ValueKey(1),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(gradient: gradient, shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                      )
                    : Container(
                        key: const ValueKey(0),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.textMuted, width: 1.5)),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
