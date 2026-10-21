import 'dart:io';
import 'package:flutter/material.dart';
import '../services/pdf_service.dart';
import '../theme.dart';
import '../widgets.dart';
import 'pick_pdf_screen.dart';

class UnlockScreen extends StatefulWidget {
  const UnlockScreen({super.key});
  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  PickedPdf? file;
  final pwdCtrl = TextEditingController();
  bool obscure = true;
  bool busy = false;
  File? result;

  @override
  void dispose() {
    pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final f = await PickPdfScreen.pick(
      context,
      title: 'Select PDF to Unlock',
      accent: Brand.unlock,
      accentSoft: Brand.unlockSoft,
    );
    if (f != null && mounted) {
      setState(() {
        file = f;
        result = null;
      });
    }
  }

  Future<void> _run() async {
    if (busy || file == null) return;
    final pwd = pwdCtrl.text.trim();
    if (pwd.isEmpty) {
      showError(context, 'Please enter the PDF password.');
      return;
    }
    setState(() {
      busy = true;
      result = null;
    });
    try {
      final out = await PdfService.unlock(file!, pwd);
      if (mounted) setState(() => result = out);
    } catch (_) {
      if (mounted) showError(context, 'Incorrect password or unsupported encryption.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = result;
    return ToolScaffold(
      title: 'Unlock PDF',
      subtitle: 'Remove password protection & restrictions.',
      accent: Brand.unlock,
      accentSoft: Brand.unlockSoft,
      icon: Icons.lock_open_rounded,
      children: [
        PickCard(
          file: file,
          accent: Brand.unlock,
          onPick: _pick,
          onClear: () => setState(() {
            file = null;
            result = null;
          }),
        ),
        const SectionTitle('Document password'),
        TextField(
          controller: pwdCtrl,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: 'Enter password to unlock…',
            prefixIcon: const Icon(Icons.key_rounded),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
              onPressed: () => setState(() => obscure = !obscure),
            ),
          ),
        ),
        const SizedBox(height: 24),
        GradientButton(
          label: 'Unlock Document',
          icon: Icons.lock_open_rounded,
          accent: Brand.unlock,
          accentSoft: Brand.unlockSoft,
          busy: busy,
          onPressed: file == null ? null : _run,
        ),
        if (r != null) ...[
          const SectionTitle('Result'),
          FileResultTile(
            name: r.uri.pathSegments.last,
            detail: 'Unprotected & free to share',
            accent: Brand.unlock,
            path: r.path,
            onRemove: () => setState(() => result = null),
          ),
        ],
      ],
    );
  }
}

