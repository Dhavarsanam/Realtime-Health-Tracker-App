import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';
import '../../widgets/orb3d.dart';
import '../doctor/doctor_shell.dart';
import '../patient/patient_shell.dart';
import 'role_select_screen.dart';

class LoginScreen extends StatefulWidget {
  final UserRole role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _signup = false;
  bool _obscure = true;
  bool _loading = false;

  bool get _isDoctor => widget.role == UserRole.doctor;
  Gradient get _g => _isDoctor ? AppColors.doctor : AppColors.brand;

  Future<void> _submit() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      premiumRoute(_isDoctor ? const DoctorShell() : const PatientShell()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AuroraBackground(
        colors: _isDoctor ? const [AppColors.teal, AppColors.sky, AppColors.indigo] : const [AppColors.violet, AppColors.cyan, AppColors.pink],
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                GlassIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.of(context).pop()),
                Center(
                  child: HoloOrb(
                    size: 190,
                    colors: _isDoctor ? const [AppColors.teal, AppColors.sky] : const [AppColors.cyan, AppColors.violet],
                    child: Icon(_isDoctor ? Icons.medical_services_rounded : Icons.favorite_rounded, color: Colors.white, size: 34),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Column(
                    key: ValueKey(_signup),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_signup ? 'Create account' : 'Welcome back', style: t.headlineLarge),
                      const SizedBox(height: 6),
                      Text(
                        _isDoctor ? 'Sign in to your clinician workspace' : 'Sign in to continue your health journey',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      AnimatedSize(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        child: _signup
                            ? const Padding(
                                padding: EdgeInsets.only(bottom: 14),
                                child: TextField(decoration: InputDecoration(hintText: 'Full name', prefixIcon: Icon(Icons.person_outline_rounded))),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: _isDoctor ? 'Medical ID or email' : 'Email address',
                          prefixIcon: const Icon(Icons.alternate_email_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: const Text('Forgot password?', style: TextStyle(color: AppColors.cyan)),
                        ),
                      ),
                      GradientButton(label: _signup ? 'Create account' : 'Sign in', gradient: _g, loading: _loading, onTap: _submit),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(children: [
                  Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or continue with', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
                  Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                ]),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: _social(Icons.fingerprint_rounded, 'Biometric')),
                    const SizedBox(width: 12),
                    Expanded(child: _social(Icons.face_retouching_natural_rounded, 'Face ID')),
                  ],
                ),
                const SizedBox(height: 22),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _signup = !_signup),
                    child: Text.rich(TextSpan(children: [
                      TextSpan(text: _signup ? 'Already have an account? ' : 'New here? ', style: const TextStyle(color: AppColors.textSecondary)),
                      TextSpan(text: _signup ? 'Sign in' : 'Create account', style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w700)),
                    ])),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _social(IconData icon, String label) => GlassCard(
        radius: 18,
        padding: const EdgeInsets.symmetric(vertical: 14),
        onTap: _submit,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: AppColors.cyan),
            const SizedBox(width: 8),
            Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      );
}
