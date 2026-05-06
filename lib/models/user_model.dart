/// نموذج بيانات المستخدم
class UserModel {
  final String name;
  final int age;
  final DateTime createdAt;

  UserModel({
    required this.name,
    required this.age,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// التحقق من صحة بيانات المستخدم
  bool isValid() {
    return name.isNotEmpty && age > 0 && age < 150;
  }

  /// نسخ النموذج مع تغيير بعض الخصائص
  UserModel copyWith({
    String? name,
    int? age,
    DateTime? createdAt,
  }) {
    return UserModel(
      name: name ?? this.name,
      age: age ?? this.age,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'UserModel(name: $name, age: $age)';
}
