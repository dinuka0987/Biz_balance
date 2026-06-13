import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/transaction.dart';

const _availableIcons = [
  'ShoppingBag', 'Users', 'Wrench', 'Package', 'Store', 
  'Zap', 'Truck', 'Megaphone', 'Laptop', 'Coins', 'DollarSign', 'Briefcase'
];

const _presetColors = [
  '#10B981', '#3B82F6', '#8B5CF6', '#EF4444', '#F59E0B', 
  '#06B6D4', '#EAB308', '#EC4899', '#6366F1', '#F97316', 
  '#14B8A6', '#84CC16', '#8B5CF6', '#6B7280'
];

class CategoryScreen extends StatefulWidget {
  final List<CategoryModel> categories;
  final void Function(CategoryModel cat) onCreateCategory;
  final void Function(String id, String name) onDeleteCategory;

  const CategoryScreen({
    super.key,
    required this.categories,
    required this.onCreateCategory,
    required this.onDeleteCategory,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  TransactionType _activeTab = TransactionType.income;
  
  final _nameController = TextEditingController();
  String _color = _presetColors[0];
  String _icon = _availableIcons[0];
  String _errorMsg = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() => _errorMsg = '');
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMsg = 'Category name cannot be empty.');
      return;
    }

    if (widget.categories.any((c) => c.name.toLowerCase() == name.toLowerCase() && c.type == _activeTab)) {
      setState(() => _errorMsg = 'A category with this designation already exists.');
      return;
    }

    widget.onCreateCategory(CategoryModel(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: _activeTab,
      color: _color,
      icon: _icon,
    ));

    _nameController.clear();
    setState(() {
      _color = _presetColors[DateTime.now().millisecond % _presetColors.length];
      _errorMsg = '';
    });
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'ShoppingBag': return Icons.shopping_bag;
      case 'Users': return Icons.people;
      case 'Wrench': return Icons.build;
      case 'Package': return Icons.inventory_2;
      case 'Store': return Icons.store;
      case 'Zap': return Icons.bolt;
      case 'Truck': return Icons.local_shipping;
      case 'Megaphone': return Icons.campaign;
      case 'Laptop': return Icons.laptop_mac;
      case 'Coins': return Icons.monetization_on;
      case 'DollarSign': return Icons.attach_money;
      case 'Briefcase': return Icons.business_center;
      default: return Icons.business_center;
    }
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceAll('#', 'FF'), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final filteredCategories = widget.categories.where((c) => c.type == _activeTab).toList();

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
            children: [
              const Icon(Icons.category, size: 20, color: Color(0xFF6366F1)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Manager',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Structure your business streams for better insights.',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = TransactionType.income),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _activeTab == TransactionType.income ? (isDark ? const Color(0xFF0F172A) : Colors.white) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _activeTab == TransactionType.income ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Income',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _activeTab == TransactionType.income ? (isDark ? Colors.white : const Color(0xFF0F172A)) : Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = TransactionType.expense),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _activeTab == TransactionType.expense ? (isDark ? const Color(0xFF0F172A) : Colors.white) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _activeTab == TransactionType.expense ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Expenses',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _activeTab == TransactionType.expense ? (isDark ? Colors.white : const Color(0xFF0F172A)) : Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Content Grid (Creator & List)
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            final children = [
              // Creator Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.4) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADD NEW CATEGORY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 1,
                        color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Text('NAME', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.grey[500])),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      maxLength: 40,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'E.g., Warehouse Deliveries...',
                        counterText: '',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text('COLOR', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.grey[500])),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _presetColors.map((col) {
                        final isSelected = _color == col;
                        return InkWell(
                          onTap: () => setState(() => _color = col),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: _hexToColor(col),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)],
                            ),
                            child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    Text('ICON', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.grey[500])),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFE2E8F0)),
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _availableIcons.map((icName) {
                          final isSelected = _icon == icName;
                          return InkWell(
                            onTap: () => setState(() => _icon = icName),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF6366F1).withValues(alpha: 0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isSelected ? const Color(0xFF6366F1) : Colors.transparent),
                              ),
                              child: Icon(_getIconData(icName), size: 18, color: isSelected ? const Color(0xFF6366F1) : Colors.grey[400]),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_errorMsg.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(_errorMsg, style: const TextStyle(fontSize: 11, color: Color(0xFFF43F5E))),
                      ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _handleSubmit,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (!isWide) const SizedBox(height: 16),

              // List Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.4) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXISTING CATEGORIES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 1,
                        color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (filteredCategories.isEmpty)
                      Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('No categories found.', style: TextStyle(fontSize: 12, color: Colors.grey[500]))))
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredCategories.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final cat = filteredCategories[index];
                          final color = _hexToColor(cat.color);
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(_getIconData(cat.icon), size: 18, color: color),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(cat.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                      Text(
                                        _activeTab == TransactionType.income ? 'INCOME' : 'EXPENSE',
                                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  color: const Color(0xFFF43F5E),
                                  onPressed: () => widget.onDeleteCategory(cat.id, cat.name),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ];

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: children[0]),
                  const SizedBox(width: 20),
                  Expanded(flex: 5, child: children[1]),
                ],
              );
            }
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
