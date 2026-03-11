class SavingsGoal {
  final int? id;
  final String name;
  final double currentAmount;
  final double targetAmount;
  final DateTime targetDate;
  final String icon;
  final DateTime createdAt;

  SavingsGoal({
    this.id,
    required this.name,
    this.currentAmount = 0.0,
    required this.targetAmount,
    required this.targetDate,
    required this.icon,
    required this.createdAt,
  });

  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'currentAmount': currentAmount,
      'targetAmount': targetAmount,
      'targetDate': targetDate.toIso8601String(),
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      name: map['name'],
      currentAmount: map['currentAmount'] ?? 0.0,
      targetAmount: map['targetAmount'],
      targetDate: DateTime.parse(map['targetDate']),
      icon: map['icon'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  SavingsGoal copyWith({
    int? id,
    String? name,
    double? currentAmount,
    double? targetAmount,
    DateTime? targetDate,
    String? icon,
    DateTime? createdAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      currentAmount: currentAmount ?? this.currentAmount,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
