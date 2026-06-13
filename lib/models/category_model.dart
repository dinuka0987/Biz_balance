import 'transaction.dart';

class CategoryModel {
  final String id;
  final String name;
  final TransactionType type;
  final String color; // Hex color string e.g. '#10B981'
  final String icon; // Icon name string

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type == TransactionType.income ? 'income' : 'expense',
        'name': name,
        'color': color,
        'icon': icon,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] == 'income'
            ? TransactionType.income
            : TransactionType.expense,
        color: json['color'] as String,
        icon: json['icon'] as String,
      );
}
