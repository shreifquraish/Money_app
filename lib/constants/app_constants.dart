import 'package:flutter/material.dart';

/// ألوان التطبيق
class AppColors {
  // الألوان الأساسية
  static const Color primaryColor = Color(0xFF5B6DEF);
  static const Color primaryDark = Color(0xFF3D4BBD);
  static const Color primaryLight = Color(0xFF8B95FF);

  static const Color secondaryColor = Color(0xFFFF6B6B);
  static const Color secondaryLight = Color(0xFFFF8E8E);

  // ألوان الحالات
  static const Color successColor = Color(0xFF51CF66);
  static const Color warningColor = Color(0xFFFFA94D);
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color infoColor = Color(0xFF4ECDC4);

  // ألوان النصوص
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFD1D5DB);

  // ألوان الخلفية
  static const Color bgLight = Color(0xFFFAFAFA);
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgGray = Color(0xFFF3F4F6);

  // ألوان مخصصة للعناصر
  static const Color incomeColor = Color(0xFF51CF66);
  static const Color expenseColor = Color(0xFFFF6B6B);
  static const Color savingColor = Color(0xFF4ECDC4);
  static const Color debtColor = Color(0xFFB28DFF);

  // ألوان للـ Gradient
  static const List<Color> primaryGradient = [
    Color(0xFF5B6DEF),
    Color(0xFF3D4BBD),
  ];

  static const List<Color> successGradient = [
    Color(0xFF51CF66),
    Color(0xFF37B24D),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFFA94D),
    Color(0xFFFF922B),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFFF6B6B),
    Color(0xFFFA5252),
  ];
}

/// الهوامش والحشوات
class AppPadding {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

/// أنصاف الأقطار
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double circle = 999.0;
}

/// أحجام الخطوط
class AppFontSizes {
  static const double xs = 10.0;
  static const double sm = 12.0;
  static const double base = 14.0;
  static const double lg = 16.0;
  static const double xl = 18.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double h1 = 36.0;
}

/// الفواصل والارتفاعات
class AppSpacer {
  static const double xs = 2.0;
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

/// مدة الرسوم المتحركة
class AppDuration {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

/// رسائل الخطأ والتحقق
class AppMessages {
  // رسائل عامة
  static const String networkError = 'حدث خطأ في الاتصال';
  static const String unknownError = 'حدث خطأ غير متوقع';
  static const String success = 'تم بنجاح';

  // رسائل التحقق
  static const String nameRequired = 'اسم المستخدم مطلوب';
  static const String nameInvalid = 'اسم المستخدم يجب أن يكون أكثر من 2 حروف';
  static const String ageRequired = 'السن مطلوب';
  static const String ageInvalid = 'السن يجب أن يكون بين 1 و 150';
  static const String amountRequired = 'المبلغ مطلوب';
  static const String amountInvalid = 'المبلغ يجب أن يكون أكبر من 0';
  static const String personNameRequired = 'اسم الشخص مطلوب';
  static const String descriptionRequired = 'الوصف مطلوب';
  static const String itemNameRequired = 'اسم المنتج مطلوب';
}

/// أيقونات مخصصة
class AppIcons {
  static const IconData income = Icons.arrow_downward;
  static const IconData expense = Icons.arrow_upward;
  static const IconData money = Icons.attach_money;
  static const IconData purchase = Icons.shopping_cart;
  static const IconData debt = Icons.warning_rounded;
  static const IconData home = Icons.home;
  static const IconData settings = Icons.settings;
  static const IconData add = Icons.add;
  static const IconData delete = Icons.delete;
  static const IconData edit = Icons.edit;
}
