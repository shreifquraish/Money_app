import '../constants/app_constants.dart';

/// فئة التحقق من صحة البيانات
class Validators {
  /// التحقق من اسم المستخدم
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppMessages.nameRequired;
    }
    if (value.length < 2) {
      return AppMessages.nameInvalid;
    }
    return null;
  }

  /// التحقق من السن
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return AppMessages.ageRequired;
    }
    try {
      final age = int.parse(value);
      if (age < 1 || age > 150) {
        return AppMessages.ageInvalid;
      }
    } catch (e) {
      return AppMessages.ageInvalid;
    }
    return null;
  }

  /// التحقق من المبلغ
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return AppMessages.amountRequired;
    }
    try {
      final amount = double.parse(value);
      if (amount <= 0) {
        return AppMessages.amountInvalid;
      }
    } catch (e) {
      return AppMessages.amountInvalid;
    }
    return null;
  }

  /// التحقق من اسم الشخص
  static String? validatePersonName(String? value) {
    if (value == null || value.isEmpty) {
      return AppMessages.personNameRequired;
    }
    if (value.length < 2) {
      return 'الاسم يجب أن يكون أكثر من 2 حروف';
    }
    return null;
  }

  /// التحقق من الوصف
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return AppMessages.descriptionRequired;
    }
    if (value.length < 2) {
      return 'الوصف يجب أن يكون أكثر من 2 حروف';
    }
    return null;
  }

  /// التحقق من اسم المنتج
  static String? validateItemName(String? value) {
    if (value == null || value.isEmpty) {
      return AppMessages.itemNameRequired;
    }
    if (value.length < 2) {
      return 'اسم المنتج يجب أن يكون أكثر من 2 حروف';
    }
    return null;
  }

  /// التحقق من صحة البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  /// التحقق من صحة رقم الهاتف
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    final phoneRegex = RegExp(r'^[0-9+\-\s()]{7,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  /// التحقق من حقل مطلوب
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }
}
