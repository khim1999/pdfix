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
      });
    }
  }

  Future<void> _run() async {
    if (file == null) return;
    setState(() {
      busy = true;
      progress = 0;
      results = [];
    });
    try {
      final out = await PdfService.pdfToImages(file!, (p) {
        if (mounted) setState(() => progress = p);
      });
      if (mounted) setState(() => results = out);
    } catch (_) {
      if (mounted) showError(context, 'Could not convert PDF to images.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
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

