class Budget {
  final String id;
  final String category; // Category name
  final double amount;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
  });

  Budget copyWith({
    String? id,
    String? category,
    double? amount,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'amount': amount,
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        id: json['id'] as String,
        category: json['category'] as String,
        amount: (json['amount'] as num).toDouble(),
      );
}
