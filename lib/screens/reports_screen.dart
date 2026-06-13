import 'dart:math';

import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/transaction.dart';

class ReportsScreen extends StatefulWidget {
  final List<Transaction> transactions;
  final List<CategoryModel> categories;
  final String currencySymbol;

  const ReportsScreen({
    super.key,
    required this.transactions,
    required this.categories,
    required this.currencySymbol,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _period = 'year';

  String _monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  String _dateKey(DateTime date) =>
      '${_monthKey(date)}-${date.day.toString().padLeft(2, '0')}';

  String _monthName(DateTime date) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[date.month - 1];
  }

  List<Transaction> _getPeriodTransactions() {
    final now = DateTime.now();
    final thisMonth = _monthKey(now);
    final previousMonth = _monthKey(DateTime(now.year, now.month - 1, 1));
    final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
    final quarterMonths = List.generate(
      3,
      (i) => _monthKey(DateTime(now.year, quarterStartMonth + i, 1)),
    );

    switch (_period) {
      case 'current_month':
        return widget.transactions
            .where((t) => t.date.startsWith(thisMonth))
            .toList();
      case 'previous_month':
        return widget.transactions
            .where((t) => t.date.startsWith(previousMonth))
            .toList();
      case 'quarter':
        return widget.transactions
            .where(
              (t) => quarterMonths.any((month) => t.date.startsWith(month)),
            )
            .toList();
      case 'year':
      default:
        return widget.transactions
            .where((t) => t.date.startsWith(now.year.toString()))
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final activeTx = _getPeriodTransactions();

    final totalRev = activeTx
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalCOGS = activeTx
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.category == 'Stock / Inventory',
        )
        .fold(0.0, (sum, t) => sum + t.amount);
    final grossProfit = totalRev - totalCOGS;
    final opExpensesList = activeTx
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.category != 'Stock / Inventory',
        )
        .toList();
    final totalOPEX = opExpensesList.fold(0.0, (sum, t) => sum + t.amount);
    final netIncome = grossProfit - totalOPEX;
    final profitMargin = totalRev > 0
        ? (netIncome / totalRev * 100).round()
        : 0;

    final incomeMap = <String, double>{};
    for (var t in activeTx.where((t) => t.type == TransactionType.income)) {
      incomeMap[t.category] = (incomeMap[t.category] ?? 0) + t.amount;
    }
    final incomeDivsBreakdown = incomeMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final expensesMap = <String, double>{};
    for (var t in opExpensesList) {
      expensesMap[t.category] = (expensesMap[t.category] ?? 0) + t.amount;
    }
    final expensesDivsBreakdown = expensesMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Daily Cashflow chart for the latest eight calendar days.
    final now = DateTime.now();
    final days = List.generate(
      8,
      (i) => _dateKey(now.subtract(Duration(days: 7 - i))),
    );
    final dailyBars = days.map((dStr) {
      final inc = widget.transactions
          .where((t) => t.type == TransactionType.income && t.date == dStr)
          .fold(0.0, (sum, t) => sum + t.amount);
      final exp = widget.transactions
          .where((t) => t.type == TransactionType.expense && t.date == dStr)
          .fold(0.0, (sum, t) => sum + t.amount);
      return {'label': dStr.substring(8), 'income': inc, 'expense': exp};
    }).toList();

    double maxDailyValue = 200;
    for (var b in dailyBars) {
      maxDailyValue = max(
        maxDailyValue,
        max(b['income'] as double, b['expense'] as double),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 0,
        vertical: isMobile ? 16 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header & Period Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calculate,
                    size: 20,
                    color: Color(0xFF6366F1),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Financial Reports',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _periodBtn('year', 'Full Year'),
                      _periodBtn('current_month', _monthName(DateTime.now())),
                      _periodBtn(
                        'previous_month',
                        _monthName(
                          DateTime(
                            DateTime.now().year,
                            DateTime.now().month - 1,
                            1,
                          ),
                        ),
                      ),
                      _periodBtn('quarter', 'Quarter'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Primary metrics grid
          if (isMobile)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _metricCard('Revenues', totalRev, isDark)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _metricCard('Inventory', totalCOGS, isDark),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _metricCard('Operating', totalOPEX, isDark),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF312E81).withValues(alpha: 0.2)
                              : const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'NET INCOME',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF818CF8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              child: Text(
                                '${widget.currencySymbol}${netIncome.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: netIncome >= 0
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF43F5E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _metricCard('Gross Revenues', totalRev, isDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _metricCard('Inventory Costs', totalCOGS, isDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _metricCard('Operating OPEX', totalOPEX, isDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF312E81).withValues(alpha: 0.2)
                          : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NET INCOME',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF818CF8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${widget.currencySymbol}${netIncome.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: netIncome >= 0
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF43F5E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Daily Cashflow Panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A).withValues(alpha: 0.4)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY CASH FLOW',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: dailyBars.map((b) {
                      final inc = b['income'] as double;
                      final exp = b['expense'] as double;
                      final incH = maxDailyValue > 0
                          ? (inc / maxDailyValue) * 110
                          : 0.0;
                      final expH = maxDailyValue > 0
                          ? (exp / maxDailyValue) * 110
                          : 0.0;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 4,
                                height: max(incH, 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Container(
                                width: 4,
                                height: max(expH, 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF43F5E),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            b['label'] as String,
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Statements Panel
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A).withValues(alpha: 0.4)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'PROFIT & LOSS STATEMENT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Icon(Icons.description, size: 16, color: Colors.grey[400]),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Revenues
                _pnlHeader('Operating Revenues', totalRev, isDark),
                const SizedBox(height: 8),
                ...incomeDivsBreakdown.map(
                  (e) => _pnlRow(
                    e.key,
                    '${widget.currencySymbol}${e.value.toStringAsFixed(0)}',
                  ),
                ),
                const SizedBox(height: 16),

                // COGS
                _pnlHeader('Cost of Goods Sold', totalCOGS, isDark),
                _pnlRow(
                  'Inventory Sourcing',
                  '${widget.currencySymbol}${totalCOGS.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 16),

                // Gross Profit
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _pnlRow(
                    'GROSS PROFIT',
                    '${widget.currencySymbol}${grossProfit.toStringAsFixed(0)}',
                    bold: true,
                  ),
                ),
                const SizedBox(height: 16),

                // OPEX
                _pnlHeader('Operating Expenses', totalOPEX, isDark),
                ...expensesDivsBreakdown.map(
                  (e) => _pnlRow(
                    e.key,
                    '${widget.currencySymbol}${e.value.toStringAsFixed(0)}',
                  ),
                ),
                const SizedBox(height: 16),

                // Net Income
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'NET INCOME',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${widget.currencySymbol}${netIncome.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: netIncome >= 0
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF43F5E),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Margin: $profitMargin%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _periodBtn(String id, String label) {
    final isSelected = _period == id;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => setState(() => _period = id),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF0F172A) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Widget _metricCard(String title, double value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.4)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              '${widget.currencySymbol}${value.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pnlHeader(String title, double value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        Text(
          '${widget.currencySymbol}${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _pnlRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
