import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/category_model.dart';

class TransactionFormDialog extends StatefulWidget {
  final Transaction? editingTransaction;
  final List<CategoryModel> categories;
  final String currencySymbol;
  final TransactionType defaultType;
  final void Function(Transaction tx) onSubmit;

  const TransactionFormDialog({
    super.key,
    this.editingTransaction,
    required this.categories,
    required this.currencySymbol,
    required this.defaultType,
    required this.onSubmit,
  });

  @override
  State<TransactionFormDialog> createState() => _TransactionFormDialogState();
}

class _TransactionFormDialogState extends State<TransactionFormDialog> {
  late TransactionType _type;
  late String _category;
  final _amountController = TextEditingController();
  late String _date;
  final _notesController = TextEditingController();
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    final editing = widget.editingTransaction;
    if (editing != null) {
      _type = editing.type;
      _category = editing.category;
      _amountController.text = editing.amount.toString();
      _date = editing.date;
      _notesController.text = editing.notes ?? '';
    } else {
      _type = widget.defaultType;
      final matchedCats = widget.categories
          .where((c) => c.type == _type)
          .toList();
      _category = matchedCats.isNotEmpty ? matchedCats[0].name : '';
      _date = _formatDate(DateTime.now());
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _handleTypeChange(TransactionType newType) {
    if (widget.editingTransaction != null) return;
    final matchedCats = widget.categories
        .where((c) => c.type == newType)
        .toList();
    setState(() {
      _type = newType;
      _category = matchedCats.isNotEmpty ? matchedCats[0].name : '';
    });
  }

  List<CategoryModel> get _currentCategories =>
      widget.categories.where((c) => c.type == _type).toList();

  void _handleSubmit() {
    setState(() => _errorMsg = '');

    final parsedAmount = double.tryParse(_amountController.text);
    if (parsedAmount == null || parsedAmount <= 0) {
      setState(
        () => _errorMsg =
            'Please enter a clear transaction amount greater than zero.',
      );
      return;
    }
    if (_category.isEmpty) {
      setState(() => _errorMsg = 'Please assign an accounting category.');
      return;
    }
    if (_date.isEmpty) {
      setState(() => _errorMsg = 'Please choose a transaction calendar date.');
      return;
    }

    final tx = Transaction(
      id:
          widget.editingTransaction?.id ??
          't_${DateTime.now().millisecondsSinceEpoch}',
      type: _type,
      category: _category,
      amount: parsedAmount,
      date: _date,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    widget.onSubmit(tx);
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_date) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _date = _formatDate(picked));
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.editingTransaction != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'AMEND RECORD' : 'RECORD TRANSACTION',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            letterSpacing: 1.2,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEditing
                              ? 'Modify existing ledger transaction'
                              : 'Insert money pipeline event',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9),
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error Alert
                  if (_errorMsg.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFF43F5E).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 16,
                            color: Color(0xFFF43F5E),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMsg,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFF43F5E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Type Selector
                  _sectionLabel('TRANSACTION SCHEME'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _typeButton(
                          'Revenue (Income)',
                          TransactionType.income,
                          const Color(0xFF10B981),
                          isEditing,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _typeButton(
                          'Cost (Expense)',
                          TransactionType.expense,
                          const Color(0xFFF43F5E),
                          isEditing,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Amount
                  _sectionLabel(
                    'TRANSACTION VOLUME (${widget.currencySymbol})',
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    autofocus: true,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      prefixText: '${widget.currencySymbol} ',
                      prefixStyle: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                      ),
                      hintText: '0.00',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  _sectionLabel('PIPELINE DIVISION (CATEGORY)'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue:
                        _currentCategories.any((c) => c.name == _category)
                        ? _category
                        : null,
                    isExpanded: true,
                    items: _currentCategories
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat.name,
                            child: Text(
                              cat.name,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _category = val);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date
                  _sectionLabel('VALUE DATE'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _date,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  _sectionLabel('DESCRIPTION NOTES (OPTIONAL)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    maxLength: 250,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'E.g., Client invoice ref #8809...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleSubmit,
                          icon: const Icon(Icons.save, size: 16),
                          label: Text(
                            isEditing ? 'Save Changes' : 'Record Entry',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      fontFamily: 'monospace',
      letterSpacing: 1,
      color: Colors.grey[500],
    ),
  );

  Widget _typeButton(
    String label,
    TransactionType type,
    Color activeColor,
    bool disabled,
  ) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: disabled ? null : () => _handleTypeChange(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? activeColor
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? activeColor : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
