import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/pdf_service.dart';
import '../theme.dart';
import '../widgets.dart';
import 'pick_pdf_screen.dart';

class SplitScreen extends StatefulWidget {
  const SplitScreen({super.key});
  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  PickedPdf? file;
  SplitMode mode = SplitMode.ranges;
  final rangeCtrl = TextEditingController();
  final nCtrl = TextEditingController(text: '2');
  bool busy = false;
  double progress = 0;
  String status = '';
  bool _cancelled = false;
  List<File> results = [];

  @override
  void dispose() {
    rangeCtrl.dispose();
    nCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final f = await PickPdfScreen.pick(
      context,
      title: 'Select PDF to Split',
      accent: Brand.split,
      accentSoft: Brand.splitSoft,
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
    final f = file!;
    List<List<int>> groups;
    try {
      switch (mode) {
        case SplitMode.ranges:
          groups = PdfService.parseRanges(rangeCtrl.text, f.pages);
        case SplitMode.everyPage:
          groups = PdfService.everyN(1, f.pages);
        case SplitMode.everyN:
          final n = int.tryParse(nCtrl.text.trim()) ?? 0;
          if (n < 1) throw const FormatException('Enter a number of pages above 0.');
          groups = PdfService.everyN(n, f.pages);
      }
    } on FormatException catch (e) {
      showError(context, e.message);
      return;
    }
    if (groups.length > 100) {
      showError(context, 'That would create ${groups.length} files. Limit is 100.');
      return;
    }
    setState(() {
      busy = true;
      progress = 0;
      status = 'Preparing split…';
      _cancelled = false;
      results = [];
    });
    try {
      final out = await PdfService.split(
        f,
        groups,
        (v, [s]) {
          if (mounted) {
            setState(() {
              progress = v;
              if (s != null) status = s;
            });
          }
        },
        isCancelled: () => _cancelled,
      );
      if (_cancelled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Split operation cancelled.')),
          );
        }
        return;
      }
      if (mounted) setState(() => results = out);
    } catch (_) {
      if (mounted && !_cancelled) {
        showError(context, 'Could not split this file. It may be protected or damaged.');
      }
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
      title: 'Split PDF',
      subtitle: 'Separate a document into individual pages or parts.',
      accent: Brand.split,
      accentSoft: Brand.splitSoft,
      icon: Icons.call_split_rounded,
      children: [
        PickCard(
          file: file,
          accent: Brand.split,
          onPick: _pick,
          onClear: () => setState(() {
            file = null;
            results = [];
          }),
        ),
        const SectionTitle('How to split'),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<SplitMode>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: Brand.split,
              selectedForegroundColor: Colors.white,
            ),
            segments: const [
              ButtonSegment(value: SplitMode.ranges, label: Text('Page Ranges')),
              ButtonSegment(value: SplitMode.everyPage, label: Text('Single Pages')),
              ButtonSegment(value: SplitMode.everyN, label: Text('By Page Count')),
            ],
            selected: {mode},
            onSelectionChanged: (s) => setState(() => mode = s.first),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: switch (mode) {
            SplitMode.ranges => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: rangeCtrl,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 1-3, 5, 8-10',
                      prefixIcon: Icon(Icons.format_list_numbered_rounded),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 6),
                    child: Text(
                      'Enter page ranges separated by commas or dashes (e.g. 1-3, 5, 8-10).'
                      '${file != null ? ' Available: Pages 1–${file!.pages}.' : ''}',
                      style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
            SplitMode.everyPage => Text(
                file == null
                    ? 'Creates one separate PDF file for each page.'
                    : 'Creates ${file!.pages} separate PDF files (1 file per page).',
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            SplitMode.everyN => TextField(
                controller: nCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Pages per file (e.g. 2, 5, 10)',
                  prefixIcon: Icon(Icons.layers_rounded),
                ),
              ),
          },
        ),
        const SizedBox(height: 24),
        GradientButton(
          label: 'Split',
          icon: Icons.content_cut_rounded,
          accent: Brand.split,
          accentSoft: Brand.splitSoft,
          busy: busy,
          progress: progress,
          status: status,
          onCancel: _cancel,
          onPressed: file == null ? null : _run,
        ),
        if (results.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 26, bottom: 12, left: 4),
            child: Row(children: [
              Expanded(
                child: Text('${results.length} files ready',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              ),
              TextButton.icon(
                onPressed: () async {
                  try {
                    final ok = await PdfService.saveAllToFolder(results);
                    if (!context.mounted) return;
                    if (ok) showSuccess(context, 'Files saved successfully');
                  } catch (_) {
                    if (context.mounted) {
                      showError(context, 'Could not save to that folder. Try Share all instead.');
                    }
                  }
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Save all'),
              ),
              TextButton.icon(
                onPressed: () => Share.shareXFiles([
                  for (final f in results) XFile(f.path, mimeType: 'application/pdf')
                ]),
                icon: const Icon(Icons.ios_share_rounded, size: 18),
                label: const Text('Share all'),
              ),
            ]),
          ),
          for (final f in results)
            FileResultTile(
              name: f.uri.pathSegments.last,
              detail: formatBytes(f.lengthSync()),
              accent: Brand.split,
              path: f.path,
              onRemove: () => setState(() => results.remove(f)),
            ),
        ],
      ],
    );
  }
}
