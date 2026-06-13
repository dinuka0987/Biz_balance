import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../data/demo_data.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final String currencyCode;
  final void Function(String code) onCurrencyChange;
  final String pin;
  final bool isPinEnabled;
  final void Function(String newPin, bool isEnabled) onPinChange;
  final VoidCallback onBackupExport;
  final Future<bool> Function(String jsonStr) onBackupImport;
  final void Function(bool loadDemo) onTruncateDatabase;
  final String themeMode;
  final VoidCallback onThemeChange;
  final int transactionsCount;

  const SettingsScreen({
    super.key,
    required this.currencyCode,
    required this.onCurrencyChange,
    required this.pin,
    required this.isPinEnabled,
    required this.onPinChange,
    required this.onBackupExport,
    required this.onBackupImport,
    required this.onTruncateDatabase,
    required this.themeMode,
    required this.onThemeChange,
    required this.transactionsCount,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _pinInput;
  late bool _pinEnabledToggle;
  bool _showPin = false;
  String _pinSuccessMsg = '';
  String _pinErrorMsg = '';

  bool _importSuccess = false;
  String _importError = '';

  @override
  void initState() {
    super.initState();
    _pinInput = widget.pin;
    _pinEnabledToggle = widget.isPinEnabled;
  }

  void _handleSavePin() {
    setState(() {
      _pinSuccessMsg = '';
      _pinErrorMsg = '';
    });

    final trimmedPin = _pinInput.trim();
    if (_pinEnabledToggle &&
        (trimmedPin.length != 4 || int.tryParse(trimmedPin) == null)) {
      setState(() => _pinErrorMsg = 'PIN must be exactly 4 digits.');
      return;
    }

    widget.onPinChange(trimmedPin, _pinEnabledToggle);
    setState(() => _pinSuccessMsg = 'Security settings updated.');
  }

  Future<void> _handleBackupImport() async {
    setState(() {
      _importSuccess = false;
      _importError = '';
    });

    try {
      FilePickerResult? result = await FilePicker.pickFiles(type: FileType.any);

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String jsonStr = await file.readAsString();

        final ok = await widget.onBackupImport(jsonStr);
        if (!mounted) return;

        setState(() {
          _importSuccess = ok;
          _importError = ok
              ? ''
              : 'Invalid backup JSON. Please check the file contents.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ok ? 'JSON backup imported successfully.' : _importError,
            ),
            backgroundColor: ok ? null : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _importSuccess = false;
        _importError = 'Failed to read file: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_importError),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

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
              const Icon(Icons.settings, size: 20, color: Color(0xFF6366F1)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Layout
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;

              final col1 = Column(
                children: [
                  // Currency Selection
                  _buildCard(
                    isDark: isDark,
                    title: 'CURRENCY',
                    subtitle: 'Select your business currency.',
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 2 : 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: isMobile ? 2.2 : 2.5,
                      ),
                      itemCount: currencies.length,
                      itemBuilder: (context, index) {
                        final curr = currencies[index];
                        final isSelected = widget.currencyCode == curr.code;
                        return InkWell(
                          onTap: () => widget.onCurrencyChange(curr.code),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(
                                      0xFF6366F1,
                                    ).withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF6366F1)
                                    : (isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFE2E8F0)),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    curr.symbol,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        curr.code,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? const Color(0xFF6366F1)
                                              : (isDark
                                                    ? Colors.white
                                                    : Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Theme Card
                  _buildCard(
                    isDark: isDark,
                    title: 'APPEARANCE',
                    subtitle: 'Toggle app theme mode.',
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: widget.onThemeChange,
                        icon: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          size: 18,
                        ),
                        label: Text(
                          isDark
                              ? 'Switch to Light Mode'
                              : 'Switch to Dark Mode',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Customer Support
                  _buildCard(
                    isDark: isDark,
                    title: 'CUSTOMER SUPPORT',
                    subtitle: 'Need help? Contact our support team.',
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final Uri emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: 'supportbiz96@gmail.com',
                          );
                          try {
                            if (!await launchUrl(emailLaunchUri)) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Could not open email client',
                                    ),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not open email client'),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.email_outlined, size: 18),
                        label: const Text(
                          'Email Support',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );

              final col2 = Column(
                children: [
                  // PIN Security
                  _buildCard(
                    isDark: isDark,
                    title: 'PIN SECURITY',
                    subtitle: 'Protect local app data with a 4 digit PIN.',
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _pinEnabledToggle,
                          onChanged: (value) =>
                              setState(() => _pinEnabledToggle = value),
                          title: const Text(
                            'Require PIN on launch',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: _pinInput,
                          enabled: _pinEnabledToggle,
                          obscureText: !_showPin,
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          onChanged: (value) => _pinInput = value,
                          decoration: InputDecoration(
                            counterText: '',
                            labelText: 'PIN',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _showPin ? 'Hide PIN' : 'Show PIN',
                              icon: Icon(
                                _showPin
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () =>
                                  setState(() => _showPin = !_showPin),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        if (_pinErrorMsg.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _pinErrorMsg,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFF43F5E),
                              ),
                            ),
                          ),
                        ],
                        if (_pinSuccessMsg.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _pinSuccessMsg,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _handleSavePin,
                            icon: const Icon(Icons.save, size: 16),
                            label: const Text(
                              'Save Security Settings',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Data Management
                  _buildCard(
                    isDark: isDark,
                    title: 'DATA MANAGEMENT',
                    subtitle: 'Export or clear your transaction records.',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: widget.onBackupExport,
                                icon: const Icon(Icons.file_download, size: 14),
                                label: const Text(
                                  'Export JSON',
                                  style: TextStyle(fontSize: 11),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _handleBackupImport,
                                icon: const Icon(Icons.file_upload, size: 14),
                                label: const Text(
                                  'Import JSON',
                                  style: TextStyle(fontSize: 11),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_importError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _importError,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFF43F5E),
                              ),
                            ),
                          ),
                        if (_importSuccess)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Backup imported successfully.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Clear All Data?'),
                                  content: const Text(
                                    'This will permanently delete all your transactions.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(c),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(c);
                                        widget.onTruncateDatabase(false);
                                      },
                                      child: const Text(
                                        'Clear Everything',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFFF43F5E,
                              ).withValues(alpha: 0.1),
                              foregroundColor: const Color(0xFFF43F5E),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Clear All Records',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: col1),
                    const SizedBox(width: 20),
                    Expanded(child: col2),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [col1, const SizedBox(height: 16), col2],
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.4)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: isDark ? Colors.grey : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[500] : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
