import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:pdfx/pdfx.dart';

import '../services/direct_share_service.dart';
import '../services/pdf_service.dart';
import '../theme.dart';
import '../widgets.dart';

class PdfViewerScreen extends StatefulWidget {
  final File file;
  final String title;
  final String? subtitle;

  const PdfViewerScreen({
    super.key,
    required this.file,
    required this.title,
    this.subtitle,
  });

  static Future<void> open(
    BuildContext context, {
    required File file,
    String? title,
    String? subtitle,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          file: file,
          title: title ?? p.basename(file.path),
          subtitle: subtitle,
        ),
      ),
    );
  }

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late final PdfController _controller;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = PdfController(
      document: PdfDocument.openFile(widget.file.path),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final ok = await PdfService.saveToDevice(widget.file);
      if (!mounted) return;
      if (ok) {
        showSuccess(context, 'PDF saved to your device storage');
      } else {
        showError(context, 'Could not save file. Try sharing instead.');
      }
    } catch (e) {
      if (mounted) showError(context, 'Save error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _share() {
    DirectShareService.showShareSheet(
      context,
      file: widget.file,
      title: widget.title,
      detail: widget.subtitle,
    );
  }

  Future<void> _remove() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove File?'),
        content: const Text('Do you want to remove and delete this file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      try {
        if (await widget.file.exists()) await widget.file.delete();
      } catch (_) {}
      if (mounted) {
        Navigator.pop(context, true);
        showSuccess(context, 'File removed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E242B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111418),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.subtitle != null)
              Text(
                widget.subtitle!,
                style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
              ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _totalPages > 0 ? '$_currentPage / $_totalPages' : '...',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          IconButton(
            tooltip: 'Share (Telegram, Teams, Outlook...)',
            onPressed: _share,
            icon: const Icon(Icons.share_rounded, size: 20),
          ),
          IconButton(
            tooltip: 'Remove / Delete file',
            onPressed: _remove,
            icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.white70),
          ),
        ],
      ),
      body: Stack(
        children: [
          PdfView(
            controller: _controller,
            scrollDirection: Axis.vertical,
            backgroundDecoration: const BoxDecoration(color: Color(0xFF1E242B)),
            renderer: (page) => page.render(
              width: page.width * 2.2,
              height: page.height * 2.2,
              format: PdfPageImageFormat.jpeg,
              backgroundColor: '#FFFFFF',
              quality: 92,
            ),
            onDocumentLoaded: (doc) {
              if (mounted) {
                setState(() => _totalPages = doc.pagesCount);
              }
            },
            onPageChanged: (page) {
              if (mounted) {
                setState(() => _currentPage = page);
              }
            },
            builders: PdfViewBuilders<DefaultBuilderOptions>(
              options: const DefaultBuilderOptions(),
              documentLoaderBuilder: (_) => const Center(
                child: CircularProgressIndicator(color: Brand.compress),
              ),
              pageLoaderBuilder: (_) => const Center(
                child: CircularProgressIndicator(color: Brand.compress),
              ),
              errorBuilder: (_, error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Unable to display PDF:\n$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 0.8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_in_rounded, size: 16, color: Color(0xFF60A5FA)),
                    SizedBox(width: 6),
                    Text(
                      'Pinch or double-tap to zoom in & check clarity',
                      style: TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF111418),
        padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + MediaQuery.of(context).padding.bottom),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _share,
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text(
                  'Share (Telegram, Teams…)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.download_rounded, size: 18),
                label: Text(_saving ? 'Saving...' : 'Save to Device'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Brand.compress,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

