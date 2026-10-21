import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/pdf_service.dart';
import '../theme.dart';
import '../widgets.dart';
import 'pick_pdf_screen.dart';

class PdfToImagesScreen extends StatefulWidget {
  const PdfToImagesScreen({super.key});
  @override
  State<PdfToImagesScreen> createState() => _PdfToImagesScreenState();
}

class _PdfToImagesScreenState extends State<PdfToImagesScreen> {
  PickedPdf? file;
  bool busy = false;
  double progress = 0;
  String status = '';
  bool _cancelled = false;
  List<File> results = [];

  Future<void> _pick() async {
    final f = await PickPdfScreen.pick(
      context,
      title: 'Select PDF to Convert',
      accent: Brand.pdfToImg,
      accentSoft: Brand.pdfToImgSoft,
    );
    if (f != null && mounted) {
      setState(() {
        file = f;
        results = [];
        status = '';
      });
    }
  }

  Future<void> _run() async {
    if (busy || file == null) return;
    setState(() {
      busy = true;
      progress = 0;
      status = 'Preparing pages…';
      _cancelled = false;
      results = [];
    });
    try {
      final out = await PdfService.pdfToImages(
        file!,
        (p, [s]) {
          if (mounted) {
            setState(() {
              progress = p;
              if (s != null) status = s;
            });
          }
        },
        isCancelled: () => _cancelled,
      );
      if (_cancelled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conversion cancelled.')),
          );
        }
        return;
      }
      if (mounted) setState(() => results = out);
    } catch (_) {
      if (mounted && !_cancelled) showError(context, 'Could not convert PDF to images.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _cancel() {
    setState(() {
      _cancelled = true;
      status = 'Cancelling…';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'PDF to Images',
      subtitle: 'Save each page as a photo image.',
      accent: Brand.pdfToImg,
      accentSoft: Brand.pdfToImgSoft,
      icon: Icons.photo_library_rounded,
      children: [
        PickCard(
          file: file,
          accent: Brand.pdfToImg,
          onPick: _pick,
          onClear: () => setState(() {
            file = null;
            results = [];
          }),
        ),
        const SizedBox(height: 20),
        GradientButton(
          label: 'Extract to JPG Images',
          icon: Icons.image_rounded,
          accent: Brand.pdfToImg,
          accentSoft: Brand.pdfToImgSoft,
          busy: busy,
          progress: progress,
          status: status,
          onCancel: _cancel,
          onPressed: file == null ? null : _run,
        ),
        if (results.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${results.length} Images Extracted',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                TextButton.icon(
                  onPressed: () => Share.shareXFiles([
                    for (final f in results) XFile(f.path, mimeType: 'image/jpeg'),
                  ], text: 'Sharing images via PDFix'),
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('Share all'),
                ),
              ],
            ),
          ),
          for (final f in results)
            FileResultTile(
              name: f.uri.pathSegments.last,
              detail: formatBytes(f.lengthSync()),
              accent: Brand.pdfToImg,
              path: f.path,
              onRemove: () => setState(() => results.remove(f)),
            ),
        ],
      ],
    );
  }
}

