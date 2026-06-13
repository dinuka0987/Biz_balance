import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../models/category_model.dart';
import '../models/transaction.dart';

class BudgetScreen extends StatefulWidget {
  final List<Budget> budgets;
  final List<CategoryModel> categories;
  final List<Transaction> transactions;
  final String currencySymbol;
  final void Function(Budget budget) onSaveBudget;
  final void Function(String id) onDeleteBudget;

  const BudgetScreen({
    super.key,
    required this.budgets,
    required this.categories,
    required this.transactions,
    required this.currencySymbol,
    required this.onSaveBudget,
    required this.onDeleteBudget,
  });

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  String? _editingId;
  bool _isAdding = false;

  String _categoryInput = '';
  final _amountController = TextEditingController();
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    final expenseCats = widget.categories
        .where((c) => c.type == TransactionType.expense)
        .toList();
    if (expenseCats.isNotEmpty) {
      _categoryInput = expenseCats.first.name;
    }
  }

  @override
  void didUpdateWidget(covariant BudgetScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final expenseCats = widget.categories
        .where((c) => c.type == TransactionType.expense)
        .toList();
    if (expenseCats.isEmpty) {
      _categoryInput = '';
    } else if (!expenseCats.any((c) => c.name == _categoryInput)) {
      _categoryInput = expenseCats.first.name;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _currentMonthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  double _getCategorySpent(String catName) {
    final monthKey = _currentMonthKey();
    return widget.transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.startsWith(monthKey) &&
              t.category == catName,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  void _handleCreateOrUpdate(String? existingId) {
    setState(() => _errorMsg = '');

    final parsedAmount = double.tryParse(_amountController.text);
    if (parsedAmount == null || parsedAmount <= 0) {
      setState(() => _errorMsg = 'Please enter a valid amount.');
      return;
    }

    final catName = existingId != null
        ? widget.budgets.firstWhere((b) => b.id == existingId).category
        : _categoryInput;

    if (catName.isEmpty) {
      setState(() => _errorMsg = 'Please select a category.');
      return;
    }

    if (existingId == null &&
        widget.budgets.any((b) => b.category == catName)) {
      setState(() => _errorMsg = 'A budget for this category already exists.');
      return;
    }

    widget.onSaveBudget(
      Budget(
        id: existingId ?? 'b_${DateTime.now().millisecondsSinceEpoch}',
        category: catName,
        amount: parsedAmount,
      ),
    );

    _cancelForm();
  }

  void _startEdit(Budget b) {
    setState(() {
      _editingId = b.id;
      _amountController.text = b.amount.toString();
      _errorMsg = '';
      _isAdding = false;
    });
  }

  void _startAdd() {
    setState(() {
      _isAdding = true;
      final expenseCats = widget.categories
          .where((c) => c.type == TransactionType.expense)
          .toList();
      _categoryInput = expenseCats.isNotEmpty ? expenseCats.first.name : '';
      _amountController.clear();
      _errorMsg = '';
      _editingId = null;
    });
  }

  void _cancelForm() {
    setState(() {
      _editingId = null;
      _isAdding = false;
      _amountController.clear();
      _errorMsg = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final expenseCats = widget.categories
        .where((c) => c.type == TransactionType.expense)
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 0,
        vertical: isMobile ? 16 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.track_changes,
                          size: 20,
                          color: Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Budget Control',
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!_isAdding)
                ElevatedButton.icon(
                  onPressed: _startAdd,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text(
                    'Set Budget',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Add Form
          if (_isAdding)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NEW BUDGET CAP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 1,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: _cancelForm,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category Selection
                  Text(
                    'CATEGORY',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: expenseCats.any((c) => c.name == _categoryInput)
                            ? _categoryInput
                            : null,
                        isExpanded: true,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                        items: expenseCats
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.name,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _categoryInput = v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amount Input
                  Text(
                    'MONTHLY TARGET (${widget.currencySymbol})',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      prefixText: '${widget.currencySymbol} ',
                      hintText: '0.00',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  if (_errorMsg.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _errorMsg,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFF43F5E),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleCreateOrUpdate(null),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Save Budget',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Budgets List
          if (widget.budgets.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
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
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.track_changes,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'NO BUDGETS SET',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Budgets help you track and limit your spending by category.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.budgets.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final b = widget.budgets[index];
                final spent = _getCategorySpent(b.category);
                final pct = b.amount > 0 ? (spent / b.amount) * 100 : 0;
                final remaining = b.amount - spent;
                final isOver = remaining < 0;

                Color statusColor = const Color(0xFF10B981);
                if (pct >= 100) {
                  statusColor = const Color(0xFFF43F5E);
                } else if (pct >= 80) {
                  statusColor = const Color(0xFFF59E0B);
                }

                final isEditing = _editingId == b.id;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A).withValues(alpha: 0.4)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isEditing
                          ? const Color(0xFF6366F1)
                          : (isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.category,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Current Month',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isEditing ? Icons.close : Icons.edit,
                                  size: 18,
                                ),
                                color: Colors.grey[500],
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                                onPressed: () =>
                                    isEditing ? _cancelForm() : _startEdit(b),
                              ),
                              if (!isEditing)
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                  ),
                                  color: const Color(0xFFF43F5E),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                  onPressed: () => widget.onDeleteBudget(b.id),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (isEditing) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                autofocus: true,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  prefixText: '${widget.currencySymbol} ',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _handleCreateOrUpdate(b.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Update',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        if (_errorMsg.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _errorMsg,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFF43F5E),
                              ),
                            ),
                          ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Spent: ${widget.currencySymbol}${spent.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              'Cap: ${widget.currencySymbol}${b.amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (pct / 100).clamp(0.0, 1.0),
                            backgroundColor: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            color: statusColor,
                            minHeight: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${pct.toStringAsFixed(0)}% USED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                color: statusColor,
                              ),
                            ),
                            if (isOver)
                              Text(
                                'OVER BY ${widget.currencySymbol}${remaining.abs().toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF43F5E),
                                  fontFamily: 'monospace',
                                ),
                              )
                            else
                              Text(
                                'LEFT: ${widget.currencySymbol}${remaining.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                  fontFamily: 'monospace',
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
