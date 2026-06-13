import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/category_model.dart';
import '../models/budget.dart';

class StorageService {
  static const _txKey = 'money_manager_transactions';
  static const _catKey = 'money_manager_categories';
  static const _budgetKey = 'money_manager_budgets';
  static const _currencyKey = 'money_manager_currency';
  static const _pinKey = 'money_manager_pin';
  static const _pinEnabledKey = 'money_manager_pin_enabled';
  static const _themeKey = 'money_manager_theme';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // ── Transactions ──
  List<Transaction> loadTransactions() {
    final raw = _prefs.getString(_txKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Transaction.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTransactions(List<Transaction> txs) async {
    await _prefs.setString(
      _txKey,
      jsonEncode(txs.map((t) => t.toJson()).toList()),
    );
  }

  // ── Categories ──
  List<CategoryModel> loadCategories() {
    final raw = _prefs.getString(_catKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map(
            (e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCategories(List<CategoryModel> cats) async {
    await _prefs.setString(
      _catKey,
      jsonEncode(cats.map((c) => c.toJson()).toList()),
    );
  }

  // ── Budgets ──
  List<Budget> loadBudgets() {
    final raw = _prefs.getString(_budgetKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Budget.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBudgets(List<Budget> budgets) async {
    await _prefs.setString(
      _budgetKey,
      jsonEncode(budgets.map((b) => b.toJson()).toList()),
    );
  }

  // ── Currency ──
  String loadCurrency() => _prefs.getString(_currencyKey) ?? 'LKR';
  Future<void> saveCurrency(String code) =>
      _prefs.setString(_currencyKey, code);

  // ── PIN ──
  String loadPin() => _prefs.getString(_pinKey) ?? '1234';
  Future<void> savePin(String pin) => _prefs.setString(_pinKey, pin);

  bool loadPinEnabled() => _prefs.getBool(_pinEnabledKey) ?? false;
  Future<void> savePinEnabled(bool enabled) =>
      _prefs.setBool(_pinEnabledKey, enabled);

  // ── Theme ──
  String loadTheme() => _prefs.getString(_themeKey) ?? 'dark';
  Future<void> saveTheme(String theme) => _prefs.setString(_themeKey, theme);

  // ── Check if first launch (no data stored yet) ──
  bool hasData() => _prefs.containsKey(_txKey);

  // ── Full backup export as JSON string ──
  String exportBackup({
    required List<Transaction> transactions,
    required List<CategoryModel> categories,
    required List<Budget> budgets,
    required String currencyCode,
    required bool isPinEnabled,
    required String pin,
    required String theme,
  }) {
    final backup = {
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'budgets': budgets.map((b) => b.toJson()).toList(),
      'currencyCode': currencyCode,
      'isPinEnabled': isPinEnabled,
      'pin': pin,
      'theme': theme,
      'exportedAt': DateTime.now().toIso8601String(),
    };
    return jsonEncode(backup);
  }

  // ── Import backup from JSON string, returns parsed data map or null on failure ──
  Map<String, dynamic>? parseBackup(String jsonStr) {
    try {
      final data = Map<String, dynamic>.from(jsonDecode(jsonStr) as Map);
      if (data['transactions'] is! List || data['categories'] is! List) {
        return null;
      }
      return data;
    } catch (_) {
      return null;
    }
  }
}
