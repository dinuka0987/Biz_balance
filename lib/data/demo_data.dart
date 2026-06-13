import '../models/budget.dart';
import '../models/category_model.dart';
import '../models/transaction.dart';

final List<CategoryModel> defaultCategories = [
  // Income Categories
  CategoryModel(
    id: 'i1',
    name: 'Product Sales',
    type: TransactionType.income,
    color: '#10B981',
    icon: 'ShoppingBag',
  ),
  CategoryModel(
    id: 'i2',
    name: 'Service Fees',
    type: TransactionType.income,
    color: '#3B82F6',
    icon: 'Wrench',
  ),
  CategoryModel(
    id: 'i3',
    name: 'Consulting',
    type: TransactionType.income,
    color: '#8B5CF6',
    icon: 'Users',
  ),
  CategoryModel(
    id: 'i4',
    name: 'Commission',
    type: TransactionType.income,
    color: '#F59E0B',
    icon: 'DollarSign',
  ),
  CategoryModel(
    id: 'i5',
    name: 'Investments',
    type: TransactionType.income,
    color: '#06B6D4',
    icon: 'Coins',
  ),
  CategoryModel(
    id: 'i6',
    name: 'Other Income',
    type: TransactionType.income,
    color: '#6B7280',
    icon: 'Briefcase',
  ),

  // Expense Categories
  CategoryModel(
    id: 'e1',
    name: 'Stock / Inventory',
    type: TransactionType.expense,
    color: '#EF4444',
    icon: 'Package',
  ),
  CategoryModel(
    id: 'e2',
    name: 'Rent / Leasing',
    type: TransactionType.expense,
    color: '#F97316',
    icon: 'Store',
  ),
  CategoryModel(
    id: 'e3',
    name: 'Employee Salaries',
    type: TransactionType.expense,
    color: '#6366F1',
    icon: 'Users',
  ),
  CategoryModel(
    id: 'e4',
    name: 'Utilities & Power',
    type: TransactionType.expense,
    color: '#EAB308',
    icon: 'Zap',
  ),
  CategoryModel(
    id: 'e5',
    name: 'Logistics / Transport',
    type: TransactionType.expense,
    color: '#84CC16',
    icon: 'Truck',
  ),
  CategoryModel(
    id: 'e6',
    name: 'Marketing & Ads',
    type: TransactionType.expense,
    color: '#EC4899',
    icon: 'Megaphone',
  ),
  CategoryModel(
    id: 'e7',
    name: 'Software / SaaS',
    type: TransactionType.expense,
    color: '#0EA5E9',
    icon: 'Laptop',
  ),
  CategoryModel(
    id: 'e8',
    name: 'Office Supplies',
    type: TransactionType.expense,
    color: '#F472B6',
    icon: 'Briefcase',
  ),
  CategoryModel(
    id: 'e9',
    name: 'Insurance',
    type: TransactionType.expense,
    color: '#10B981',
    icon: 'Zap',
  ),
  CategoryModel(
    id: 'e10',
    name: 'Other Expenses',
    type: TransactionType.expense,
    color: '#6B7280',
    icon: 'Coins',
  ),
];

final List<Budget> defaultBudgets = [
  Budget(id: 'b1', category: 'Stock / Inventory', amount: 5000),
  Budget(id: 'b2', category: 'Marketing & Ads', amount: 1500),
  Budget(id: 'b3', category: 'Rent / Leasing', amount: 2500),
  Budget(id: 'b4', category: 'Utilities & Power', amount: 600),
];

final List<Transaction> demoTransactions = [
  Transaction(
    id: 't1',
    type: TransactionType.income,
    category: 'Product Sales',
    amount: 1200.0,
    date: '2026-06-01',
    notes: 'Bulk order - Client A',
  ),
  Transaction(
    id: 't2',
    type: TransactionType.expense,
    category: 'Stock / Inventory',
    amount: 450.0,
    date: '2026-06-02',
    notes: 'Restocking widget X',
  ),
  Transaction(
    id: 't3',
    type: TransactionType.expense,
    category: 'Rent / Leasing',
    amount: 2500.0,
    date: '2026-06-05',
    notes: 'June office rent',
  ),
  Transaction(
    id: 't4',
    type: TransactionType.income,
    category: 'Service Fees',
    amount: 850.0,
    date: '2026-06-08',
    notes: 'Maintenance service',
  ),
];

class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

const List<CurrencyInfo> currencies = [
  CurrencyInfo(code: 'LKR', symbol: 'Rs.', name: 'Sri Lankan Rupee'),
  CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar'),
  CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro'),
  CurrencyInfo(code: 'GBP', symbol: '£', name: 'British Pound'),
  CurrencyInfo(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
  CurrencyInfo(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
  CurrencyInfo(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
  CurrencyInfo(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar'),
];

String getCurrencySymbol(String code) {
  return currencies
      .firstWhere((c) => c.code == code, orElse: () => currencies[0])
      .symbol;
}
