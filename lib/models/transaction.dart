enum TransactionType { income, expense }

class Transaction {
  final String id;
  final TransactionType type;
  final String category;
  final double amount;
  final String date; // YYYY-MM-DD
  final String? notes;
  final String? source;

  Transaction({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.notes,
    this.source,
  });

  Transaction copyWith({
    String? id,
    TransactionType? type,
    String? category,
    double? amount,
    String? date,
    String? notes,
    String? source,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type == TransactionType.income ? 'income' : 'expense',
        'category': category,
        'amount': amount,
        'date': date,
        'notes': notes,
        'source': source,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        type: json['type'] == 'income'
            ? TransactionType.income
            : TransactionType.expense,
        category: json['category'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: json['date'] as String,
        notes: json['notes'] as String?,
        source: json['source'] as String?,
      );
}
