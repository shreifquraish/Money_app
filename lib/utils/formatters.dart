/// فئة مساعدة للتنسيق والمعالجة
class Formatters {
  /// تنسيق المبلغ مع الفاصلة العشرية
  static String formatCurrency(double amount) {
    return amount.toStringAsFixed(2);
  }

  /// تنسيق المبلغ مع العملة
  static String formatCurrencyWithSymbol(double amount, {String symbol = 'جنيه'}) {
    return '${formatCurrency(amount)} $symbol';
  }

  /// تنسيق التاريخ
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// تنسيق الوقت
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// تنسيق التاريخ والوقت
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// تنسيق التاريخ بصيغة مقروءة
  static String formatDateReadable(DateTime date) {
    const monthNames = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  /// تنسيق الأرقام بفواصل
  static String formatNumber(num number) {
    return number.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (Match m) => ',',
        );
  }

  /// حساب الفرق بين التاريخين
  static String getDateDifference(DateTime date1, DateTime date2) {
    final difference = date1.difference(date2).inDays;
    if (difference == 0) {
      return 'اليوم';
    } else if (difference == 1) {
      return 'غدا';
    } else if (difference == -1) {
      return 'أمس';
    } else if (difference > 0) {
      return 'بعد $difference أيام';
    } else {
      return 'منذ ${difference.abs()} أيام';
    }
  }
}
