import 'dart:io';
import 'package:flutter/material.dart';
import '../services/pdf_service.dart';
import '../theme.dart';
import '../widgets.dart';

class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});
  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  List<String> images = [];
  bool busy = false;
  double progress = 0;
  File? result;

  Future<void> _pick() async {
    final list = await PdfService.pickImages();
    if (list.isNotEmpty) {
      setState(() {
        images.addAll(list);
        result = null;
      });
    }
  }

  Future<void> _run() async {
    if (busy || images.isEmpty) return;
    setState(() {
      busy = true;
      progress = 0;
      result = null;
    });
    try {
      final out = await PdfService.imagesToPdf(images, (v) {
        if (mounted) setState(() => progress = v);
      });
      if (mounted) setState(() => result = out);
    } catch (_) {
      if (mounted) showError(context, 'Could not convert images to PDF.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = result;
    return ToolScaffold(
      title: 'Images to PDF',
      subtitle: 'Convert JPG and PNG photos into a single PDF.',
      accent: Brand.image,
      accentSoft: Brand.imageSoft,
      icon: Icons.image_rounded,
      children: [
        if (images.isEmpty)
          InkWell(
            onTap: _pick,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              decoration: BoxDecoration(
                color: Brand.image.withOpacity(.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Brand.image.withOpacity(.45), width: 1.5),
              ),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: Brand.image, shape: BoxShape.circle),
                  child: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 14),
                const Text('Choose Images',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Select photos from your gallery',
                    style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14)),
              ]),
            ),
          )
        else ...[
          Row(children: [
            Text('${images.length} images selected',
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
            itemCount: images.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = images.removeAt(oldIndex);
                images.insert(newIndex, item);
                result = null;
              });
            },
            itemBuilder: (context, i) {
              final path = images[i];
              return Container(
                key: ValueKey(path),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cardColor(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(File(path), width: 44, height: 44, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      path.split(Platform.pathSeparator).last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => setState(() {
                      images.removeAt(i);
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
          label: 'Create PDF',
          icon: Icons.picture_as_pdf_rounded,
          accent: Brand.image,
          accentSoft: Brand.imageSoft,
          busy: busy,
          progress: progress,
          onPressed: images.isEmpty ? null : _run,
        ),
        if (r != null) ...[
          const SectionTitle('Result'),
          FileResultTile(
            name: r.uri.pathSegments.last,
            detail: formatBytes(r.lengthSync()),
            accent: Brand.image,
            path: r.path,
            onRemove: () => setState(() => result = null),
          ),
        ],
      ],
    );
  }
}

