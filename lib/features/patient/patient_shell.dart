import 'package:flutter/material.dart';

import '../../widgets/aurora_background.dart';
import '../../widgets/floating_nav.dart';
import '../chat/chat_list_screen.dart';
import 'ai_chatbot_screen.dart';
import 'patient_home_screen.dart';
import 'profile_screen.dart';
import 'trends_screen.dart';

class PatientShell extends StatefulWidget {
  const PatientShell({super.key});

  @override
  State<PatientShell> createState() => _PatientShellState();
}

class _PatientShellState extends State<PatientShell> {
  int _index = 0;

  static const _items = [
    NavItem(Icons.space_dashboard_outlined, Icons.space_dashboard_rounded, 'Home'),
    NavItem(Icons.insights_outlined, Icons.insights_rounded, 'Trends'),
    NavItem(Icons.auto_awesome_outlined, Icons.auto_awesome_rounded, 'AI'),
    NavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Chat'),
    NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Me'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      PatientHomeScreen(onOpenTab: (i) => setState(() => _index = i)),
      const TrendsScreen(),
      AiChatbotScreen(onClose: () => setState(() => _index = 0)),
      const ChatListScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      extendBody: true,
      body: AuroraBackground(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, a) => FadeTransition(
            opacity: a,
            child: SlideTransition(position: Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(a), child: child),
          ),
          child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
        ),
      ),
      bottomNavigationBar: _index == 2 ? null : FloatingNav(items: _items, index: _index, onChanged: (i) => setState(() => _index = i)),
    );
  }
}
