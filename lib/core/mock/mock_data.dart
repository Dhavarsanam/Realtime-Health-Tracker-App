import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_colors.dart';

/// Frontend-only sample data. Replace with SQLite / API layers later.
class MockData {
  MockData._();

  static const patientName = 'Aarav Mehta';
  static const doctorName = 'Dr. Sophia Carter';

  static const vitals = <Vital>[
    Vital(
      key: 'hr',
      name: 'Heart Rate',
      value: '72',
      unit: 'bpm',
      icon: Icons.favorite_rounded,
      gradient: AppColors.heart,
      status: HealthStatus.optimal,
      trend: [68, 74, 71, 79, 73, 70, 72],
      delta: '-2%',
    ),
    Vital(
      key: 'bp',
      name: 'Blood Pressure',
      value: '118/76',
      unit: 'mmHg',
      icon: Icons.bloodtype_rounded,
      gradient: AppColors.night,
      status: HealthStatus.optimal,
      trend: [122, 119, 125, 117, 120, 116, 118],
      delta: '-1%',
    ),
    Vital(
      key: 'gl',
      name: 'Glucose',
      value: '108',
      unit: 'mg/dL',
      icon: Icons.water_drop_rounded,
      gradient: AppColors.sunset,
      status: HealthStatus.normal,
      trend: [96, 112, 104, 118, 101, 110, 108],
      delta: '+4%',
    ),
    Vital(
      key: 'wt',
      name: 'Water',
      value: '1.9',
      unit: 'L',
      icon: Icons.local_drink_rounded,
      gradient: AppColors.aqua,
      status: HealthStatus.normal,
      trend: [2.1, 1.6, 2.4, 2.0, 1.8, 2.6, 1.9],
      delta: '-8%',
    ),
    Vital(
      key: 'sl',
      name: 'Sleep',
      value: '7.4',
      unit: 'hrs',
      icon: Icons.bedtime_rounded,
      gradient: AppColors.brand,
      status: HealthStatus.optimal,
      trend: [6.2, 7.1, 6.8, 7.9, 8.1, 7.0, 7.4],
      delta: '+6%',
    ),
    Vital(
      key: 'cal',
      name: 'Calories',
      value: '1,840',
      unit: 'kcal',
      icon: Icons.local_fire_department_rounded,
      gradient: AppColors.mint,
      status: HealthStatus.optimal,
      trend: [2100, 1950, 2240, 1800, 2010, 1890, 1840],
      delta: '-3%',
    ),
  ];

  static const patients = <Patient>[
    Patient(id: 'P-1024', name: 'Aarav Mehta', age: 34, gender: 'M', condition: 'Hypertension', status: HealthStatus.optimal, heartRate: 72, bp: '118/76', glucose: 108, score: 92, avatarColor: AppColors.cyan, lastUpdate: '2 min ago'),
    Patient(id: 'P-1031', name: 'Elena Rossi', age: 58, gender: 'F', condition: 'Type 2 Diabetes', status: HealthStatus.critical, heartRate: 118, bp: '168/104', glucose: 262, score: 41, avatarColor: AppColors.rose, lastUpdate: 'Just now'),
    Patient(id: 'P-1047', name: 'Marcus Chen', age: 46, gender: 'M', condition: 'Arrhythmia', status: HealthStatus.warning, heartRate: 104, bp: '142/88', glucose: 121, score: 64, avatarColor: AppColors.amber, lastUpdate: '12 min ago'),
    Patient(id: 'P-1052', name: 'Priya Nair', age: 29, gender: 'F', condition: 'Pregnancy care', status: HealthStatus.normal, heartRate: 84, bp: '124/80', glucose: 98, score: 81, avatarColor: AppColors.violet, lastUpdate: '1 h ago'),
    Patient(id: 'P-1066', name: 'James Walker', age: 71, gender: 'M', condition: 'COPD', status: HealthStatus.warning, heartRate: 96, bp: '136/86', glucose: 112, score: 59, avatarColor: AppColors.orange, lastUpdate: '25 min ago'),
    Patient(id: 'P-1078', name: 'Sofia Alvarez', age: 39, gender: 'F', condition: 'Post-surgery', status: HealthStatus.optimal, heartRate: 68, bp: '114/72', glucose: 92, score: 95, avatarColor: AppColors.emerald, lastUpdate: '3 h ago'),
  ];

  static final sosAlerts = <SosAlert>[
    SosAlert(patients[1], 'Glucose 262 mg/dL · HR 118 bpm', '2.3 km · Park Avenue, NY', 'Just now', true),
    SosAlert(patients[2], 'Irregular heartbeat detected', '5.8 km · Brooklyn, NY', '14 min ago', true),
    SosAlert(patients[4], 'Low SpO₂ reported', '1.1 km · Queens, NY', 'Yesterday', false),
  ];

  static const conversations = <Conversation>[
    Conversation(name: 'Dr. Sophia Carter', role: 'Cardiologist', lastMessage: 'Your BP trend looks great this week 👏', time: '09:42', unread: 2, online: true, color: AppColors.cyan),
    Conversation(name: 'Dr. Liam Patel', role: 'Endocrinologist', lastMessage: 'Please log fasting glucose tomorrow.', time: 'Yesterday', unread: 0, online: false, color: AppColors.violet),
    Conversation(name: 'Dr. Hana Kim', role: 'General Physician', lastMessage: 'Prescription updated in your profile.', time: 'Mon', unread: 0, online: true, color: AppColors.emerald),
    Conversation(name: 'Care Team', role: 'Nursing support', lastMessage: 'Reminder: follow-up visit on Friday.', time: 'Sun', unread: 1, online: false, color: AppColors.amber),
  ];

  static final chatThread = <ChatMessage>[
    ChatMessage('Good morning Doctor! I logged my vitals today.', true, DateTime.now().subtract(const Duration(minutes: 40))),
    ChatMessage('Morning Aarav! I can see them. Your BP is 118/76 — excellent progress.', false, DateTime.now().subtract(const Duration(minutes: 38))),
    ChatMessage('Should I continue the same dosage of Amlodipine?', true, DateTime.now().subtract(const Duration(minutes: 30))),
    ChatMessage('Yes, continue 5 mg once daily. We will review again in two weeks.', false, DateTime.now().subtract(const Duration(minutes: 28))),
    ChatMessage('Your BP trend looks great this week 👏', false, DateTime.now().subtract(const Duration(minutes: 3))),
  ];

  static const drugs = <Drug>[
    Drug(brand: 'Norvasc', generic: 'Amlodipine Besylate', manufacturer: 'Pfizer Labs', route: 'Oral', purpose: 'Treatment of hypertension and chronic stable angina.', warnings: ['Hypotension', 'Peripheral edema', 'Avoid in severe aortic stenosis'], dosage: '5 mg once daily, max 10 mg'),
    Drug(brand: 'Glucophage', generic: 'Metformin Hydrochloride', manufacturer: 'Bristol-Myers Squibb', route: 'Oral', purpose: 'Improves glycemic control in adults with type 2 diabetes mellitus.', warnings: ['Lactic acidosis', 'Renal impairment', 'Hold before iodinated contrast'], dosage: '500 mg twice daily with meals'),
    Drug(brand: 'Lipitor', generic: 'Atorvastatin Calcium', manufacturer: 'Viatris', route: 'Oral', purpose: 'Reduces LDL-C and risk of myocardial infarction and stroke.', warnings: ['Myopathy', 'Liver enzyme elevation'], dosage: '10–20 mg once daily'),
    Drug(brand: 'Lopressor', generic: 'Metoprolol Tartrate', manufacturer: 'Novartis', route: 'Oral', purpose: 'Management of hypertension, angina and heart failure.', warnings: ['Do not stop abruptly', 'Bradycardia', 'Bronchospasm'], dosage: '50 mg twice daily'),
    Drug(brand: 'Ventolin HFA', generic: 'Albuterol Sulfate', manufacturer: 'GlaxoSmithKline', route: 'Inhalation', purpose: 'Treatment or prevention of bronchospasm.', warnings: ['Paradoxical bronchospasm', 'Tachycardia'], dosage: '2 puffs every 4–6 h as needed'),
    Drug(brand: 'Zestril', generic: 'Lisinopril', manufacturer: 'Almatica Pharma', route: 'Oral', purpose: 'Hypertension, heart failure and acute MI.', warnings: ['Angioedema', 'Fetal toxicity', 'Hyperkalemia'], dosage: '10 mg once daily'),
  ];

  static final reminders = <Reminder>[
    Reminder('Hydration break', 'Drink 250 ml of water', 'Every 2 h', Icons.local_drink_rounded, AppColors.aqua, true),
    Reminder('Morning vitals', 'Log BP & heart rate', '08:00 AM', Icons.monitor_heart_rounded, AppColors.heart, true),
    Reminder('Amlodipine 5 mg', 'After breakfast', '09:00 AM', Icons.medication_rounded, AppColors.night, true),
    Reminder('Evening walk', '30 min brisk walk', '06:30 PM', Icons.directions_walk_rounded, AppColors.mint, false),
    Reminder('Wind down', 'Screens off, sleep prep', '10:30 PM', Icons.bedtime_rounded, AppColors.brand, true),
  ];

  static const goals = <Goal>[
    Goal('Daily Steps', 'steps', 8432, 10000, Icons.directions_walk_rounded, AppColors.mint),
    Goal('Hydration', 'L', 1.9, 3, Icons.local_drink_rounded, AppColors.aqua),
    Goal('Sleep', 'h', 7.4, 8, Icons.bedtime_rounded, AppColors.night),
    Goal('Active Calories', 'kcal', 420, 600, Icons.local_fire_department_rounded, AppColors.sunset),
  ];

  static const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
}
