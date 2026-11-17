import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/analyzer/health_analyzer.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';

class AddVitalsScreen extends StatefulWidget {
  const AddVitalsScreen({super.key});

  @override
  State<AddVitalsScreen> createState() => _AddVitalsScreenState();
}

class _AddVitalsScreenState extends State<AddVitalsScreen> {
  double systolic = 118, diastolic = 76, hr = 72, glucose = 104, water = 1.9, sleep = 7.4, calories = 1840;
  bool _saving = false;

  Future<void> _analyze() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _saving = false);
    HapticFeedback.mediumImpact();
    final result = HealthAnalyzer.analyze(
      systolic: systolic.round(),
      diastolic: diastolic.round(),
      heartRate: hr.round(),
      glucose: glucose.round(),
      waterLiters: water,
      sleepHours: sleep,
      calories: calories.round(),
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AnalysisSheet(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
              const PageHeader(title: 'Log vitals', subtitle: 'Stored securely on your device'),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                  children: [
                    Entrance(
                      child: _MetricSlider(
                        title: 'Blood Pressure',
                        icon: Icons.bloodtype_rounded,
                        gradient: AppColors.night,
                        display: '${systolic.round()}/${diastolic.round()}',
                        unit: 'mmHg',
                        children: [
                          _labeledSlider('Systolic', systolic, 80, 200, (v) => setState(() => systolic = v), AppColors.violet),
                          _labeledSlider('Diastolic', diastolic, 50, 130, (v) => setState(() => diastolic = v), AppColors.indigo),
                        ],
                      ),
                    ),
                    Entrance(
                      index: 1,
                      child: _MetricSlider(
                        title: 'Heart Rate',
                        icon: Icons.favorite_rounded,
                        gradient: AppColors.heart,
                        display: '${hr.round()}',
                        unit: 'bpm',
                        children: [_labeledSlider('Resting', hr, 40, 160, (v) => setState(() => hr = v), AppColors.rose)],
                      ),
                    ),
                    Entrance(
                      index: 2,
                      child: _MetricSlider(
                        title: 'Glucose',
                        icon: Icons.water_drop_rounded,
                        gradient: AppColors.sunset,
                        display: '${glucose.round()}',
                        unit: 'mg/dL',
                        children: [_labeledSlider('Fasting', glucose, 50, 300, (v) => setState(() => glucose = v), AppColors.amber)],
                      ),
                    ),
                    Entrance(index: 3, child: _WaterPicker(value: water, onChanged: (v) => setState(() => water = v))),
                    Row(
                      children: [
                        Expanded(
                          child: Entrance(
                            index: 4,
                            child: _Stepper(
                              title: 'Sleep',
                              icon: Icons.bedtime_rounded,
                              gradient: AppColors.brand,
                              value: sleep.toStringAsFixed(1),
                              unit: 'hrs',
                              onMinus: () => setState(() => sleep = (sleep - 0.5).clamp(0, 14)),
                              onPlus: () => setState(() => sleep = (sleep + 0.5).clamp(0, 14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Entrance(
                            index: 5,
                            child: _Stepper(
                              title: 'Calories',
                              icon: Icons.local_fire_department_rounded,
                              gradient: AppColors.mint,
                              value: calories.round().toString(),
                              unit: 'kcal',
                              onMinus: () => setState(() => calories = (calories - 50).clamp(0, 5000)),
                              onPlus: () => setState(() => calories = (calories + 50).clamp(0, 5000)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Entrance(
                      index: 6,
                      child: GradientButton(label: 'Analyze & save', icon: Icons.auto_awesome_rounded, loading: _saving, onTap: _analyze),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labeledSlider(String label, double v, double min, double max, ValueChanged<double> on, Color c) {
    const caption = TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Row(children: [
            Text(label, style: caption),
            const Spacer(),
            Text('${min.round()}–${max.round()}', style: caption.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w500)),
          ]),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(activeTrackColor: c, overlayColor: c.withValues(alpha: 0.2)),
            child: Slider(
              value: v,
              min: min,
              max: max,
              padding: const EdgeInsets.symmetric(vertical: 14),
              onChanged: (x) {
                if (x.round() != v.round()) HapticFeedback.selectionClick();
                on(x);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricSlider extends StatelessWidget {
  final String title;
  final IconData icon;
  final Gradient gradient;
  final String display;
  final String unit;
  final List<Widget> children;
  const _MetricSlider({required this.title, required this.icon, required this.gradient, required this.display, required this.unit, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Column(
          children: [
            Row(
              children: [
                IconOrb(icon: icon, gradient: gradient, size: 40, iconSize: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    GradientText(display, gradient: gradient, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(width: 4),
                    Text(unit, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _WaterPicker extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _WaterPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final glasses = (value / 0.25).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IconOrb(icon: Icons.local_drink_rounded, gradient: AppColors.aqua, size: 40, iconSize: 20),
                const SizedBox(width: 12),
                const Expanded(child: Text('Water intake', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    GradientText(value.toStringAsFixed(2), gradient: AppColors.aqua, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(width: 4),
                    const Text('L', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 6,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.78,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(12, (i) {
                final filled = i < glasses;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onChanged((i + 1) * 0.25);
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 250 + i * 20),
                    curve: Curves.easeOutBack,
                    width: 30,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6), bottom: Radius.circular(10)),
                      gradient: filled ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF67E8F9), Color(0xFF0284C7)]) : null,
                      color: filled ? null : Colors.white.withValues(alpha: 0.05),
                      border: Border.all(color: filled ? Colors.transparent : AppColors.stroke),
                      boxShadow: filled ? [BoxShadow(color: AppColors.sky.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))] : null,
                    ),
                    child: filled ? const Icon(Icons.water_drop, size: 13, color: Colors.white70) : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            const Text('Tap a glass · each = 250 ml', style: TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String title;
  final IconData icon;
  final Gradient gradient;
  final String value;
  final String unit;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const _Stepper({required this.title, required this.icon, required this.gradient, required this.value, required this.unit, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(children: [
            IconOrb(icon: icon, gradient: gradient, size: 34, iconSize: 17),
            const SizedBox(width: 8),
            Flexible(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 14),
          FittedBox(fit: BoxFit.scaleDown, child: GradientText(value, gradient: gradient, style: Theme.of(context).textTheme.headlineMedium)),
          Text(unit, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _btn(Icons.remove_rounded, onMinus),
              _btn(Icons.add_rounded, onPlus),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn(IconData i, VoidCallback f) => Pressable(
        onTap: f,
        child: Container(
          width: 44,
          height: 36,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
          child: Icon(i, size: 20),
        ),
      );
}

/// Bottom sheet that presents the analyzer's evaluation.
class AnalysisSheet extends StatelessWidget {
  final AnalysisResult result;
  const AnalysisSheet({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final overall = result.overall;
    final g = LinearGradient(colors: [overall.color, Color.lerp(overall.color, AppColors.violet, 0.5)!]);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, sc) => Container(
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
          border: Border.all(color: AppColors.stroke),
        ),
        child: ListView(
          controller: sc,
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
          children: [
            Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 18),
            Center(
              child: ArcGauge(
                value: result.score / 100,
                size: 220,
                gradient: g,
                center: Column(mainAxisSize: MainAxisSize.min, children: [
                  CountUp(result.score.toDouble(), style: Theme.of(context).textTheme.displaySmall),
                  const Text('Health score', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ]),
              ),
            ),
            const SizedBox(height: 14),
            Center(child: StatusPill(overall)),
            const SizedBox(height: 12),
            Text(result.summary, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
            if (overall == HealthStatus.critical) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.rose.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.rose.withValues(alpha: 0.4)),
                ),
                child: const Row(children: [
                  Icon(Icons.notifications_active_rounded, color: AppColors.rose),
                  SizedBox(width: 10),
                  Expanded(child: Text('Dr. Sophia Carter has been alerted about your critical readings.', style: TextStyle(fontSize: 13))),
                ]),
              ),
            ],
            const SizedBox(height: 20),
            ...result.items.asMap().entries.map((e) => Entrance(
                  index: e.key,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(18),
                      border: Border(left: BorderSide(color: e.value.status.color, width: 3)),
                    ),
                    child: Row(
                      children: [
                        Icon(e.value.status.icon, color: e.value.status.color),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Text(e.value.metric, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Text(e.value.value, style: TextStyle(color: e.value.status.color, fontWeight: FontWeight.w700, fontSize: 13)),
                            ]),
                            const SizedBox(height: 3),
                            Text(e.value.message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 14),
            GradientButton(
              label: 'Done',
              gradient: g,
              onTap: () {
                Navigator.of(context)
                  ..pop()
                  ..pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
