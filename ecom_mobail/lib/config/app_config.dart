import 'package:flutter/material.dart';

/// هذا هو محرك التصميم الجديد لتطبيق "محسوب"
/// بناءً على الهوية البصرية المعتمدة بتاريخ 28-12-2025
class AppConfig {
  AppConfig._();

  // =======================================================================
  // 1. نظام الألوان الجديد (New Color Palette)
  // =======================================================================
  static const Color primaryColor = Color(0xFF007BFF);    // اللون الأساسي الجديد (الأزرق الساطع)
  static const Color secondaryColor = Color(0xFF0056b3);  // درجة أغمق من الأزرق للاستخدامات الثانوية

  // ألوان الخلفيات والأسطح
  static const Color backgroundColor = Colors.white;      // خلفية التطبيق أصبحت بيضاء
  static const Color surfaceColor = Color(0xFFF8F9FA);    // لون خلفية البطاقات (رمادي فاتح)

  // ألوان النصوص
  static const Color textPrimary = Color(0xFF212529);     // لون النص الداكن
  static const Color textSecondary = Colors.white;        // لون النص على الأزرار الزرقاء
  static const Color textSubtle = Color(0xFF6c757d);      // لون النصوص الفرعية

  // ألوان أخرى
  static const Color accentColor = Colors.green;
  static const Color errorColor = Color(0xFFDC3545);
  static final Color shadowColor = Colors.black.withOpacity(0.04);
  static final Color borderColor = Colors.grey.shade300;  // لون الحدود الخفيفة للبطاقات

  // =======================================================================
  // 2. نظام الخطوط (Typography)
  // =======================================================================
  static const double fontSizeDisplay = 32.0;
  static const double fontSizeHeader = 22.0;
  static const double fontSizeTitle = 18.0;
  static const double fontSizeBody = 16.0;
  static const double fontSizeSubtitle = 14.0;
  static const double fontSizeCaption = 12.0;

  // =======================================================================
  // 3. أحجام الأيقونات (Iconography)
  // =======================================================================
  static const double iconSizeLarge = 30.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeSmall = 20.0;

  // =======================================================================
  // 4. المسافات والفراغات (Spacing)
  // =======================================================================
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;

  // =======================================================================
  // 5. خصائص عناصر الواجهة (UI Elements Properties)
  // =======================================================================
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double generalElevation = 0.0; // الاعتماد على الحدود بدلاً من الظل
}