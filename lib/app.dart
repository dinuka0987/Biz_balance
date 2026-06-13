import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'data/demo_data.dart';
import 'models/budget.dart';
import 'models/category_model.dart';
import 'models/transaction.dart';
import 'screens/budget_screen.dart';
import 'screens/category_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/ledger_screen.dart';
import 'screens/pin_lock_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'services/storage_service.dart';
import 'widgets/transaction_form_dialog.dart';

class BusinessMoneyManagerApp extends StatefulWidget {
  final SharedPreferences prefs;

  const BusinessMoneyManagerApp({super.key, required this.prefs});

  @override
  State<BusinessMoneyManagerApp> createState() =>
      _BusinessMoneyManagerAppState();
}

class _BusinessMoneyManagerAppState extends State<BusinessMoneyManagerApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  late StorageService _storage;
  bool _isLoading = true;

  // Global State
  List<Transaction> _transactions = [];
  List<CategoryModel> _categories = [];
  List<Budget> _budgets = [];
  String _currencyCode = 'LKR';

  // Security & Preferences
  String _pin = '1234';
  bool _isPinEnabled = false;
  bool _isUnlocked = true;
  String _themeMode = 'dark'; // 'light' or 'dark'

  // Navigation
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    _storage = StorageService(widget.prefs);

    // Seed initial data if first launch
    if (!_storage.hasData()) {
      await _storage.saveTransactions(demoTransactions);
      await _storage.saveCategories(defaultCategories);
      await _storage.saveBudgets(defaultBudgets);
      await _storage.saveCurrency('LKR');
      await _storage.savePin('1234');
      await _storage.savePinEnabled(false);
      await _storage.saveTheme('dark');
    }

    // Load state
    _transactions = _storage.loadTransactions();
    _categories = _storage.loadCategories();
    _budgets = _storage.loadBudgets();
    _currencyCode = _storage.loadCurrency();
    _pin = _storage.loadPin();
    _isPinEnabled = _storage.loadPinEnabled();
    _themeMode = _storage.loadTheme();

    if (_isPinEnabled) {
      _isUnlocked = false;
    }

    setState(() => _isLoading = false);
  }

  // --- Handlers ---
  Future<void> _addTransaction(Transaction tx) async {
    setState(() {
      _transactions = [..._transactions, tx];
      _transactions.sort((a, b) => b.date.compareTo(a.date)); // descending date
    });
    await _storage.saveTransactions(_transactions);
  }

  Future<void> _updateTransaction(Transaction tx) async {
    setState(() {
      final idx = _transactions.indexWhere((t) => t.id == tx.id);
      if (idx != -1) {
        _transactions = [..._transactions]..[idx] = tx;
        _transactions.sort((a, b) => b.date.compareTo(a.date));
      }
    });
    await _storage.saveTransactions(_transactions);
  }

  Future<void> _deleteTransaction(String id) async {
    setState(() {
      _transactions = _transactions.where((t) => t.id != id).toList();
    });
    await _storage.saveTransactions(_transactions);
  }

  Future<void> _addCategory(CategoryModel cat) async {
    setState(() => _categories = [..._categories, cat]);
    await _storage.saveCategories(_categories);
  }

  Future<void> _deleteCategory(String id, String name) async {
    setState(() {
      _categories = _categories.where((c) => c.id != id).toList();
      final updatedTransactions = [..._transactions];
      // Reassign transactions
      for (int i = 0; i < updatedTransactions.length; i++) {
        if (updatedTransactions[i].category == name) {
          updatedTransactions[i] = updatedTransactions[i].copyWith(
            category: updatedTransactions[i].type == TransactionType.income
                ? 'Other Income'
                : 'Other Expenses',
          );
        }
      }
      _transactions = updatedTransactions;

      final updatedBudgets = [..._budgets];
      // Reassign budgets
      for (int i = 0; i < updatedBudgets.length; i++) {
        if (updatedBudgets[i].category == name) {
          updatedBudgets[i] = updatedBudgets[i].copyWith(
            category: 'Other Expenses',
          );
        }
      }
      _budgets = updatedBudgets;
    });
    await _storage.saveCategories(_categories);
    await _storage.saveTransactions(_transactions);
    await _storage.saveBudgets(_budgets);
  }

  Future<void> _saveBudget(Budget b) async {
    setState(() {
      final idx = _budgets.indexWhere((existing) => existing.id == b.id);
      if (idx >= 0) {
        _budgets = [..._budgets]..[idx] = b;
      } else {
        _budgets = [..._budgets, b];
      }
    });
    await _storage.saveBudgets(_budgets);
  }

  Future<void> _deleteBudget(String id) async {
    setState(() {
      _budgets = _budgets.where((b) => b.id != id).toList();
    });
    await _storage.saveBudgets(_budgets);
  }

  Future<void> _exportBackupJson() async {
    try {
      final backupJson = _storage.exportBackup(
        transactions: _transactions,
        categories: _categories,
        budgets: _budgets,
        currencyCode: _currencyCode,
        isPinEnabled: _isPinEnabled,
        pin: _pin,
        theme: _themeMode,
      );
      final dir = await getApplicationDocumentsDirectory();
      final date = DateTime.now().toIso8601String().split('T').first;
      final file = File('${dir.path}/biz_backup_$date.json');
      await file.writeAsString(backupJson);

      if (!mounted) return;
      _showSnackBar(
        SnackBar(
          content: Text('JSON backup exported to: ${file.path}'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Trigger share dialog to let user save to phone storage
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: 'Biz Backup $date'),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        SnackBar(
          content: Text('JSON export failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSnackBar(SnackBar snackBar) {
    _scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void _showTransactionForm({
    Transaction? editingTx,
    TransactionType? defaultType,
  }) {
    final dialogContext = _navigatorKey.currentState?.overlay?.context;
    if (dialogContext == null) {
      _showSnackBar(
        const SnackBar(
          content: Text('Unable to open the record form. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (ctx) => TransactionFormDialog(
        editingTransaction: editingTx,
        categories: _categories,
        currencySymbol: getCurrencySymbol(_currencyCode),
        defaultType: defaultType ?? TransactionType.expense,
        onSubmit: (tx) {
          if (editingTx != null) {
            _updateTransaction(tx);
          } else {
            _addTransaction(tx);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFF0F172A),
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final isDarkTheme = _themeMode == 'dark';
    final primaryTextColor = isDarkTheme
        ? Colors.white
        : const Color(0xFF0F172A);
    final secondaryTextColor = isDarkTheme
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF334155);
    final themeData = ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      colorSchemeSeed: const Color(0xFF4F46E5),
      scaffoldBackgroundColor: isDarkTheme
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      textTheme:
          ThemeData(
            brightness: isDarkTheme ? Brightness.dark : Brightness.light,
            fontFamily: 'Inter',
          ).textTheme.apply(
            bodyColor: primaryTextColor,
            displayColor: primaryTextColor,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkTheme
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        foregroundColor: primaryTextColor,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: primaryTextColor),
        titleTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      iconTheme: IconThemeData(color: primaryTextColor),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: secondaryTextColor),
        hintStyle: TextStyle(color: secondaryTextColor.withValues(alpha: 0.7)),
      ),
      listTileTheme: ListTileThemeData(
        textColor: primaryTextColor,
        iconColor: primaryTextColor,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: primaryTextColor),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: secondaryTextColor),
          hintStyle: TextStyle(
            color: secondaryTextColor.withValues(alpha: 0.7),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        textStyle: TextStyle(color: primaryTextColor),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDarkTheme
              ? const Color(0xFFCBD5E1)
              : const Color(0xFF0F172A),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDarkTheme
              ? const Color(0xFFCBD5E1)
              : const Color(0xFF0F172A),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            color: primaryTextColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: primaryTextColor),
        ),
      ),
    );

    if (!_isUnlocked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
        scaffoldMessengerKey: _scaffoldMessengerKey,
        theme: themeData,
        home: PINLockScreen(
          storedPin: _pin,
          currencySymbol: getCurrencySymbol(_currencyCode),
          onUnlock: () => setState(() => _isUnlocked = true),
        ),
      );
    }

    final screens = [
      DashboardScreen(
        transactions: _transactions,
        categories: _categories,
        budgets: _budgets,
        currencySymbol: getCurrencySymbol(_currencyCode),
        onNavigate: (tab) {
          int idx = 0;
          if (tab == 'ledger') idx = 1;
          setState(() => _currentIndex = idx);
        },
        onQuickAdd: (type) => _showTransactionForm(defaultType: type),
      ),
      LedgerScreen(
        transactions: _transactions,
        categories: _categories,
        currencySymbol: getCurrencySymbol(_currencyCode),
        onAddClick: () =>
            _showTransactionForm(defaultType: TransactionType.expense),
        onEditClick: (tx) => _showTransactionForm(editingTx: tx),
        onDeleteClick: _deleteTransaction,
      ),
      BudgetScreen(
        budgets: _budgets,
        categories: _categories,
        transactions: _transactions,
        currencySymbol: getCurrencySymbol(_currencyCode),
        onSaveBudget: _saveBudget,
        onDeleteBudget: _deleteBudget,
      ),
      CategoryScreen(
        categories: _categories,
        onCreateCategory: _addCategory,
        onDeleteCategory: _deleteCategory,
      ),
      ReportsScreen(
        transactions: _transactions,
        categories: _categories,
        currencySymbol: getCurrencySymbol(_currencyCode),
      ),
      SettingsScreen(
        currencyCode: _currencyCode,
        onCurrencyChange: (code) {
          setState(() => _currencyCode = code);
          _storage.saveCurrency(code);
        },
        pin: _pin,
        isPinEnabled: _isPinEnabled,
        onPinChange: (newPin, enabled) {
          setState(() {
            _pin = newPin;
            _isPinEnabled = enabled;
          });
          _storage.savePin(newPin);
          _storage.savePinEnabled(enabled);
        },
        onBackupExport: _exportBackupJson,
        onBackupImport: (jsonStr) async {
          final data = _storage.parseBackup(jsonStr);
          if (data != null) {
            setState(() {
              _transactions = (data['transactions'] as List)
                  .map((e) => Transaction.fromJson(e))
                  .toList();
              _categories = (data['categories'] as List)
                  .map((e) => CategoryModel.fromJson(e))
                  .toList();
              if (data['budgets'] != null) {
                _budgets = (data['budgets'] as List)
                    .map((e) => Budget.fromJson(e))
                    .toList();
              }
              _currencyCode = data['currencyCode'] ?? 'LKR';
              _isPinEnabled = data['isPinEnabled'] ?? false;
              _pin = data['pin'] ?? '1234';
              _themeMode = data['theme'] ?? 'dark';
            });
            await _storage.saveTransactions(_transactions);
            await _storage.saveCategories(_categories);
            await _storage.saveBudgets(_budgets);
            await _storage.saveCurrency(_currencyCode);
            await _storage.savePinEnabled(_isPinEnabled);
            await _storage.savePin(_pin);
            await _storage.saveTheme(_themeMode);
            return true;
          }
          return false;
        },
        onTruncateDatabase: (loadDemo) async {
          setState(() {
            _transactions = loadDemo ? demoTransactions : [];
            _categories = loadDemo ? defaultCategories : defaultCategories;
            _budgets = loadDemo ? defaultBudgets : [];
          });
          await _storage.saveTransactions(_transactions);
          await _storage.saveCategories(_categories);
          await _storage.saveBudgets(_budgets);
        },
        themeMode: _themeMode,
        onThemeChange: () {
          setState(() => _themeMode = _themeMode == 'dark' ? 'light' : 'dark');
          _storage.saveTheme(_themeMode);
        },
        transactionsCount: _transactions.length,
      ),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      title: 'Business Money Manager',
      theme: themeData,
      home: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Color(0xFF6366F1)),
              SizedBox(width: 12),
              Text('Biz', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: screens[_currentIndex],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Ledger',
            ),
            NavigationDestination(
              icon: Icon(Icons.track_changes_outlined),
              selectedIcon: Icon(Icons.track_changes),
              label: 'Budget',
            ),
            NavigationDestination(
              icon: Icon(Icons.category_outlined),
              selectedIcon: Icon(Icons.category),
              label: 'Categories',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() => _currentIndex = 1);
            // show form after navigation completes
            Future.microtask(
              () => _showTransactionForm(defaultType: TransactionType.expense),
            );
          },
          backgroundColor: const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
