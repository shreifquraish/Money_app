/// نموذج بيانات الدين
class DebtModel {
  final String id;
  final String personName;
  final double amount;
  final DateTime debtDate;
  final DateTime? dueDate;
  final String? notes;
  final bool isPaid;

  DebtModel({
    String? id,
    required this.personName,
    required this.amount,
    DateTime? debtDate,
    this.dueDate,
    this.notes,
    this.isPaid = false,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        debtDate = debtDate ?? DateTime.now();

  /// التحقق من صحة البيانات
  bool isValid() {
    return personName.isNotEmpty && amount > 0;
  }

  /// حساب عدد الأيام المتبقية حتى موعد الاستحقاق
  int? getDaysUntilDue() {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  /// التحقق من تجاوز موعد الاستحقاق
  bool isOverdue() {
    if (dueDate == null || isPaid) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// نسخ النموذج مع تغيير بعض الخصائص
  DebtModel copyWith({
    String? id,
    String? personName,
    double? amount,
    DateTime? debtDate,
    DateTime? dueDate,
    String? notes,
    bool? isPaid,
  }) {
    return DebtModel(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      debtDate: debtDate ?? this.debtDate,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  @override
  String toString() =>
      'DebtModel(id: $id, personName: $personName, amount: $amount, isPaid: $isPaid)';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personName': personName,
      'amount': amount,
      'debtDate': debtDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'notes': notes,
      'isPaid': isPaid,
    };
  }

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'],
      personName: json['personName'],
      amount: json['amount'],
      debtDate: DateTime.parse(json['debtDate']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      notes: json['notes'],
      isPaid: json['isPaid'] ?? false,
    );
  }
}
