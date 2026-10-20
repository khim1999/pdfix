import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/security_service.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  final bool isSetup;
  final ValueChanged<String>? onPinCreated;

  const LockScreen({
    super.key,
    required this.onUnlocked,
    this.isSetup = false,
    this.onPinCreated,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  String? _firstPin;
  String _errorMessage = '';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPress(String digit) {
    if (_enteredPin.length >= 4) return;
    HapticFeedback.lightImpact();

    setState(() {
      _enteredPin += digit;
      _errorMessage = '';
    });

    if (_enteredPin.length == 4) {
      _submitPin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _errorMessage = '';
    });
  }

  void _triggerError(String msg) {
    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0.0);
    setState(() {
      _errorMessage = msg;
      _enteredPin = '';
    });
  }

  void _submitPin() {
    if (widget.isSetup) {
      if (_firstPin == null) {
        // Step 1 of setup: record first PIN, ask for confirmation
        setState(() {
          _firstPin = _enteredPin;
          _enteredPin = '';
        });
      } else {
        // Step 2 of setup: confirm
        if (_enteredPin == _firstPin) {
          widget.onPinCreated?.call(_enteredPin);
          widget.onUnlocked();
        } else {
          _firstPin = null;
          _triggerError('PINs did not match. Please start again.');
        }
      }
    } else {
      // Normal Unlock verification
      final ok = SecurityService.instance.verifyPin(_enteredPin);
      if (ok) {
        widget.onUnlocked();
      } else {
        _triggerError('Incorrect PIN. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = dark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    String title;
    String subtitle;
    if (widget.isSetup) {
      if (_firstPin == null) {
        title = 'Create App PIN';
        subtitle = 'Choose a 4-digit PIN to protect your PDFix files';
      } else {
        title = 'Confirm App PIN';
        subtitle = 'Re-enter your 4-digit PIN to confirm';
      }
    } else {
      title = 'PDFix Secure Lock';
      subtitle = 'Enter your 4-digit PIN to unlock';
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Logo & Shield Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5AEB), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B5AEB).withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.shield_rounded, color: Colors.white, size: 44),
              ),
            ),
            const SizedBox(height: 24),

            // Title & Subtitle
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 4-Digit Indicator Dots with shake animation
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (ctx, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value * (1 - _shakeController.value), 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final filled = index < _enteredPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: filled ? 18 : 16,
                    height: filled ? 18 : 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? const Color(0xFF1B5AEB)
                          : (dark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      boxShadow: filled
                          ? [
                              BoxShadow(
                                color: const Color(0xFF1B5AEB).withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),
            ),

            // Error Message
            const SizedBox(height: 16),
            SizedBox(
              height: 22,
              child: _errorMessage.isNotEmpty
                  ? Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),

            const Spacer(flex: 3),

            // Number Pad (1-9, empty, 0, backspace)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                children: [
                  _buildNumRow(['1', '2', '3'], cardBg, textColor, dark),
                  const SizedBox(height: 16),
                  _buildNumRow(['4', '5', '6'], cardBg, textColor, dark),
                  const SizedBox(height: 16),
                  _buildNumRow(['7', '8', '9'], cardBg, textColor, dark),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Cancel button if setup mode
                      widget.isSetup
                          ? _buildActionButton(
                              icon: Icons.close_rounded,
                              onTap: () => Navigator.pop(context),
                              color: textColor,
                            )
                          : const SizedBox(width: 72, height: 72),

                      _buildKeyButton('0', cardBg, textColor, dark),

                      _buildActionButton(
                        icon: Icons.backspace_rounded,
                        onTap: _onBackspace,
                        color: textColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNumRow(List<String> digits, Color cardBg, Color textColor, bool dark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: digits.map((d) => _buildKeyButton(d, cardBg, textColor, dark)).toList(),
    );
  }

  Widget _buildKeyButton(String digit, Color cardBg, Color textColor, bool dark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPress(digit),
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: cardBg,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.3 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        child: SizedBox(
          width: 72,
          height: 72,
          child: Icon(
            icon,
            size: 26,
            color: color,
          ),
        ),
      ),
    );
  }
}

