import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class CacheStats {
  final int fileCount;
  final int totalBytes;

  const CacheStats({required this.fileCount, required this.totalBytes});

  String get formattedSize {
    if (totalBytes <= 0) return '0 KB';
    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

class SecurityService extends ChangeNotifier {
  static final SecurityService instance = SecurityService._();
  SecurityService._();

  static const _channel = MethodChannel('com.ttfc.pdfix/direct_share');
  static const _configFileName = '.pdfix_security.json';

  bool _initialized = false;
  bool _isAppLockEnabled = false;
  bool _isSecureScreenEnabled = false;
  bool _isAutoWipeEnabled = false;
  bool _isLocked = false;
  String? _pinHash;
  String? _pinSalt;

  bool get isInitialized => _initialized;
  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get isSecureScreenEnabled => _isSecureScreenEnabled;
  bool get isAutoWipeEnabled => _isAutoWipeEnabled;
  bool get isLocked => _isLocked;
  bool get hasPin => _pinHash != null && _pinSalt != null;

  /// Initializes the security service, loads saved configuration and applies FLAG_SECURE.
  Future<void> init() async {
    if (_initialized) return;
    try {
      final file = await _getConfigFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final map = jsonDecode(content) as Map<String, dynamic>;
        _isAppLockEnabled = map['app_lock'] == true;
        _isSecureScreenEnabled = map['secure_screen'] == true;
        _isAutoWipeEnabled = map['auto_wipe'] == true;
        _pinHash = map['pin_hash'] as String?;
        _pinSalt = map['pin_salt'] as String?;

        if (_isAppLockEnabled && hasPin) {
          _isLocked = true;
        }
      }
    } catch (e) {
      debugPrint('SecurityService load error: $e');
    }

    // Apply native FLAG_SECURE
    if (Platform.isAndroid && _isSecureScreenEnabled) {
      await _applySecureScreen(true);
    }

    // If auto-wipe is on, do a cleanup on startup
    if (_isAutoWipeEnabled) {
      await wipeCache();
    }

    _initialized = true;
    notifyListeners();
  }

  Future<File> _getConfigFile() async {
    final docs = await getApplicationDocumentsDirectory();
    return File('${docs.path}/$_configFileName');
  }

  Future<void> _saveConfig() async {
    try {
      final file = await _getConfigFile();
      final map = {
        'app_lock': _isAppLockEnabled,
        'secure_screen': _isSecureScreenEnabled,
        'auto_wipe': _isAutoWipeEnabled,
        'pin_hash': _pinHash,
        'pin_salt': _pinSalt,
        'updated_at': DateTime.now().toIso8601String(),
      };
      await file.writeAsString(jsonEncode(map), flush: true);
    } catch (e) {
      debugPrint('SecurityService save error: $e');
    }
    notifyListeners();
  }

  Future<void> _applySecureScreen(bool enabled) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('setSecureScreen', {'enabled': enabled});
    } catch (e) {
      debugPrint('Failed to set FLAG_SECURE: $e');
    }
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin:pdfix_secure_key');
    return sha256.convert(bytes).toString();
  }

  String _generateSalt() {
    final rand = Random.secure();
    final values = List<int>.generate(16, (i) => rand.nextInt(256));
    return base64UrlEncode(values);
  }

  /// Sets or updates the 4-digit PIN.
  Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    _pinSalt = salt;
    _pinHash = hash;
    _isAppLockEnabled = true;
    _isLocked = false;
    await _saveConfig();
  }

  /// Verifies entered PIN. Unlocks if correct.
  bool verifyPin(String pin) {
    if (!hasPin) return true;
    final hash = _hashPin(pin, _pinSalt!);
    if (hash == _pinHash) {
      _isLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Disables App Lock.
  Future<void> disableAppLock() async {
    _isAppLockEnabled = false;
    _isLocked = false;
    await _saveConfig();
  }

  /// Enables App Lock (requires PIN already set).
  Future<bool> enableAppLock() async {
    if (!hasPin) return false;
    _isAppLockEnabled = true;
    await _saveConfig();
    return true;
  }

  /// Toggles Anti-Spy / Screenshot protection (`FLAG_SECURE`).
  Future<void> setSecureScreen(bool enabled) async {
    _isSecureScreenEnabled = enabled;
    await _applySecureScreen(enabled);
    await _saveConfig();
  }

  /// Toggles automatic temporary cache wipe on exit/startup.
  Future<void> setAutoWipe(bool enabled) async {
    _isAutoWipeEnabled = enabled;
    await _saveConfig();
  }

  /// Locks the app manually or on background event.
  void lock() {
    if (_isAppLockEnabled && hasPin && !_isLocked) {
      _isLocked = true;
      notifyListeners();
    }
  }

  /// Unlocks the app manually.
  void unlock() {
    _isLocked = false;
    notifyListeners();
  }

  /// Calculates current cache size and count.
  Future<CacheStats> getCacheStats() async {
    int count = 0;
    int bytes = 0;
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            count++;
            bytes += await entity.length();
          }
        }
      }
    } catch (_) {}
    return CacheStats(fileCount: count, totalBytes: bytes);
  }

  /// Securely clears all temporary cache files.
  Future<CacheStats> wipeCache() async {
    int deleted = 0;
    int bytesFreed = 0;
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list(recursive: false)) {
          try {
            if (entity is File) {
              bytesFreed += await entity.length();
              await entity.delete();
              deleted++;
            } else if (entity is Directory) {
              await for (final sub in entity.list(recursive: true)) {
                if (sub is File) {
                  bytesFreed += await sub.length();
                  deleted++;
                }
              }
              await entity.delete(recursive: true);
            }
          } catch (_) {}
        }
      }
    } catch (_) {}
    notifyListeners();
    return CacheStats(fileCount: deleted, totalBytes: bytesFreed);
  }
}

