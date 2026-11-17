import 'package:flutter/material.dart';

enum HealthStatus { optimal, normal, warning, critical }

extension HealthStatusX on HealthStatus {
  String get label => switch (this) {
        HealthStatus.optimal => 'Optimal',
        HealthStatus.normal => 'Normal',
        HealthStatus.warning => 'Attention',
        HealthStatus.critical => 'Critical',
      };

  Color get color => switch (this) {
        HealthStatus.optimal => const Color(0xFF10B981),
        HealthStatus.normal => const Color(0xFF22D3EE),
        HealthStatus.warning => const Color(0xFFF59E0B),
        HealthStatus.critical => const Color(0xFFF43F5E),
      };

  IconData get icon => switch (this) {
        HealthStatus.optimal => Icons.verified_rounded,
        HealthStatus.normal => Icons.check_circle_rounded,
        HealthStatus.warning => Icons.error_rounded,
        HealthStatus.critical => Icons.warning_amber_rounded,
      };
}

class Vital {
  final String key;
  final String name;
  final String value;
  final String unit;
  final IconData icon;
  final Gradient gradient;
  final HealthStatus status;
  final List<double> trend;
  final String delta;

  const Vital({
    required this.key,
    required this.name,
    required this.value,
    required this.unit,
    required this.icon,
    required this.gradient,
    required this.status,
    required this.trend,
    required this.delta,
  });
}

class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String condition;
  final HealthStatus status;
  final int heartRate;
  final String bp;
  final int glucose;
  final int score;
  final Color avatarColor;
  final String lastUpdate;

  const Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.condition,
    required this.status,
    required this.heartRate,
    required this.bp,
    required this.glucose,
    required this.score,
    required this.avatarColor,
    required this.lastUpdate,
  });

  String get initials => name.split(' ').map((e) => e[0]).take(2).join();
}

class ChatMessage {
  final String text;
  final bool mine;
  final DateTime time;
  const ChatMessage(this.text, this.mine, this.time);
}

class Conversation {
  final String name;
  final String role;
  final String lastMessage;
  final String time;
  final int unread;
  final bool online;
  final Color color;
  const Conversation({
    required this.name,
    required this.role,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.online,
    required this.color,
  });
  String get initials => name.replaceAll('Dr. ', '').split(' ').map((e) => e[0]).take(2).join();
}

class Drug {
  final String brand;
  final String generic;
  final String manufacturer;
  final String route;
  final String purpose;
  final List<String> warnings;
  final String dosage;
  const Drug({
    required this.brand,
    required this.generic,
    required this.manufacturer,
    required this.route,
    required this.purpose,
    required this.warnings,
    required this.dosage,
  });
}

class SosAlert {
  final Patient patient;
  final String reason;
  final String location;
  final String time;
  final bool active;
  const SosAlert(this.patient, this.reason, this.location, this.time, this.active);
}

class Reminder {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Gradient gradient;
  bool enabled;
  Reminder(this.title, this.subtitle, this.time, this.icon, this.gradient, this.enabled);
}

class Goal {
  final String title;
  final String unit;
  final double current;
  final double target;
  final IconData icon;
  final Gradient gradient;
  const Goal(this.title, this.unit, this.current, this.target, this.icon, this.gradient);
  double get progress => (current / target).clamp(0, 1).toDouble();
}
