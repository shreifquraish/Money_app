/// نموذج بيانات الأموال والدخل
class MoneyModel {
  final String id;
  final String description;
  final double amount;
  final MoneyType type;
  final DateTime date;
  final String? source;
  final String? notes;

  MoneyModel({
    String? id,
    required this.description,
    required this.amount,
    required this.type,
    DateTime? date,
    this.source,
    this.notes,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date = date ?? DateTime.now();

  /// التحقق من صحة البيانات
  bool isValid() {
    return description.isNotEmpty && amount > 0;
  }

  /// نسخ النموذج مع تغيير بعض الخصائص
  MoneyModel copyWith({
    String? id,
    String? description,
    double? amount,
    MoneyType? type,
    DateTime? date,
    String? source,
    String? notes,
  }) {
    return MoneyModel(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      source: source ?? this.source,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() =>
      'MoneyModel(id: $id, description: $description, amount: $amount, type: $type)';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type.name,
      'date': date.toIso8601String(),
      'source': source,
      'notes': notes,
    };
  }

  factory MoneyModel.fromJson(Map<String, dynamic> json) {
    return MoneyModel(
      id: json['id'],
      description: json['description'],
      amount: json['amount'],
      type: MoneyType.values.firstWhere((e) => e.name == json['type']),
      date: DateTime.parse(json['date']),
      source: json['source'],
      notes: json['notes'],
    );
  }
}

/// نوع الأموال
enum MoneyType {
  income('دخل'),
  expense('مصروف'),
  saving('توفير');

  final String displayName;
  const MoneyType(this.displayName);
}
