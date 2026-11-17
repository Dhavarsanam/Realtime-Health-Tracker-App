import 'package:flutter/material.dart';

/// Central design tokens for the VitalSync premium design language.
class AppColors {
  AppColors._();

  // Surfaces
  static const Color bg = Color(0xFF060914);
  static const Color bgElevated = Color(0xFF0C1124);
  static const Color surface = Color(0xFF121933);
  static const Color surfaceHigh = Color(0xFF1A2244);
  static const Color stroke = Color(0x1FFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFFF4F6FF);
  static const Color textSecondary = Color(0xFFA3ABCB);
  static const Color textMuted = Color(0xFF6B7396);

  // Brand
  static const Color cyan = Color(0xFF22D3EE);
  static const Color teal = Color(0xFF2DD4BF);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color indigo = Color(0xFF6366F1);
  static const Color pink = Color(0xFFEC4899);
  static const Color rose = Color(0xFFF43F5E);
  static const Color amber = Color(0xFFF59E0B);
  static const Color emerald = Color(0xFF10B981);
  static const Color sky = Color(0xFF38BDF8);
  static const Color orange = Color(0xFFFB923C);

  // Semantic
  static const Color success = emerald;
  static const Color warning = amber;
  static const Color danger = rose;

  // Gradients
  static const LinearGradient brand = LinearGradient(
    colors: [Color(0xFF22D3EE), Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient heart = LinearGradient(
    colors: [Color(0xFFFF6B8B), Color(0xFFF43F5E), Color(0xFFBE123C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient aqua = LinearGradient(
    colors: [Color(0xFF67E8F9), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient sunset = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient mint = LinearGradient(
    colors: [Color(0xFF6EE7B7), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient night = LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient doctor = LinearGradient(
    colors: [Color(0xFF2DD4BF), Color(0xFF0EA5E9), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient danger3 = LinearGradient(
    colors: [Color(0xFFFF8A8A), Color(0xFFF43F5E), Color(0xFF9F1239)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
