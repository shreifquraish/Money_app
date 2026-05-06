# 🔧 دليل المطور

## نظرة عامة

هذا الملف يوضح الهيكل الداخلي للتطبيق ويساعدك على إضافة ميزات جديدة.

---

## 📁 هيكل المشروع

```
lib/
│
├── main.dart                          # نقطة الدخول الرئيسية
│
├── models/                            # نماذج البيانات
│   ├── user_model.dart               # نموذج المستخدم
│   ├── purchase_model.dart           # نموذج المشترى
│   ├── debt_model.dart               # نموذج الدين
│   └── money_model.dart              # نموذج الأموال
│
├── pages/                             # الصفحات الرئيسية
│   ├── login_page.dart               # صفحة تسجيل الدخول
│   ├── home_page.dart                # الصفحة الرئيسية
│   ├── purchases_page.dart           # صفحة المشتريات
│   ├── debts_page.dart               # صفحة الديون
│   └── money_management_page.dart    # صفحة إدارة الأموال
│
├── widgets/                           # العناصر المخصصة
│   └── custom_widgets.dart           # جميع Custom Widgets
│
├── constants/                         # الثوابت والإعدادات
│   ├── app_constants.dart            # الثوابت الأساسية
│   └── app_theme.dart                # نظام الثيم
│
└── utils/                             # دوال مساعدة
    ├── validators.dart               # دوال التحقق
    ├── formatters.dart               # دوال التنسيق
    └── helpers.dart                  # دوال مساعدة أخرى
```

---

## 📊 نماذج البيانات (Models)

### UserModel
```dart
UserModel({
  required String name,
  required int age,
  DateTime? createdAt,
})

// الدوال
- isValid(): bool                     // التحقق من الصحة
- copyWith({...}): UserModel         // نسخ مع تغييرات
```

### PurchaseModel
```dart
PurchaseModel({
  String? id,
  required String itemName,
  required double price,
  DateTime? purchaseDate,
  String? category,
  String? notes,
})

// الدوال
- isValid(): bool                     // التحقق من الصحة
- getTotalWithTax(double): double    // الحساب مع الضرائب
- copyWith({...}): PurchaseModel     // نسخ مع تغيييرات
```

### DebtModel
```dart
DebtModel({
  String? id,
  required String personName,
  required double amount,
  DateTime? debtDate,
  DateTime? dueDate,
  String? notes,
  bool isPaid = false,
})

// الدوال
- isValid(): bool                     // التحقق من الصحة
- getDaysUntilDue(): int?            // حساب الأيام المتبقية
- isOverdue(): bool                  // التحقق من التأخير
- copyWith({...}): DebtModel         // نسخ مع تغييرات
```

### MoneyModel
```dart
MoneyModel({
  String? id,
  required String description,
  required double amount,
  required MoneyType type,           // income, expense, saving
  DateTime? date,
  String? source,
  String? notes,
})

// الدوال
- isValid(): bool                     // التحقق من الصحة
- copyWith({...}): MoneyModel        // نسخ مع تغييرات
```

---

## 🎨 ثوابت وألوان (Constants)

### AppColors
```dart
// الألوان الأساسية
AppColors.primaryColor           // Color(0xFF5B6DEF)
AppColors.secondaryColor         // Color(0xFFFF6B6B)

// الحالات
AppColors.successColor           // أخضر
AppColors.warningColor           // برتقالي
AppColors.errorColor             // أحمر
AppColors.infoColor              // تركواز

// العمليات المالية
AppColors.incomeColor            // أخضر
AppColors.expenseColor           // أحمر
AppColors.savingColor            // تركواز
AppColors.debtColor              // بنفسجي
```

### AppPadding (المسافات)
```dart
AppPadding.xs   // 4
AppPadding.sm   // 8
AppPadding.md   // 12
AppPadding.lg   // 16
AppPadding.xl   // 24
AppPadding.xxl  // 32
```

### AppRadius (أنصاف الأقطار)
```dart
AppRadius.xs       // 4
AppRadius.sm       // 8
AppRadius.md       // 12
AppRadius.lg       // 16
AppRadius.xl       // 24
AppRadius.circle   // 999
```

### AppFontSizes (أحجام الخطوط)
```dart
AppFontSizes.xs    // 10
AppFontSizes.sm    // 12
AppFontSizes.base  // 14
AppFontSizes.lg    // 16
AppFontSizes.xl    // 18
AppFontSizes.xxl   // 24
AppFontSizes.xxxl  // 32
AppFontSizes.h1    // 36
```

---

## 🎯 العناصر المخصصة (Custom Widgets)

### CustomTextField
```dart
CustomTextField(
  controller: TextEditingController,
  label: String?,                    // تسمية الحقل
  hintText: String?,                 // نص مساعد
  validator: String Function(String?)?  // دالة التحقق
  keyboardType: TextInputType,       // نوع لوحة المفاتيح
  maxLines: int?,
  minLines: int?,
  obscureText: bool,
  prefixIcon: Widget?,               // أيقونة في البداية
  suffixIcon: Widget?,               // أيقونة في النهاية
  onChanged: ValueChanged<String>?,
  textInputAction: TextInputAction?,
)
```

**الاستخدام**:
```dart
CustomTextField(
  controller: nameController,
  label: 'الاسم',
  hintText: 'أدخل اسمك',
  validator: Validators.validateName,
  prefixIcon: const Icon(Icons.person),
)
```

### CustomButton
```dart
CustomButton(
  label: String,                     // نص الزر
  onPressed: VoidCallback,           // دالة عند الضغط
  isLoading: bool,                   // حالة التحميل
  width: double?,
  height: double,
  icon: Widget?,
  backgroundColor: Color?,
  foregroundColor: Color?,
  padding: EdgeInsets?,
)
```

**الاستخدام**:
```dart
CustomButton(
  label: 'إضافة',
  onPressed: () => _handleAdd(),
  isLoading: _isLoading,
  backgroundColor: AppColors.primaryColor,
)
```

### CustomCard
```dart
CustomCard(
  child: Widget,                     // المحتوى
  padding: EdgeInsets?,
  elevation: double,
  backgroundColor: Color?,
  borderRadius: BorderRadius?,
  onTap: VoidCallback?,              // عند الضغط
)
```

**الاستخدام**:
```dart
CustomCard(
  child: Column(
    children: [...],
  ),
  onTap: () => print('Tapped'),
)
```

### CustomGradientHeader
```dart
CustomGradientHeader(
  title: String,
  subtitle: String?,
  gradientColors: List<Color>,
  child: Widget?,
  padding: EdgeInsets?,
  height: double?,
)
```

### EmptyStateWidget
```dart
EmptyStateWidget(
  icon: IconData,
  title: String,
  subtitle: String?,
  onActionPressed: VoidCallback?,
  actionLabel: String?,
  iconColor: Color?,
)
```

### MoneyDisplayWidget
```dart
MoneyDisplayWidget(
  amount: double,
  label: String,
  color: Color?,
  currencySymbol: String,
)
```

---

## ✔️ Validators (دوال التحقق)

```dart
// الاسم
Validators.validateName(String?)
// يتحقق: غير فارغ + أكثر من حرفين

// السن
Validators.validateAge(String?)
// يتحقق: غير فارغ + رقم + بين 1-150

// المبلغ
Validators.validateAmount(String?)
// يتحقق: غير فارغ + رقم + أكبر من 0

// اسم الشخص
Validators.validatePersonName(String?)
// يتحقق: غير فارغ + أكثر من حرفين

// الوصف
Validators.validateDescription(String?)
// يتحقق: غير فارغ + أكثر من حرفين

// اسم المنتج
Validators.validateItemName(String?)
// يتحقق: غير فارغ + أكثر من حرفين

// البريد الإلكتروني
Validators.validateEmail(String?)

// رقم الهاتف
Validators.validatePhoneNumber(String?)

// حقل مطلوب
Validators.validateRequired(String?, String fieldName)
```

---

## 📝 Formatters (دوال التنسيق)

### تنسيق الأموال
```dart
Formatters.formatCurrency(1234.56)
// النتيجة: "1234.56"

Formatters.formatCurrencyWithSymbol(1234.56)
// النتيجة: "1234.56 جنيه"

Formatters.formatNumber(1000000)
// النتيجة: "1,000,000"
```

### تنسيق التواريخ
```dart
Formatters.formatDate(DateTime.now())
// النتيجة: "2026-04-22"

Formatters.formatTime(DateTime.now())
// النتيجة: "14:30"

Formatters.formatDateTime(DateTime.now())
// النتيجة: "2026-04-22 14:30"

Formatters.formatDateReadable(DateTime.now())
// النتيجة: "22 أبريل 2026"
```

### الفروقات الزمنية
```dart
Formatters.getDateDifference(date1, date2)
// النتيجة: "اليوم" أو "أمس" أو "غدا" أو "منذ 3 أيام"
```

---

## 📢 Helpers (دوال مساعدة)

### SnackBarService
```dart
// رسالة نجاح
SnackBarService.showSuccess(context, 'تم بنجاح')

// رسالة خطأ
SnackBarService.showError(context, 'حدث خطأ')

// رسالة تحذير
SnackBarService.showWarning(context, 'تحذير')

// رسالة معلومات
SnackBarService.showInfo(context, 'معلومة')
```

### DialogService
```dart
// طلب تأكيد
final confirmed = await DialogService.showConfirmDialog(
  context,
  title: 'تأكيد',
  message: 'هل أنت متأكد؟',
  confirmText: 'نعم',
  cancelText: 'لا',
);

// dialog بسيط
await DialogService.showSimpleDialog(
  context,
  title: 'رسالة',
  message: 'محتوى الرسالة',
);
```

---

## 🔧 إنشاء صفحة جديدة

### الخطوات:
1. **أنشئ نموذج البيانات** (إن لزم الأمر)
```dart
// lib/models/new_model.dart
class NewModel {
  final String id;
  final String name;
  // ... الخصائص
  
  bool isValid() => name.isNotEmpty;
  NewModel copyWith({String? name}) => NewModel(name: name ?? this.name);
}
```

2. **أنشئ الصفحة**
```dart
// lib/pages/new_page.dart
import '../constants/app_constants.dart';
import '../widgets/custom_widgets.dart';
import '../utils/validators.dart';

class NewPage extends StatefulWidget {
  const NewPage({super.key});
  
  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الصفحة الجديدة')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              controller: _controller,
              label: 'الاسم',
              validator: Validators.validateName,
            ),
            CustomButton(
              label: 'إضافة',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
```

3. **أضف الصفحة إلى التوجيه** (في `main.dart`)
```dart
routes: {
  '/new': (context) => const NewPage(),
}
```

4. **استخدم الصفحة**
```dart
Navigator.pushNamed(context, '/new');
```

---

## 🚀 إضافة ميزة جديدة

### مثال: إضافة فئات للمشتريات

1. **عدّل نموذج البيانات**
```dart
enum PurchaseCategory {
  food('الطعام'),
  electronics('الإلكترونيات'),
  clothing('الملابس');
  
  final String displayName;
  const PurchaseCategory(this.displayName);
}

class PurchaseModel {
  // ... الخصائص السابقة
  final PurchaseCategory? category;
}
```

2. **أضف خيارات الاختيار في الصفحة**
```dart
Wrap(
  children: [
    for (final category in PurchaseCategory.values)
      FilterChip(
        label: Text(category.displayName),
        selected: _selectedCategory == category,
        onSelected: (selected) {
          setState(() => _selectedCategory = category);
        },
      ),
  ],
)
```

3. **استخدم في المنطق**
```dart
final purchase = PurchaseModel(
  itemName: _itemController.text,
  price: double.parse(_priceController.text),
  category: _selectedCategory,
);
```

---

## 🧪 الاختبار والتصحيح

### طباعة المعلومات
```dart
print('Debug: $variable');
```

### التحقق من النموذج
```dart
if (!model.isValid()) {
  SnackBarService.showError(context, 'البيانات غير صحيحة');
  return;
}
```

### التحقق من الأخطاء
```dart
try {
  // العملية
} catch (e) {
  if (mounted) {
    SnackBarService.showError(context, 'خطأ: $e');
  }
}
```

---

## 📦 الحزم المستخدمة

### الحزم الأساسية
- `flutter`: إطار العمل الأساسي
- `flutter_bloc`: إدارة الحالة (قد تُضاف لاحقاً)

---

## 📝 معايير الكود

### تسمية الملفات
- استخدم `snake_case` للملفات
- أمثلة: `login_page.dart`, `custom_widgets.dart`

### تسمية الفئات والدوال
- استخدم `PascalCase` للفئات
- استخدم `camelCase` للدوال والمتغيرات
- أمثلة: `LoginPage`, `validateName()`

### التعليقات
```dart
/// توثيق المستند للفئات والدوال العامة
class MyClass {
  /// وصف الدالة
  void myMethod() {}
}

// تعليق سطر واحد
// للشرح المحدود

/* تعليق متعدد الأسطر
   للشروحات الطويلة */
```

---

## 💾 حفظ البيانات (المستقبل)

عند إضافة حفظ دائم:
```dart
import 'package:shared_preferences/shared_preferences.dart';

// أو

import 'package:sqflite/sqflite.dart';

// أو

import 'package:hive/hive.dart';
```

---

## 🎓 موارد إضافية

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language](https://dart.dev)
- [Material Design](https://material.io/design)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)

---

**هذا هو دليل المطور الشامل للتطبيق. استمتع بالتطوير! 🚀**
