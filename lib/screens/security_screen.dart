import 'package:flutter/material.dart';
import '../services/security_service.dart';
import 'lock_screen.dart';
import 'protect_screen.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _sec = SecurityService.instance;
  CacheStats? _cacheStats;
  bool _wiping = false;

  @override
  void initState() {
    super.initState();
    _loadCacheStats();
  }

  Future<void> _loadCacheStats() async {
    final stats = await _sec.getCacheStats();
    if (mounted) {
      setState(() => _cacheStats = stats);
    }
  }

  Future<void> _handleAppLockToggle(bool enable) async {
    if (enable) {
      if (!_sec.hasPin) {
        // Must create PIN first
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LockScreen(
              isSetup: true,
              onPinCreated: (pin) async {
                await _sec.setPin(pin);
              },
              onUnlocked: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✔ App Lock PIN created and enabled!'),
                    backgroundColor: Color(0xFF16A34A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        );
      } else {
        await _sec.enableAppLock();
      }
    } else {
      // Confirm with current PIN before turning off
      final confirmed = await _verifyCurrentPin();
      if (confirmed) {
        await _sec.disableAppLock();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('App Lock disabled.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
    setState(() {});
  }

  Future<bool> _verifyCurrentPin() async {
    if (!_sec.hasPin) return true;
    bool verified = false;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LockScreen(
          onUnlocked: () {
            verified = true;
            Navigator.pop(context);
          },
        ),
      ),
    );
    return verified;
  }

  Future<void> _changePin() async {
    final confirmed = await _verifyCurrentPin();
    if (!confirmed) return;

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LockScreen(
          isSetup: true,
          onPinCreated: (newPin) async {
            await _sec.setPin(newPin);
          },
          onUnlocked: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✔ App Lock PIN updated successfully!'),
                backgroundColor: Color(0xFF16A34A),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _wipeCacheNow() async {
    setState(() => _wiping = true);
    final result = await _sec.wipeCache();
    await _loadCacheStats();
    if (mounted) {
      setState(() => _wiping = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✔ Purged ${result.fileCount} temporary files (${result.formattedSize} freed)'),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = dark ? const Color(0xFF1E293B) : Colors.white;
    final border = dark ? Colors.white12 : Colors.black.withOpacity(0.06);

    final isFullyProtected = _sec.isAppLockEnabled && _sec.isSecureScreenEnabled;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Security & Privacy', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
        children: [
          // Security Status Score Header
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isFullyProtected
                    ? [const Color(0xFF059669), const Color(0xFF10B981)]
                    : [const Color(0xFF1B5AEB), const Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (isFullyProtected ? const Color(0xFF10B981) : const Color(0xFF1B5AEB))
                      .withOpacity(0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFullyProtected ? Icons.verified_user_rounded : Icons.shield_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFullyProtected ? 'All Systems Protected' : 'Security Active',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isFullyProtected
                            ? 'App Lock, Anti-Spy, and Offline Privacy are actively guarding your files.'
                            : 'Customize your PIN lock and screenshot protection below.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          _sectionHeader('ACCESS PROTECTION'),
          const SizedBox(height: 12),

          // Feature 1: App Lock (4-Digit PIN)
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  secondary: _iconBadge(Icons.lock_rounded, const Color(0xFF1B5AEB), dark),
                  title: const Text('App Lock (4-Digit PIN)',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                  subtitle: Text(
                    'Require PIN whenever PDFix is opened or resumed from background.',
                    style: TextStyle(fontSize: 12.5, color: Theme.of(context).hintColor),
                  ),
                  value: _sec.isAppLockEnabled,
                  activeColor: const Color(0xFF1B5AEB),
                  onChanged: _handleAppLockToggle,
                ),
                if (_sec.hasPin) ...[
                  Divider(height: 1, color: border),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                    leading: const SizedBox(width: 40),
                    title: const Text('Change 4-Digit PIN',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: _changePin,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),
          _sectionHeader('SCREEN & MEMORY PRIVACY'),
          const SizedBox(height: 12),

          // Feature 2: Anti-Spy / Screenshot Blocker
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              secondary: _iconBadge(Icons.no_photography_rounded, const Color(0xFF9333EA), dark),
              title: const Text('Anti-Spy Screen / Screenshot Shield',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
              subtitle: Text(
                'Blocks screenshots and hides document contents in recent apps switcher.',
                style: TextStyle(fontSize: 12.5, color: Theme.of(context).hintColor),
              ),
              value: _sec.isSecureScreenEnabled,
              activeColor: const Color(0xFF9333EA),
              onChanged: (val) async {
                final messenger = ScaffoldMessenger.of(context);
                await _sec.setSecureScreen(val);
                if (mounted) setState(() {});
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(val
                        ? '🛡️ Screenshot blocking & Recent Apps privacy enabled.'
                        : 'Screenshot blocking disabled.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          _sectionHeader('STORAGE & CACHE CLEANER'),
          const SizedBox(height: 12),

          // Feature 3: Temporary Cache & File Shredder
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _iconBadge(Icons.cleaning_services_rounded, const Color(0xFFEA580C), dark),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Temporary Files Cleaner',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                          const SizedBox(height: 2),
                          Text(
                            _cacheStats == null
                                ? 'Calculating cache size…'
                                : '${_cacheStats!.formattedSize} used across ${_cacheStats!.fileCount} temporary files',
                            style: TextStyle(fontSize: 12.5, color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _wiping ? null : _wipeCacheNow,
                    icon: _wiping
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_sweep_rounded, size: 18),
                    label: Text(_wiping ? 'Clearing Files…' : 'Clean Temporary Files Now'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEA580C),
                      side: const BorderSide(color: Color(0xFFEA580C)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: border),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto-Clean on App Launch',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  subtitle: Text(
                    'Automatically clears temporary files whenever PDFix opens.',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                  ),
                  value: _sec.isAutoWipeEnabled,
                  activeColor: const Color(0xFFEA580C),
                  onChanged: (val) async {
                    await _sec.setAutoWipe(val);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _sectionHeader('DOCUMENT & OFFLINE PRIVACY'),
          const SizedBox(height: 12),

          // Feature 4: AES-256 PDF Password Encryption
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  leading: _iconBadge(Icons.enhanced_encryption_rounded, const Color(0xFF0284C7), dark),
                  title: const Text('Encrypt PDF with Password',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                  subtitle: Text(
                    'Add AES-256 military-grade password protection to any PDF document.',
                    style: TextStyle(fontSize: 12.5, color: Theme.of(context).hintColor),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProtectScreen()),
                    );
                  },
                ),
                Divider(height: 1, color: border),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _checkItem('100% On-Device Processing (No Cloud Uploads)'),
                      const SizedBox(height: 8),
                      _checkItem('Zero Telemetry & Zero External Analytics'),
                      const SizedBox(height: 8),
                      _checkItem('Protected Scoped Storage (Files Stay in PDFix)'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: Theme.of(context).hintColor.withOpacity(0.7),
      ),
    );
  }

  Widget _iconBadge(IconData icon, Color color, bool dark) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _checkItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

