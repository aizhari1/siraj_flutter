import 'package:flutter/material.dart';

/// ألوان تطبيق سراج - أبيض وأزرق
class AppColors {
  AppColors._();

  // الأزرق الأساسي (Primary)
  static const Color primary = Color(0xFF1565D8);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF4A8CF0);
  static const Color primarySoft = Color(0xFFE8F1FD); // خلفيات خفيفة

  // الأزرق الثانوي / التمييز
  static const Color secondary = Color(0xFF00B8D9);
  static const Color accent = Color(0xFF2196F3);

  // أبيض وخلفيات
  static const Color background = Color(0xFFF7FAFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF0F4FA);

  // نصوص
  static const Color textPrimary = Color(0xFF0F1B2D);
  static const Color textSecondary = Color(0xFF5B6B84);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // حالة / تنبيهات
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0EA5E9);

  // حدود وفواصل
  static const Color border = Color(0xFFE1E9F5);
  static const Color divider = Color(0xFFEAF0FA);

  // تدرج البطاقات الرئيسية
  static const List<Color> heroGradient = [primaryDark, primary, accent];

  // ألوان حسب الدور
  static const Color studentColor = primary;
  static const Color teacherColor = Color(0xFF0EA5E9);
  static const Color adminColor = Color(0xFF0D47A1);
}
