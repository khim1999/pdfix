import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'pdf_service.dart';

class DirectShareService {
  static const _channel = MethodChannel('com.ttfc.pdfix/direct_share');

  static const telegramPackages = [
    'org.telegram.messenger',
    'org.telegram.messenger.web',
    'org.telegram.plus',
    'org.thunderdog.challegram',
  ];

  static const teamsPackages = [
    'com.microsoft.teams',
    'com.microsoft.teams.enterprise',
  ];

  static const outlookPackages = [
    'com.microsoft.office.outlook',
  ];

  static const whatsappPackages = [
    'com.whatsapp',
    'com.whatsapp.w4b',
  ];

  static Future<bool> shareToApp({
    required String filePath,
    required List<String> packages,
    String? mimeType,
    String? title,
  }) async {
    if (!Platform.isAndroid) {
      await Share.shareXFiles(
        [XFile(filePath, mimeType: mimeType ?? 'application/pdf')],
        subject: title ?? 'Share Document',
      );
      return true;
    }

    try {
      final res = await _channel.invokeMethod<bool>('shareDirect', {
        'filePath': filePath,
        'packages': packages,
        'mimeType': mimeType ?? 'application/pdf',
        'title': title ?? 'Share Document',
      });
      return res ?? false;
    } catch (e) {
      debugPrint('DirectShareService error: $e');
      return false;
    }
  }

  static Future<void> shareSystem({
    required String filePath,
    String? mimeType,
    String? title,
  }) async {
    await Share.shareXFiles(
      [XFile(filePath, mimeType: mimeType ?? 'application/pdf')],
      subject: title ?? 'Share Document',
      text: 'Sharing ${title ?? 'document'} via PDFix',
    );
  }

  static Future<void> _shareWithCheck(
    BuildContext context, {
    required String appName,
    required File file,
    required List<String> packages,
    required String mimeType,
    required String fileName,
  }) async {
    final ok = await shareToApp(
      filePath: file.path,
      packages: packages,
      mimeType: mimeType,
      title: fileName,
    );
    if (!ok && context.mounted) {
      showDialog(
        context: context,
        builder: (dlgCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFF1B5AEB), size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$appName Not Found',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
            ],
          ),
          content: Text(
            '$appName is not installed on this device / emulator.\n\n'
            'On your physical smartphone where $appName is installed, tapping this button opens $appName directly.\n\n'
            'Would you like to share using other available apps instead?',
            style: const TextStyle(fontSize: 14, height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.share_rounded, size: 17),
              label: const Text('Use Other Apps'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1B5AEB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(dlgCtx);
                shareSystem(filePath: file.path, mimeType: mimeType, title: fileName);
              },
            ),
          ],
        ),
      );
    }
  }

  /// Displays the custom, modern Share Bottom Sheet with direct Telegram, Teams, Outlook & WhatsApp options.
  static void showShareSheet(
    BuildContext context, {
    required File file,
    String? title,
    String? detail,
  }) {
    final fileName = title ?? p.basename(file.path);
    final isImage = RegExp(r'\.(jpg|jpeg|png)$', caseSensitive: false).hasMatch(file.path);
    final mimeType = isImage ? 'image/jpeg' : 'application/pdf';
    final dark = Theme.of(context).brightness == Brightness.dark;

    String sizeLabel = '';
    try {
      if (file.existsSync()) {
        final bytes = file.lengthSync();
        sizeLabel = bytes > 1024 * 1024
            ? '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB'
            : '${(bytes / 1024).toStringAsFixed(1)} KB';
      }
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF1E222B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: dark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // File preview header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isImage
                          ? Colors.purple.withOpacity(0.12)
                          : Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isImage ? Icons.image_rounded : Icons.picture_as_pdf_rounded,
                      color: isImage ? Colors.purple : Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        if (sizeLabel.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            sizeLabel,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Theme.of(ctx).hintColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),
              Text(
                'SHARE DIRECTLY TO',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: Theme.of(ctx).hintColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 14),

              // Apps Row: Telegram, Teams, Outlook, WhatsApp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Telegram
                  _ShareAppButton(
                    name: 'Telegram',
                    icon: Icons.send_rounded,
                    color: const Color(0xFF229ED9),
                    onTap: () {
                      Navigator.pop(ctx);
                      _shareWithCheck(
                        context,
                        appName: 'Telegram',
                        file: file,
                        packages: telegramPackages,
                        mimeType: mimeType,
                        fileName: fileName,
                      );
                    },
                  ),

                  // Teams
                  _ShareAppButton(
                    name: 'Teams',
                    icon: Icons.groups_rounded,
                    color: const Color(0xFF5059C9),
                    onTap: () {
                      Navigator.pop(ctx);
                      _shareWithCheck(
                        context,
                        appName: 'Microsoft Teams',
                        file: file,
                        packages: teamsPackages,
                        mimeType: mimeType,
                        fileName: fileName,
                      );
                    },
                  ),

                  // Outlook
                  _ShareAppButton(
                    name: 'Outlook',
                    icon: Icons.email_rounded,
                    color: const Color(0xFF0078D4),
                    onTap: () {
                      Navigator.pop(ctx);
                      _shareWithCheck(
                        context,
                        appName: 'Microsoft Outlook',
                        file: file,
                        packages: outlookPackages,
                        mimeType: mimeType,
                        fileName: fileName,
                      );
                    },
                  ),

                  // WhatsApp
                  _ShareAppButton(
                    name: 'WhatsApp',
                    icon: Icons.chat_rounded,
                    color: const Color(0xFF25D366),
                    onTap: () {
                      Navigator.pop(ctx);
                      _shareWithCheck(
                        context,
                        appName: 'WhatsApp',
                        file: file,
                        packages: whatsappPackages,
                        mimeType: mimeType,
                        fileName: fileName,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Divider(color: dark ? Colors.white12 : Colors.black12, height: 1),
              const SizedBox(height: 14),

              // Option 1: More Apps (System Chooser)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: dark ? Colors.white10 : Colors.grey.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.share_rounded,
                    color: dark ? Colors.white70 : Colors.black87,
                    size: 22,
                  ),
                ),
                title: const Text('More Apps…',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                subtitle: Text(
                  'Quick Share, Drive, Gmail, Bluetooth & more',
                  style: TextStyle(fontSize: 12.5, color: Theme.of(ctx).hintColor),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  shareSystem(filePath: file.path, mimeType: mimeType, title: fileName);
                },
              ),

              // Option 2: Save to device storage
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5AEB).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.download_rounded,
                    color: Color(0xFF1B5AEB),
                    size: 22,
                  ),
                ),
                title: const Text('Save to Device',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                subtitle: Text(
                  'Save copy to Downloads / PDFix folder',
                  style: TextStyle(fontSize: 12.5, color: Theme.of(ctx).hintColor),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final ok = await PdfService.saveToDevice(file);
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✔ Saved to Downloads folder'),
                          backgroundColor: Color(0xFF16A34A),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (_) {}
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShareAppButton extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ShareAppButton({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}

