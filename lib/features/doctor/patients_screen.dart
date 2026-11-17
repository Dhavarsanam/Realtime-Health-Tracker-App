import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';
import 'doctor_dashboard_screen.dart';
import 'patient_detail_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  HealthStatus? _filter;
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final list = MockData.patients
        .where((p) => _filter == null || p.status == _filter)
        .where((p) => _q.isEmpty || p.name.toLowerCase().contains(_q.toLowerCase()) || p.condition.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
        children: [
          Entrance(child: Text('Patients', style: Theme.of(context).textTheme.headlineMedium)),
          Entrance(index: 1, child: Text('${MockData.patients.length} under remote monitoring', style: const TextStyle(color: AppColors.textSecondary))),
          const SizedBox(height: 16),
          Entrance(
            index: 2,
            child: TextField(
              onChanged: (v) => setState(() => _q = v),
              decoration: const InputDecoration(hintText: 'Search name or condition', prefixIcon: Icon(Icons.search_rounded), suffixIcon: Icon(Icons.tune_rounded)),
            ),
          ),
          const SizedBox(height: 14),
          Entrance(
            index: 3,
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _chip('All', null, AppColors.cyan),
                  for (final s in HealthStatus.values) _chip(s.label, s, s.color),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Column(
              key: ValueKey('$_filter$_q'),
              children: list.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Column(children: [
                          Icon(Icons.person_search_rounded, size: 56, color: AppColors.textMuted),
                          SizedBox(height: 10),
                          Text('No patients match', style: TextStyle(color: AppColors.textSecondary)),
                        ]),
                      ),
                    ]
                  : list
                      .asMap()
                      .entries
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Entrance(
                              index: e.key,
                              child: PatientTile(patient: e.value, onTap: () => Navigator.of(context).push(premiumRoute(PatientDetailScreen(patient: e.value)))),
                            ),
                          ))
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, HealthStatus? s, Color c) {
    final active = _filter == s;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Pressable(
        onTap: () => setState(() => _filter = s),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? c.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: active ? c : AppColors.stroke),
          ),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: active ? c : AppColors.textSecondary)),
        ),
      ),
    );
  }
}
