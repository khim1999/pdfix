import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../services/pdf_service.dart';
import '../theme.dart';
import '../widgets.dart';
import 'pick_pdf_screen.dart';

class SignScreen extends StatefulWidget {
  const SignScreen({super.key});
  @override
  State<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> {
  PickedPdf? file;
  final List<List<Offset>> strokes = [];
  List<Offset> currentStroke = [];
  int targetPage = 1;
  bool busy = false;
  File? result;

  Future<void> _pick() async {
    final f = await PickPdfScreen.pick(
      context,
      title: 'Select PDF to Sign',
      accent: Brand.sign,
      accentSoft: Brand.signSoft,
    );
    if (f != null && mounted) {
      setState(() {
        file = f;
        targetPage = f.pages;
        result = null;
      });
    }
  }

  Future<ui.Image> _renderSignatureImage(double width, double height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    for (final stroke in strokes) {
      for (var i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
    final picture = recorder.endRecording();
    return picture.toImage(width.toInt(), height.toInt());
  }

  Future<void> _run() async {
    if (strokes.isEmpty) {
      showError(context, 'Please draw your signature first.');
      return;
    }
    setState(() {
      busy = true;
      result = null;
    });
    try {
      final img = await _renderSignatureImage(320, 160);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception();
      final pngBytes = byteData.buffer.asUint8List();

      final out = await PdfService.signPdf(file!, pngBytes, targetPage);
      if (mounted) setState(() => result = out);
    } catch (_) {
      if (mounted) showError(context, 'Could not sign this document.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = result;
    return ToolScaffold(
      title: 'Sign PDF',
      subtitle: 'Draw signature and stamp onto your document.',
      accent: Brand.sign,
      accentSoft: Brand.signSoft,
      icon: Icons.draw_rounded,
      children: [
        PickCard(
          file: file,
          accent: Brand.sign,
          onPick: _pick,
          onClear: () => setState(() {
            file = null;
            result = null;
          }),
        ),
        if (file != null) ...[
          const SectionTitle('Target Page'),
          Row(children: [
            const Text('Place signature on page: ', style: TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            DropdownButton<int>(
              value: targetPage,
              items: [
                for (var i = 1; i <= file!.pages; i++)
                  DropdownMenuItem(value: i, child: Text('Page $i of ${file!.pages}')),
              ],
              onChanged: (v) => setState(() => targetPage = v ?? 1),
            ),
          ]),
        ],
        const SectionTitle('Draw Your Signature'),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(.3), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      currentStroke = [details.localPosition];
                      strokes.add(currentStroke);
                      result = null;
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      currentStroke.add(details.localPosition);
                    });
                  },
                  child: CustomPaint(
                    painter: _SignaturePainter(strokes),
                    size: Size.infinite,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    strokes.clear();
                    result = null;
                  }),
                  icon: const Icon(Icons.clear_all_rounded, size: 18, color: Colors.grey),
                  label: const Text('Clear', style: TextStyle(color: Colors.grey)),
                ),
              ),
              if (strokes.isEmpty)
                const Center(
                  child: Text(
                    '✍️ Sign with your finger here',
                    style: TextStyle(color: Colors.black38, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GradientButton(
          label: 'Stamp & Save PDF',
          icon: Icons.check_circle_outline_rounded,
          accent: Brand.sign,
          accentSoft: Brand.signSoft,
          busy: busy,
          onPressed: file == null || strokes.isEmpty ? null : _run,
        ),
        if (r != null) ...[
          const SectionTitle('Result'),
          FileResultTile(
            name: r.uri.pathSegments.last,
            detail: 'Signed on page $targetPage',
            accent: Brand.sign,
            path: r.path,
            onRemove: () => setState(() => result = null),
          ),
        ],
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  _SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF14213D)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.2;

    for (final stroke in strokes) {
      for (var i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}

