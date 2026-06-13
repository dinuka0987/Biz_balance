import 'package:flutter/material.dart';

class PINLockScreen extends StatefulWidget {
  final String storedPin;
  final VoidCallback onUnlock;
  final String currencySymbol;

  const PINLockScreen({
    super.key,
    required this.storedPin,
    required this.onUnlock,
    required this.currencySymbol,
  });

  @override
  State<PINLockScreen> createState() => _PINLockScreenState();
}

class _PINLockScreenState extends State<PINLockScreen> {
  String _pinInput = '';
  bool _showPin = false;
  String _errorMsg = '';

  void _handleKeyPress(String num) {
    if (_pinInput.length < 4) {
      final nextPin = _pinInput + num;
      setState(() {
        _pinInput = nextPin;
        _errorMsg = '';
      });
      if (nextPin == widget.storedPin) {
        Future.delayed(const Duration(milliseconds: 150), () {
          widget.onUnlock();
        });
      } else if (nextPin.length == 4) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _errorMsg = 'Incorrect PIN. Please try again.';
              _pinInput = '';
            });
          }
        });
      }
    }
  }

  void _handleDelete() {
    if (_pinInput.isNotEmpty) {
      setState(() {
        _pinInput = _pinInput.substring(0, _pinInput.length - 1);
        _errorMsg = '';
      });
    }
  }

  void _handleClear() {
    setState(() {
      _pinInput = '';
      _errorMsg = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isShort = screenSize.height < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(Icons.lock_outline, color: Color(0xFF38BDF8), size: 30),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Biz',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your 4-digit security PIN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                SizedBox(height: isShort ? 24 : 40),

                // PIN Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final filled = _pinInput.length > index;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? const Color(0xFF38BDF8) : Colors.transparent,
                        border: Border.all(
                          color: filled ? const Color(0xFF38BDF8) : const Color(0xFF475569),
                          width: 2,
                        ),
                        boxShadow: filled
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // Error Message
                SizedBox(
                  height: 20,
                  child: _errorMsg.isNotEmpty
                      ? Text(
                          _errorMsg,
                          style: const TextStyle(fontSize: 12, color: Color(0xFFFB7185), fontWeight: FontWeight.bold),
                        )
                      : (_pinInput.isNotEmpty
                          ? InkWell(
                              onTap: () => setState(() => _showPin = !_showPin),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_showPin ? Icons.visibility_off : Icons.visibility,
                                      size: 14, color: Colors.white38),
                                  const SizedBox(width: 4),
                                  Text(
                                    _showPin ? _pinInput : 'Show PIN',
                                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink()),
                ),
                SizedBox(height: isShort ? 24 : 40),

                // Keypad
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Column(
                    children: [
                      for (int row = 0; row < 3; row++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (int col = 0; col < 3; col++)
                                _buildKeypadButton('${row * 3 + col + 1}'),
                            ],
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(Icons.backspace_outlined, _handleDelete),
                          _buildKeypadButton('0'),
                          _buildActionButton(Icons.refresh, _handleClear),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String num) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Material(
        color: const Color(0xFF1E293B).withValues(alpha: 0.8),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _handleKeyPress(num),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          ),
        ),
      ),
    );
  }
}
