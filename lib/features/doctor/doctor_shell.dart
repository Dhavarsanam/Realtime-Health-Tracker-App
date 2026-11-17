import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/floating_nav.dart';
import '../chat/chat_list_screen.dart';
import '../patient/profile_screen.dart';
import 'alerts_screen.dart';
import 'doctor_dashboard_screen.dart';
import 'patients_screen.dart';

class DoctorShell extends StatefulWidget {
  const DoctorShell({super.key});

  @override
  State<DoctorShell> createState() => _DoctorShellState();
}

class _DoctorShellState extends State<DoctorShell> {
  int _index = 0;

  static const _items = [
    NavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Home'),
    NavItem(Icons.people_outline_rounded, Icons.people_rounded, 'Patients'),
    NavItem(Icons.sos_outlined, Icons.sos_rounded, 'Alerts'),
    NavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Chat'),
    NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Me'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      DoctorDashboardScreen(onOpenTab: (i) => setState(() => _index = i)),
      const PatientsScreen(),
      const AlertsScreen(),
      const ChatListScreen(doctor: true),
      const ProfileScreen(doctor: true),
    ];
    return Scaffold(
      extendBody: true,
      body: AuroraBackground(
        colors: const [AppColors.teal, AppColors.sky, AppColors.indigo],
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          transitionBuilder: (child, a) => FadeTransition(
            opacity: a,
            child: SlideTransition(position: Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(a), child: child),
          ),
          child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
        ),
      ),
      bottomNavigationBar: FloatingNav(items: _items, index: _index, gradient: AppColors.doctor, onChanged: (i) => setState(() => _index = i)),
    );
  }
}
