import 'dart:io';
import 'package:flutter/material.dart';
import '../services/pdf_service.dart';
import '../theme.dart';
import '../widgets.dart';
import 'pick_pdf_screen.dart';

class ProtectScreen extends StatefulWidget {
  const ProtectScreen({super.key});
  @override
  State<ProtectScreen> createState() => _ProtectScreenState();
}

class _ProtectScreenState extends State<ProtectScreen> {
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
      title: 'Select PDF to Protect',
      accent: Brand.protect,
      accentSoft: Brand.protectSoft,
    );
    if (f != null && mounted) {
      setState(() {
        file = f;
        result = null;
      });
    }
  }

  Future<void> _run() async {
    final pwd = pwdCtrl.text.trim();
    if (pwd.isEmpty) {
      showError(context, 'Please enter a password.');
      return;
    }
    setState(() {
      busy = true;
      result = null;
    });
    try {
      final out = await PdfService.protect(file!, pwd);
      if (mounted) setState(() => result = out);
    } catch (_) {
      if (mounted) showError(context, 'Could not encrypt this document.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = result;
    return ToolScaffold(
      title: 'Protect PDF',
      subtitle: 'Lock your document with a secure password.',
      accent: Brand.protect,
      accentSoft: Brand.protectSoft,
      icon: Icons.lock_rounded,
      children: [
        PickCard(
          file: file,
          accent: Brand.protect,
          onPick: _pick,
          onClear: () => setState(() {
            file = null;
            result = null;
          }),
        ),
        const SectionTitle('Set Password'),
        TextField(
          controller: pwdCtrl,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: 'Enter password to unlock',
            prefixIcon: const Icon(Icons.key_rounded),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
              onPressed: () => setState(() => obscure = !obscure),
            ),
          ),
        ),
        const SizedBox(height: 24),
        GradientButton(
          label: 'Lock Document',
          icon: Icons.lock_rounded,
          accent: Brand.protect,
          accentSoft: Brand.protectSoft,
          busy: busy,
          onPressed: file == null ? null : _run,
        ),
        if (r != null) ...[
          const SectionTitle('Result'),
          FileResultTile(
            name: r.uri.pathSegments.last,
            detail: 'Protected with 256-bit AES',
            accent: Brand.protect,
            path: r.path,
            onRemove: () => setState(() => result = null),
          ),
        ],
      ],
    );
  }
}

