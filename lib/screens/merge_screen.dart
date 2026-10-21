import 'dart:io';
import 'package:flutter/material.dart';
import '../services/pdf_service.dart';
import '../theme.dart';
import '../widgets.dart';
import 'pick_pdf_screen.dart';

class MergeScreen extends StatefulWidget {
  const MergeScreen({super.key});
  @override
  State<MergeScreen> createState() => _MergeScreenState();
}

class _MergeScreenState extends State<MergeScreen> {
  List<PickedPdf> files = [];
  bool busy = false;
  double progress = 0;
  String status = '';
  bool _cancelled = false;
  File? result;

  Future<void> _pick() async {
    final f = await PickPdfScreen.pick(
      context,
      title: 'Select PDF to Add',
      accent: Brand.merge,
      accentSoft: Brand.mergeSoft,
    );
    if (f != null && mounted) {
      setState(() {
        files.add(f);
        result = null;
        status = '';
      });
    }
  }

  Future<void> _run() async {
    if (busy) return;
    if (files.length < 2) {
      showError(context, 'Please choose at least 2 PDF files to merge.');
      return;
    }
    setState(() {
      busy = true;
      progress = 0;
      status = 'Preparing merge…';
      _cancelled = false;
      result = null;
    });
    try {
      final out = await PdfService.merge(
        files,
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
            const SnackBar(content: Text('Merge operation cancelled.')),
          );
        }
        return;
      }
      if (mounted) setState(() => result = out);
    } catch (_) {
      if (mounted && !_cancelled) showError(context, 'Could not merge these files.');
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
    final r = result;
    return ToolScaffold(
      title: 'Merge PDF',
      subtitle: 'Combine multiple PDFs in your desired order.',
      accent: Brand.merge,
      accentSoft: Brand.mergeSoft,
      icon: Icons.layers_rounded,
      children: [
        if (files.isEmpty)
          InkWell(
            onTap: _pick,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              decoration: BoxDecoration(
                color: Brand.merge.withOpacity(.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Brand.merge.withOpacity(.45), width: 1.5),
              ),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: Brand.merge, shape: BoxShape.circle),
                  child: const Icon(Icons.note_add_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 14),
                const Text('Choose PDFs to Merge',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Select 2 or more files',
                    style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14)),
              ]),
            ),
          )
        else ...[
          Row(children: [
            Text('${files.length} documents selected',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton.icon(
              onPressed: _pick,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add more'),
            ),
          ]),
          const SizedBox(height: 8),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: files.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = files.removeAt(oldIndex);
                files.insert(newIndex, item);
                result = null;
              });
            },
            itemBuilder: (context, i) {
              final f = files[i];
              return Container(
                key: ValueKey(f.path),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: cardColor(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  const Icon(Icons.drag_indicator_rounded, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(f.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${formatBytes(f.size)} • ${f.pages} pages',
                          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                    ]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => setState(() {
                      files.removeAt(i);
                      result = null;
                    }),
                  ),
                ]),
              );
            },
          ),
        ],
        const SizedBox(height: 24),
        GradientButton(
          label: 'Merge Files',
          icon: Icons.merge_type_rounded,
          accent: Brand.merge,
          accentSoft: Brand.mergeSoft,
          busy: busy,
          progress: progress,
          status: status,
          onCancel: _cancel,
          onPressed: files.length < 2 ? null : _run,
        ),
        if (r != null) ...[
          const SectionTitle('Result'),
          FileResultTile(
            name: r.uri.pathSegments.last,
            detail: formatBytes(r.lengthSync()),
            accent: Brand.merge,
            path: r.path,
            onRemove: () => setState(() => result = null),
          ),
        ],
      ],
    );
  }
}

