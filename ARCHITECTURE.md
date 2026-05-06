# 🏗️ البنية المعمارية للتطبيق

## نظرة عامة

تم تصميم التطبيق باستخدام **معمارية نظيفة وقابلة للتوسع** تتبع أفضل الممارسات في تطوير تطبيقات Flutter.

---

## 📊 الطبقات المعمارية

```
┌─────────────────────────────────────┐
│      Presentation Layer (UI)         │
│  - Pages                             │
│  - Widgets                           │
└─────────────────────┬───────────────┘
                      │
┌─────────────────────▼───────────────┐
│   Business Logic Layer                │
│  - Validators                         │
│  - Formatters                         │
│  - Helpers                            │
└─────────────────────┬───────────────┘
                      │
┌─────────────────────▼───────────────┐
│      Data Layer                       │
│  - Models                             │
│  - Data management                    │
└─────────────────────────────────────┘
```

---

## 1️⃣ Presentation Layer (طبقة العرض)

### الوظيفة
التعامل مع واجهة المستخدم والعمليات المرئية.

### المكونات

#### Pages (الصفحات)
```
lib/pages/
├── login_page.dart          # صفحة تسجيل الدخول
├── home_page.dart           # الصفحة الرئيسية
├── purchases_page.dart      # صفحة المشتريات
├── debts_page.dart          # صفحة الديون
└── money_management_page.dart # صفحة إدارة الأموال
```

**مسؤوليات الصفحة**:
- بناء الواجهة
- إدارة الحالة المحلية
- التعامل مع تفاعلات المستخدم
- استدعاء الدوال المساعدة

#### Widgets (العناصر)
```
lib/widgets/
└── custom_widgets.dart
    ├── CustomTextField      # حقل إدخال مخصص
    ├── CustomButton        # زر مخصص
    ├── CustomCard          # بطاقة مخصصة
    ├── CustomGradientHeader # رأس بتدرج
    ├── EmptyStateWidget    # حالة فارغة
    └── MoneyDisplayWidget  # عرض الأموال
```

**مميزات العناصر**:
- ✅ قابلة لإعادة الاستخدام
- ✅ مستقلة عن بعضها
- ✅ قابلة للتخصيص
- ✅ توفر أداء أفضل

---

## 2️⃣ Business Logic Layer (طبقة المنطق)

### الوظيفة
معالجة العمليات المنطقية والتحقق والتنسيق.

### المكونات

#### Validators (المدققات)
```dart
Validators.validateName()
Validators.validateAge()
Validators.validateAmount()
Validators.validatePersonName()
Validators.validateDescription()
Validators.validateItemName()
```

**المسؤوليات**:
- ✅ التحقق من صحة البيانات
- ✅ إرجاع رسائل خطأ واضحة
- ✅ معالجة الاستثناءات

#### Formatters (منسقات البيانات)
```dart
Formatters.formatCurrency()
Formatters.formatDate()
Formatters.formatDateTime()
Formatters.formatNumber()
```

**المسؤوليات**:
- ✅ تنسيق البيانات للعرض
- ✅ تحويل الأنواع
- ✅ توحيد الصيغ

#### Helpers (دوال مساعدة)
```dart
SnackBarService   // الإشعارات
DialogService     // الـ Dialogs
```

**المسؤوليات**:
- ✅ عرض الرسائل
- ✅ طلب التأكيدات
- ✅ التعامل مع الإدخال

---

## 3️⃣ Data Layer (طبقة البيانات)

### الوظيفة
تمثيل البيانات وتخزينها.

### المكونات

#### Models (النماذج)
```
lib/models/
├── user_model.dart         # نموذج المستخدم
├── purchase_model.dart     # نموذج المشترى
├── debt_model.dart         # نموذج الدين
└── money_model.dart        # نموذج العملية المالية
```

**مميزات النماذج**:
- ✅ تحتوي على منطق التحقق
- ✅ توفر نسخ معدلة (copyWith)
- ✅ توفر تمثيل نصي (toString)
- ✅ محددة الأنواع (Type-safe)

---

## 🔄 دورة حياة البيانات

### مثال: إضافة مشترى

```
1. المستخدم يملأ النموذج
   └─> CustomTextField يجمع البيانات

2. التحقق من الصحة
   └─> Validators.validateItemName()
   └─> Validators.validateAmount()

3. إنشاء النموذج
   └─> PurchaseModel(itemName, price)

4. التحقق من النموذج
   └─> purchase.isValid()

5. إضافة إلى الحالة
   └─> setState(() => purchases.add(purchase))

6. عرض رسالة نجاح
   └─> SnackBarService.showSuccess()

7. إعادة تحميل الواجهة
   └─> BUilد الحالة مع البيانات الجديدة
```

---

## 📦 إدارة الحالة

### الحالة المحلية (Local State)
كل صفحة تدير حالتها المحلية:
```dart
class _PurchasesPageState extends State<PurchasesPage> {
  List<PurchaseModel> _purchases = [];
  
  void _addPurchase() {
    setState(() {
      _purchases.add(purchase);
    });
  }
}
```

### مستقبل: إدارة حالة عامة
يمكن إضافة `GetX` أو `BLoC` لاحقاً:
```dart
// في المستقبل
class PurchaseController extends GetxController {
  RxList<PurchaseModel> purchases = <PurchaseModel>[].obs;
  
  void addPurchase(PurchaseModel purchase) {
    purchases.add(purchase);
  }
}
```

---

## 🎯 مسار العملية من البداية إلى النهاية

### عملية: إضافة دين جديد

#### 1. صفحة الديون (DebtsPage)
```dart
// في التصميم
CustomTextField(
  controller: _personNameController,
  validator: Validators.validatePersonName,
)

// في الحدث
Future<void> _addDebt() async {
  if (!_formKey.currentState!.validate()) {
    SnackBarService.showError(context, 'البيانات غير صحيحة');
    return;
  }
  // ... المزيد
}
```

#### 2. التحقق (Validators)
```dart
// في validators.dart
static String? validatePersonName(String? value) {
  if (value == null || value.isEmpty) {
    return AppMessages.personNameRequired;
  }
  if (value.length < 2) {
    return 'الاسم يجب أن يكون أكثر من 2 حروف';
  }
  return null;
}
```

#### 3. النموذج (DebtModel)
```dart
// في models/debt_model.dart
final debt = DebtModel(
  personName: _personNameController.text.trim(),
  amount: double.parse(_amountController.text.trim()),
);

if (!debt.isValid()) {
  SnackBarService.showError(context, 'البيانات غير صحيحة');
  return;
}
```

#### 4. التنسيق (Formatters)
```dart
// في widgets/custom_widgets.dart
Text(
  Formatters.formatCurrencyWithSymbol(debt.amount),
  style: Theme.of(context).textTheme.titleMedium,
)
```

#### 5. عرض الرسالة (Helpers)
```dart
// في صفحة الديون
SnackBarService.showSuccess(context, 'تم إضافة الدين بنجاح');
```

---

## 🔐 الثوابت والإعدادات

### AppConstants
```dart
// في constants/app_constants.dart
class AppColors { ... }
class AppPadding { ... }
class AppRadius { ... }
class AppFontSizes { ... }
class AppMessages { ... }
```

### AppTheme
```dart
// في constants/app_theme.dart
class AppTheme {
  static ThemeData get lightTheme { ... }
}
```

---

## 🚀 تدفق الشاشات

```
┌──────────────┐
│  LoginPage   │
└────┬─────────┘
     │ Navigate
     ▼
┌──────────────┐
│  HomePage    │◄─── Default Page
└────┬────┬────┘
     │    │
     │    └──┬──────────────────┐
     │       │                  │
     ▼       ▼                  ▼
┌─────────┐┌──────────────┐┌──────────────┐
│Purchases││ MoneyMgmt    ││  (Settings)  │
│ Page    ││   Page       ││   (Future)   │
└─────────┘└──────────────┘└──────────────┘
     │
     └──┬────────────┐
         │           │
         ▼           ▼
    ┌─────────┐ ┌──────────┐
    │  Debts  │ │ Details  │
    │  Page   │ │  (Future)│
    └─────────┘ └──────────┘
```

---

## 📈 قابلية التوسع

### إضافة ميزة جديدة

```
1. أنشئ نموذج البيانات (model)
   └─> models/new_feature_model.dart

2. أنشئ الصفحة (page)
   └─> pages/new_feature_page.dart

3. أضف validators (إذا لزم الأمر)
   └─> أضف إلى utils/validators.dart

4. أضف formatters (إذا لزم الأمر)
   └─> أضف إلى utils/formatters.dart

5. أضف التوجيه (routing)
   └─> سجل في main.dart

6. أضف الأيقونة والألوان
   └─> أضف إلى constants/app_constants.dart
```

---

## 🔄 دورة الحياة

### صفحة StatefulWidget

```dart
class MyPage extends StatefulWidget {
  // 1. إنشاء الحالة
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  // 2. التهيئة
  @override
  void initState() {
    super.initState();
    // تهيئة التحكم والبيانات
  }

  // 3. البناء
  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }

  // 4. التنظيف
  @override
  void dispose() {
    // تنظيف الموارد
    super.dispose();
  }
}
```

---

## 🎨 تدفق التنسيق

```
النص الخام
    │
    ▼
Validators      ← التحقق من الصحة
    │
    ▼
Formatters      ← تنسيق العرض
    │
    ▼
Widgets         ← عرض في الواجهة
    │
    ▼
Theme           ← تطبيق الأنماط
    │
    ▼
عرض نهائي
```

---

## 📊 مخطط الأنواع

```
Models (من الملفات والإدخال)
  │
  ├─ UserModel
  ├─ PurchaseModel
  ├─ DebtModel
  └─ MoneyModel
       │
       ▼
Validators (التحقق)
       │
       ▼
Formatters (التنسيق)
       │
       ▼
Widgets (العرض)
       │
       ▼
State Management (إدارة الحالة)
       │
       ▼
Theme (الأسلوب)
       │
       ▼
User Interface (الواجهة النهائية)
```

---

## 🛡️ معالجة الأخطاء

```dart
// في كل عملية
try {
  // 1. التحقق
  if (!_formKey.currentState!.validate()) {
    SnackBarService.showError(context, 'البيانات غير صحيحة');
    return;
  }

  // 2. إنشاء النموذج
  final model = MyModel(...);

  // 3. التحقق من النموذج
  if (!model.isValid()) {
    SnackBarService.showError(context, 'النموذج غير صحيح');
    return;
  }

  // 4. العملية
  setState(() => items.add(model));

  // 5. رسالة النجاح
  SnackBarService.showSuccess(context, 'تم بنجاح');
} catch (e) {
  // 6. معالجة الاستثناءات
  SnackBarService.showError(context, 'خطأ: $e');
}
```

---

## 📝 التوثيق

### توثيق الفئات
```dart
/// فئة لتمثيل المستخدم
/// تحتوي على البيانات الأساسية للمستخدم
class UserModel {
  /// اسم المستخدم
  final String name;
  
  /// سن المستخدم
  final int age;
}
```

### توثيق الدوال
```dart
/// التحقق من صحة اسم المستخدم
/// 
/// يتحقق من:
/// - أن الاسم غير فارغ
/// - أن طول الاسم أكثر من 2 حروف
/// 
/// يرجع:
/// - null إذا كان صحيحاً
/// - رسالة خطأ إذا كان غير صحيح
static String? validateName(String? value) { ... }
```

---

## 🎯 الخلاصة

البنية المعمارية:
- ✅ **منظمة**: كل شيء في مكانه المناسب
- ✅ **قابلة للتوسع**: سهل إضافة ميزات جديدة
- ✅ **قابلة للصيانة**: سهل فهم الكود وتعديله
- ✅ **آمنة**: معالجة شاملة للأخطاء
- ✅ **احترافية**: تتبع أفضل الممارسات

**هذا هو أساس تطبيق احترافي وقابل للنمو! 🚀**
