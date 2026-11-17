import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/mock/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';

/// E-prescription composer. Drug search uses sample data that mirrors the
/// openFDA drug label fields; wire `_search` to the FDA API later.
class PrescribeScreen extends StatefulWidget {
  final Patient? patient;
  const PrescribeScreen({super.key, this.patient});

  @override
  State<PrescribeScreen> createState() => _PrescribeScreenState();
}

class _PrescribeScreenState extends State<PrescribeScreen> {
  String _q = '';
  bool _searching = false;
  Drug? _selected;
  int _freq = 0;
  int _days = 14;

  late Patient _patient = widget.patient ?? MockData.patients.first;

  List<Drug> get _results => MockData.drugs
      .where((d) => _q.isEmpty || d.brand.toLowerCase().contains(_q.toLowerCase()) || d.generic.toLowerCase().contains(_q.toLowerCase()))
      .toList();

  Future<void> _search(String v) async {
    setState(() {
      _q = v;
      _searching = true;
    });
    await Future.delayed(const Duration(milliseconds: 450));
    if (mounted) setState(() => _searching = false);
  }

  void _send() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (context, v, child) => Transform.scale(scale: v, child: child),
              child: const IconOrb(icon: Icons.check_rounded, gradient: AppColors.mint, size: 80, iconSize: 42),
            ),
            const SizedBox(height: 18),
            Text('Prescription sent', style: Theme.of(ctx).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text('${_selected!.brand} was sent to ${_patient.name}\'s app and pharmacy.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Done',
              gradient: AppColors.doctor,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        colors: const [AppColors.violet, AppColors.teal, AppColors.indigo],
        child: SafeArea(
          child: Column(children: [
            const PageHeader(title: 'New prescription', subtitle: 'Powered by openFDA drug labels'),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                children: [
                  Entrance(
                    child: GlassCard(
                      radius: 22,
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Avatar(initials: _patient.initials, color: _patient.avatarColor, size: 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Patient', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                            Text(_patient.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          ]),
                        ),
                        PopupMenuButton<Patient>(
                          color: AppColors.surface,
                          icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.cyan),
                          onSelected: (p) => setState(() => _patient = p),
                          itemBuilder: (_) => MockData.patients.map((p) => PopupMenuItem(value: p, child: Text(p.name))).toList(),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Entrance(
                    index: 1,
                    child: TextField(
                      onChanged: _search,
                      decoration: InputDecoration(
                        hintText: 'Search drug by brand or generic name',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searching
                            ? const Padding(padding: EdgeInsets.all(14), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                            : const Icon(Icons.qr_code_scanner_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ..._results.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Entrance(index: 2 + e.key, child: _drugCard(e.value)),
                      )),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    child: _selected == null ? const SizedBox(width: double.infinity) : _dosage(),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _drugCard(Drug d) {
    final sel = _selected == d;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: sel ? AppColors.doctor : null),
      child: GlassCard(
        radius: 22.5,
        padding: const EdgeInsets.all(14),
        onTap: () => setState(() => _selected = sel ? null : d),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const IconOrb(icon: Icons.medication_rounded, gradient: AppColors.night, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d.brand, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                Text(d.generic, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.sky.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(d.route, style: const TextStyle(color: AppColors.sky, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            child: !sel
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _kv('Indication', d.purpose),
                      _kv('Manufacturer', d.manufacturer),
                      _kv('Standard dose', d.dosage),
                      const SizedBox(height: 6),
                      const Text('WARNINGS', style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: d.warnings
                            .map((w) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.amber.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.amber.withValues(alpha: 0.35)),
                                  ),
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    const Icon(Icons.warning_amber_rounded, size: 13, color: AppColors.amber),
                                    const SizedBox(width: 4),
                                    Text(w, style: const TextStyle(fontSize: 11.5, color: AppColors.amber, fontWeight: FontWeight.w600)),
                                  ]),
                                ))
                            .toList(),
                      ),
                    ]),
                  ),
          ),
        ]),
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k.toUpperCase(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1)),
          Text(v, style: const TextStyle(fontSize: 13, height: 1.4)),
        ]),
      );

  Widget _dosage() {
    const freqs = ['Once daily', 'Twice daily', 'Every 8 h', 'As needed'];
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GlassCard(
        glow: AppColors.teal,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Dosage & schedule', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(freqs.length, (i) {
              final a = i == _freq;
              return Pressable(
                onTap: () => setState(() => _freq = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: a ? AppColors.doctor : null,
                    color: a ? null : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(freqs[i], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(children: [
            const Text('Duration', style: TextStyle(color: AppColors.textSecondary)),
            const Spacer(),
            GradientText('$_days days', gradient: AppColors.doctor, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ]),
          Slider(value: _days.toDouble(), min: 1, max: 90, divisions: 89, onChanged: (v) => setState(() => _days = v.round())),
          const TextField(maxLines: 2, decoration: InputDecoration(hintText: 'Notes for patient (e.g. take after meals)')),
          const SizedBox(height: 16),
          GradientButton(label: 'Send prescription', icon: Icons.send_rounded, gradient: AppColors.doctor, onTap: _send),
        ]),
      ),
    );
  }
}
