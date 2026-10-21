import 'dart:io';
import 'package:flutter/material.dart';
import 'screens/pdf_viewer_screen.dart';
import 'services/direct_share_service.dart';
import 'services/pdf_service.dart';
import 'theme.dart';

/// Page shell: coloured header band + rounded sheet for content.
class ToolScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final Color accentSoft;
  final IconData icon;
  final List<Widget> children;

  const ToolScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.accentSoft,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent, accentSoft],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 24, 0),
                  child: Row(children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                    const Spacer(),
                    Icon(icon, color: Colors.white.withOpacity(.9)),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1.05)),
                      const SizedBox(height: 8),
                      Text(subtitle,
                          style: TextStyle(
                              color: Colors.white.withOpacity(.88), fontSize: 15)),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: ListView(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                      children: children,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PickCard extends StatelessWidget {
  final PickedPdf? file;
  final Color accent;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const PickCard({
    super.key,
    required this.file,
    required this.accent,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final f = file;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: f == null
          ? InkWell(
              key: const ValueKey('empty'),
              onTap: onPick,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
                decoration: BoxDecoration(
                  color: accent.withOpacity(.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accent.withOpacity(.45), width: 1.5),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration:
                          BoxDecoration(color: accent, shape: BoxShape.circle),
                      child: const Icon(Icons.upload_file_rounded,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 14),
                    const Text('Choose a PDF',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Tap to browse and select from your device',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 14)),
                  ],
                ),
              ),
            )
          : Container(
              key: const ValueKey('file'),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor(context),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.picture_as_pdf_rounded, color: accent, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 3),
                      Text('${formatBytes(f.size)}  •  ${f.pages} pages',
                          style: TextStyle(color: Theme.of(context).hintColor)),
                    ],
                  ),
                ),
                IconButton(onPressed: onClear, icon: const Icon(Icons.close_rounded)),
              ]),
            ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accent;
  final Color accentSoft;
  final bool busy;
  final double progress;
  final String? status;
  final VoidCallback? onCancel;
  final VoidCallback? onPressed;

  const GradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.accent,
    required this.accentSoft,
    required this.onPressed,
    this.busy = false,
    this.progress = 0,
    this.status,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (busy && onCancel != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [accent, accentSoft]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        color: Colors.white,
                        value: progress > 0 ? progress : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        status ?? (progress > 0 ? 'Working… ${(progress * 100).round()}%' : 'Working…'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded, size: 18, color: Colors.redAccent),
            label: const Text('Cancel Operation', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      );
    }

    final enabled = onPressed != null && !busy;
    return Opacity(
      opacity: onPressed == null ? .45 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [accent, accentSoft]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: busy
                  ? Row(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          color: Colors.white,
                          value: progress > 0 ? progress : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          status ?? (progress > 0 ? 'Working… ${(progress * 100).round()}%' : 'Working…'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ])
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(icon, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                    ]),
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 26, bottom: 12, left: 4),
        child: Text(text,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      );
}

class FileResultTile extends StatelessWidget {
  final String name;
  final String detail;
  final Color accent;
  final String path;
  final VoidCallback? onRemove;

  const FileResultTile({
    super.key,
    required this.name,
    required this.detail,
    required this.accent,
    required this.path,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final file = File(path);
    final isImage = RegExp(r'\.(jpg|jpeg|png)$', caseSensitive: false).hasMatch(path);

    void openViewer() {
      if (isImage) {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: Colors.black87,
            insetPadding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InteractiveViewer(
                    child: Image.file(file),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        PdfViewerScreen.open(
          context,
          file: file,
          title: name,
          subtitle: detail,
        );
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: dark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: File icon, Name, detail, Remove button
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isImage ? Icons.image_rounded : Icons.picture_as_pdf_rounded,
                    color: accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Brand.success.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 12, color: Brand.success),
                                SizedBox(width: 4),
                                Text(
                                  'Ready',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Brand.success),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              detail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Theme.of(context).hintColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    tooltip: 'Remove file',
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Theme.of(context).hintColor.withOpacity(0.8),
                      size: 20,
                    ),
                    onPressed: () async {
                      try {
                        if (await file.exists()) {
                          await file.delete();
                        }
                      } catch (_) {}
                      if (context.mounted) {
                        onRemove?.call();
                        showSuccess(context, 'File removed');
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 14),
            // Modern Action Row: View, Share, Save
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: openViewer,
                    icon: const Icon(Icons.visibility_rounded, size: 17),
                    label: const Text('View', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => DirectShareService.showShareSheet(
                      context,
                      file: file,
                      title: name,
                      detail: detail,
                    ),
                    icon: const Icon(Icons.share_rounded, size: 17),
                    label: const Text(
                      'Share',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: dark ? Colors.white : Colors.black87,
                      side: BorderSide(
                        color: dark ? Colors.white24 : Colors.black12,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: dark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    tooltip: 'Save to device storage',
                    icon: Icon(Icons.download_rounded, color: accent, size: 20),
                    onPressed: () async {
                      try {
                        final ok = await PdfService.saveToDevice(file);
                        if (ok && context.mounted) {
                          showSuccess(context, 'Saved to Downloads folder');
                        }
                      } catch (_) {
                        if (context.mounted) {
                          showError(context, 'Could not save file. Try Share instead.');
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showToast(BuildContext context, String msg, {bool isError = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(msg)),
        ],
      ),
      backgroundColor: isError ? Colors.red.shade800 : const Color(0xFF10B981),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
}

void showError(BuildContext context, String msg) =>
    showToast(context, msg, isError: true);

void showSuccess(BuildContext context, String msg) =>
    showToast(context, msg, isError: false);
