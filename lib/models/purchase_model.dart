/// نموذج بيانات المشترى
class PurchaseModel {
  final String id;
  final String itemName;
  final double price;
  final DateTime purchaseDate;
  final String? category;
  final String? notes;

  PurchaseModel({
    String? id,
    required this.itemName,
    required this.price,
    DateTime? purchaseDate,
    this.category,
    this.notes,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        purchaseDate = purchaseDate ?? DateTime.now();

  /// التحقق من صحة البيانات
  bool isValid() {
    return itemName.isNotEmpty && price > 0;
  }

  /// الحصول على المجموع مع الضرائب (إن وجدت)
  double getTotalWithTax({double taxPercentage = 0}) {
    return price * (1 + taxPercentage / 100);
  }

  /// نسخ النموذج مع تغيير بعض الخصائص
  PurchaseModel copyWith({
    String? id,
    String? itemName,
    double? price,
    DateTime? purchaseDate,
    String? category,
    String? notes,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      price: price ?? this.price,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() =>
      'PurchaseModel(id: $id, itemName: $itemName, price: $price)';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'price': price,
      'purchaseDate': purchaseDate.toIso8601String(),
      'category': category,
      'notes': notes,
    };
  }

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'],
      itemName: json['itemName'],
      price: json['price'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      category: json['category'],
      notes: json['notes'],
    );
  }
}
