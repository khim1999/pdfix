import 'dart:io';
import 'package:flutter/material.dart';
import '../services/pdf_service.dart';
import '../theme.dart';
import '../widgets.dart';
import 'pick_pdf_screen.dart';

class RotateScreen extends StatefulWidget {
  const RotateScreen({super.key});
  @override
  State<RotateScreen> createState() => _RotateScreenState();
}

class _RotateScreenState extends State<RotateScreen> {
  PickedPdf? file;
  int degrees = 90;
  bool busy = false;
  double progress = 0;
  String status = '';
  File? result;

  Future<void> _pick() async {
    final f = await PickPdfScreen.pick(
      context,
      title: 'Select PDF to Rotate',
      accent: Brand.rotate,
      accentSoft: Brand.rotateSoft,
    );
    if (f != null && mounted) {
      setState(() {
        file = f;
        result = null;
        status = '';
      });
    }
  }

  Future<void> _run() async {
    if (busy || file == null) return;
    setState(() {
      busy = true;
      progress = 0;
      status = 'Preparing rotation…';
      result = null;
    });
    try {
      final out = await PdfService.rotate(file!, degrees, (v, [s]) {
        if (mounted) {
          setState(() {
            progress = v;
            if (s != null) status = s;
          });
        }
      });
      if (mounted) setState(() => result = out);
    } catch (_) {
      if (mounted) showError(context, 'Could not rotate this file.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = result;
    return ToolScaffold(
      title: 'Rotate PDF',
      subtitle: 'Turn sideways or upside-down pages.',
      accent: Brand.rotate,
      accentSoft: Brand.rotateSoft,
      icon: Icons.rotate_right_rounded,
      children: [
        PickCard(
          file: file,
          accent: Brand.rotate,
          onPick: _pick,
          onClear: () => setState(() {
            file = null;
            result = null;
          }),
        ),
        const SectionTitle('Choose direction'),
        Row(children: [
          for (final angle in [90, 180, 270])
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => degrees = angle),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: cardColor(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: degrees == angle ? Brand.rotate : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(children: [
                    Icon(
                      switch (angle) {
                        90 => Icons.rotate_90_degrees_cw_rounded,
                        180 => Icons.screen_rotation_rounded,
                        _ => Icons.rotate_90_degrees_ccw_rounded,
                      },
                      color: degrees == angle ? Brand.rotate : Colors.grey,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      switch (angle) {
                        90 => '90° Right',
                        180 => '180° Flip',
                        _ => '90° Left',
                      },
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: degrees == angle ? Brand.rotate : null,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 24),
        GradientButton(
          label: 'Rotate Pages',
          icon: Icons.refresh_rounded,
          accent: Brand.rotate,
          accentSoft: Brand.rotateSoft,
          busy: busy,
          progress: progress,
          status: status,
          onPressed: file == null ? null : _run,
        ),
        if (r != null) ...[
          const SectionTitle('Result'),
          FileResultTile(
            name: r.uri.pathSegments.last,
            detail: formatBytes(r.lengthSync()),
            accent: Brand.rotate,
            path: r.path,
            onRemove: () => setState(() => result = null),
          ),
        ],
      ],
    );
  }
}

