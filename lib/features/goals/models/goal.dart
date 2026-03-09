class Goal {
  final int? id;
  final String name;
  final double targetAmount;
  final double savedAmount;

  Goal({
    this.id,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'saved_amount': savedAmount,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      name: map['name'],
      targetAmount: map['target_amount'],
      savedAmount: map['saved_amount'] ?? 0.0,
    );
  }
}
