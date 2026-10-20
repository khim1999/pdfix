import 'dart:io';
import 'package:flutter/material.dart';
import '../services/pdf_service.dart';
import '../theme.dart';
import '../widgets.dart';
import 'pick_pdf_screen.dart';

class WatermarkScreen extends StatefulWidget {
  const WatermarkScreen({super.key});
  @override
  State<WatermarkScreen> createState() => _WatermarkScreenState();
}

class _WatermarkScreenState extends State<WatermarkScreen> {
  PickedPdf? file;
  final textCtrl = TextEditingController(text: 'CONFIDENTIAL');
  bool busy = false;
  File? result;

  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final f = await PickPdfScreen.pick(
      context,
      title: 'Select PDF to Watermark',
      accent: Brand.watermark,
      accentSoft: Brand.watermarkSoft,
    );
    if (f != null && mounted) {
      setState(() {
        file = f;
        result = null;
      });
    }
  }

  Future<void> _run() async {
    final text = textCtrl.text.trim();
    if (text.isEmpty) {
      showError(context, 'Please enter watermark text.');
      return;
    }
    setState(() {
      busy = true;
      result = null;
    });
    try {
      final out = await PdfService.watermark(file!, text);
      if (mounted) setState(() => result = out);
    } catch (_) {
      if (mounted) showError(context, 'Could not apply watermark.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = result;
    return ToolScaffold(
      title: 'Watermark PDF',
      subtitle: 'Stamp customized text across all pages.',
      accent: Brand.watermark,
      accentSoft: Brand.watermarkSoft,
      icon: Icons.branding_watermark_rounded,
      children: [
        PickCard(
          file: file,
          accent: Brand.watermark,
          onPick: _pick,
          onClear: () => setState(() {
            file = null;
            result = null;
          }),
        ),
        const SectionTitle('Watermark Text'),
        TextField(
          controller: textCtrl,
          decoration: const InputDecoration(
            hintText: 'e.g. CONFIDENTIAL, DRAFT, APPROVED',
            prefixIcon: Icon(Icons.text_fields_rounded),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: ['CONFIDENTIAL', 'DRAFT', 'DO NOT COPY', 'SAMPLE', 'APPROVED'].map((preset) {
            return ActionChip(
              label: Text(preset),
              onPressed: () => setState(() => textCtrl.text = preset),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        GradientButton(
          label: 'Apply Watermark',
          icon: Icons.done_all_rounded,
          accent: Brand.watermark,
          accentSoft: Brand.watermarkSoft,
          busy: busy,
          onPressed: file == null ? null : _run,
        ),
        if (r != null) ...[
          const SectionTitle('Result'),
          FileResultTile(
            name: r.uri.pathSegments.last,
            detail: 'Watermark stamped',
            accent: Brand.watermark,
            path: r.path,
            onRemove: () => setState(() => result = null),
          ),
        ],
      ],
    );
  }
}

