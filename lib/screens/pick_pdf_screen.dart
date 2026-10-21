import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../services/pdf_service.dart';
import '../theme.dart';
import '../widgets.dart';

class PickPdfScreen extends StatefulWidget {
  final String title;
  final Color accent;
  final Color accentSoft;

  const PickPdfScreen({
    super.key,
    this.title = 'Select PDF Document',
    this.accent = Brand.compress,
    this.accentSoft = Brand.compressSoft,
  });

  static Future<PickedPdf?> pick(
    BuildContext context, {
    String title = 'Select PDF Document',
    Color accent = Brand.compress,
    Color accentSoft = Brand.compressSoft,
  }) {
    return Navigator.push<PickedPdf>(
      context,
      MaterialPageRoute(
        builder: (_) => PickPdfScreen(
          title: title,
          accent: accent,
          accentSoft: accentSoft,
        ),
      ),
    );
  }

  @override
  State<PickPdfScreen> createState() => _PickPdfScreenState();
}

class _PickPdfScreenState extends State<PickPdfScreen> {
  bool _loading = false;
  List<PickedPdf> _recentFiles = [];

  @override
  void initState() {
    super.initState();
    _loadRecentDocuments();
  }

  Future<void> _loadRecentDocuments() async {
    try {
      final list = <PickedPdf>[];
      // Scan standard paths
      final checkDirs = [
        Directory('/sdcard/Download'),
        Directory('/sdcard/Documents'),
        Directory('/storage/emulated/0/Download'),
        Directory('/storage/emulated/0/Documents'),
      ];

      final foundFiles = <File>[];
      for (final dir in checkDirs) {
        if (await dir.exists()) {
          try {
            final entities = dir.listSync();
            for (final entity in entities) {
              if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
                if (!foundFiles.any((x) => x.path == entity.path)) {
                  foundFiles.add(entity);
                }
              }
            }
          } catch (_) {}
        }
      }

      // Sort by last modified (newest first) and take the top 12
      foundFiles.sort((a, b) {
        try {
          return b.lastModifiedSync().compareTo(a.lastModifiedSync());
        } catch (_) {
          return 0;
        }
      });

      for (final entity in foundFiles.take(12)) {
        try {
          final length = await entity.length();
          final pages = await PdfService.getPageCount(entity.path);
          list.add(PickedPdf(
            entity.path,
            p.basename(entity.path),
            length,
            pages,
          ));
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _recentFiles = list;
        });
      }
    } catch (_) {}
  }

  Future<void> _browseDeviceFiles() async {
    setState(() => _loading = true);
    try {
      final result = await PdfService.pick();
      if (!mounted) return;
      if (result != null) {
        Navigator.pop(context, result);
      }
    } catch (_) {
      if (mounted) {
        showError(context, 'Could not open selected file.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to app',
          onPressed: () => Navigator.pop(context, null),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // Safe & Offline Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Brand.success.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Brand.success.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_rounded, color: Brand.success, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '100% On-Device & Safe',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Brand.success,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Your documents never leave this device. Processing is 100% offline.',
                          style: TextStyle(fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Big Browse Button Card
            InkWell(
              onTap: _loading ? null : _browseDeviceFiles,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.accent.withOpacity(0.12),
                      widget.accentSoft.withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: widget.accent.withOpacity(0.5), width: 1.5),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: widget.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.accent.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Icon(
                              Icons.folder_open_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Browse Phone Storage',
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap to choose any PDF from Downloads, Internal Memory, or SD Card',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: widget.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app_rounded,
                              size: 16, color: widget.accent),
                          const SizedBox(width: 6),
                          Text(
                            'Tap here to browse',
                            style: TextStyle(
                              color: widget.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // If any device files found, list them
            if (_recentFiles.isNotEmpty) ...[
              const SectionTitle('Device PDF Documents'),
              for (final f in _recentFiles)
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  tileColor: cardColor(context),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.picture_as_pdf_rounded,
                        color: widget.accent, size: 24),
                  ),
                  title: Text(
                    f.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${formatBytes(f.size)}  •  ${f.pages} pages',
                    style: TextStyle(
                        fontSize: 12, color: Theme.of(context).hintColor),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14),
                  onTap: () => Navigator.pop(context, f),
                ),
              const SizedBox(height: 16),
            ],

            // Back to App explicit button
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, null),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to App'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
