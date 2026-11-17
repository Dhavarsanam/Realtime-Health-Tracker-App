import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project1/core/mock/mock_data.dart';
import 'package:project1/features/auth/login_screen.dart';
import 'package:project1/features/auth/role_select_screen.dart';
import 'package:project1/features/chat/chat_room_screen.dart';
import 'package:project1/features/doctor/doctor_shell.dart';
import 'package:project1/features/doctor/patient_detail_screen.dart';
import 'package:project1/features/doctor/prescribe_screen.dart';
import 'package:project1/features/onboarding/onboarding_screen.dart';
import 'package:project1/features/patient/add_vitals_screen.dart';
import 'package:project1/features/patient/ai_chatbot_screen.dart';
import 'package:project1/features/patient/goals_screen.dart';
import 'package:project1/features/patient/patient_shell.dart';
import 'package:project1/features/patient/reminders_screen.dart';
import 'package:project1/features/patient/sos_screen.dart';
import 'package:project1/features/patient/steps_screen.dart';
import 'package:project1/features/patient/vital_detail_screen.dart';
import 'package:project1/features/shared/notifications_screen.dart';

/// Renders every screen at common phone sizes and fails on layout overflow.
void main() {
  // Load real Roboto so text metrics match a phone (the default test font
  // renders every glyph as a full-width square).
  setUpAll(() async {
    final dir = '${Platform.environment['FLUTTER_ROOT'] ?? r'C:\flutter'}/bin/cache/artifacts/material_fonts';
    for (final w in ['regular', 'medium', 'bold', 'black']) {
      final f = File('$dir/roboto-$w.ttf');
      if (!f.existsSync()) continue;
      final loader = FontLoader('Roboto')..addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
      await loader.load();
    }
  });

  final screens = <String, Widget Function()>{
    'onboarding': () => const OnboardingScreen(),
    'role': () => const RoleSelectScreen(),
    'login': () => const LoginScreen(role: UserRole.patient),
    'patient shell': () => const PatientShell(),
    'add vitals': () => const AddVitalsScreen(),
    'vital detail': () => VitalDetailScreen(vital: MockData.vitals.first),
    'goals': () => const GoalsScreen(),
    'steps': () => const StepsScreen(),
    'reminders': () => const RemindersScreen(),
    'sos': () => const SosScreen(),
    'ai': () => const AiChatbotScreen(),
    'notifications': () => const NotificationsScreen(),
    'chat room': () => ChatRoomScreen(conversation: MockData.conversations.first),
    'doctor shell': () => const DoctorShell(),
    'patient detail': () => PatientDetailScreen(patient: MockData.patients[1]),
    'prescribe': () => const PrescribeScreen(),
  };

  for (final size in const [Size(360, 740), Size(412, 915)]) {
    for (final e in screens.entries) {
      testWidgets('${e.key} @ ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        tester.view.physicalSize = size * 3;
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        final errors = <String>[];
        final prev = FlutterError.onError;
        FlutterError.onError = (d) {
          final s = d.toString();
          final m = RegExp(r'(overflowed by [\d.]+ pixels on the \w+)[\s\S]*?(lib/[\w/]+\.dart:\d+)').firstMatch(s);
          errors.add(m == null ? d.exceptionAsString() : '${m[1]} @ ${m[2]}');
        };
        await tester.pumpWidget(MaterialApp(theme: ThemeData.dark(useMaterial3: true), home: e.value()));
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 150));
        }
        FlutterError.onError = prev;
        expect(errors.toSet().toList(), isEmpty);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 3));
      });
    }
  }
}
