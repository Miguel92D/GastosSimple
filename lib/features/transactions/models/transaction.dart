// lib/models/transaction.dart
class Transaction {
  final int? id;
  final double amount;
  final String category;
  final String type; // "gasto" or "ingreso"
  final DateTime date;
  final int isSecret; // 0 = normal, 1 = secret
  final String? note;
  final bool isRecurring;
  final int? goalId;
  final double? goalAmount;

  Transaction({
    this.id,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.isSecret = 0,
    this.note,
    this.isRecurring = false,
    this.goalId,
    this.goalAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'type': type,
      'date': date.toIso8601String(),
      'is_secret': isSecret,
      'note': note,
      'is_recurring': isRecurring ? 1 : 0,
      'goal_id': goalId,
      'goal_amount': goalAmount,
    };
  }

  Transaction copyWith({
    int? id,
    double? amount,
    String? category,
    String? type,
    DateTime? date,
    int? isSecret,
    String? note,
    bool? isRecurring,
    int? goalId,
    double? goalAmount,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
      isSecret: isSecret ?? this.isSecret,
      note: note ?? this.note,
      isRecurring: isRecurring ?? this.isRecurring,
      goalId: goalId ?? this.goalId,
      goalAmount: goalAmount ?? this.goalAmount,
    );
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: (map['amount'] ?? map['monto'] ?? 0.0).toDouble(),
      category: map['category'] ?? map['categoria'] ?? 'Otros',
      type: map['type'] ?? map['tipo'] ?? 'expense',
      date: DateTime.parse(map['date'] ?? map['fecha']),
      isSecret: map['is_secret'] ?? map['archived'] ?? 0,
      note: map['note'] ?? map['nota'],
      isRecurring: (map['is_recurring'] ?? 0) == 1,
      goalId: map['goal_id'],
      goalAmount: (map['goal_amount'] ?? 0.0).toDouble(),
    );
  }
}
