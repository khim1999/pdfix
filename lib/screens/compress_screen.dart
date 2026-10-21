import 'package:flutter/material.dart';
import '../services/pdf_service.dart';
import '../theme.dart';
import '../widgets.dart';
import 'pick_pdf_screen.dart';

class CompressScreen extends StatefulWidget {
  const CompressScreen({super.key});
  @override
  State<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen> {
  PickedPdf? file;
  CompressLevel level = CompressLevel.recommended;
  bool busy = false;
  double progress = 0;
  String status = '';
  bool _cancelled = false;
  CompressResult? result;

  Future<void> _pick() async {
    final f = await PickPdfScreen.pick(
      context,
      title: 'Select PDF to Compress',
      accent: Brand.compress,
      accentSoft: Brand.compressSoft,
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
      status = 'Preparing document…';
      _cancelled = false;
      result = null;
    });
    try {
      final r = await PdfService.compress(
        file!,
        level,
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
            const SnackBar(content: Text('Compression cancelled.')),
          );
        }
        return;
      }

      if (mounted) {
        setState(() => result = r);
      }
    } catch (e) {
      if (mounted && !_cancelled) {
        showError(context, 'Could not compress this file. It may be protected or damaged.');
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
    final r = result;
    return ToolScaffold(
      title: 'Compress PDF files',
      subtitle: 'Reduce file size while optimizing for maximal PDF quality.',
      accent: Brand.compress,
      accentSoft: Brand.compressSoft,
      icon: Icons.compress_rounded,
      children: [
        PickCard(
          file: file,
          accent: Brand.compress,
          onPick: _pick,
          onClear: () => setState(() {
            file = null;
            result = null;
          }),
        ),
        const SectionTitle('Compression level'),
        for (final l in CompressLevel.values)
          _LevelTile(
            level: l,
            selected: l == level,
            onTap: () => setState(() => level = l),
          ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Brand.success.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Brand.success.withOpacity(0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_rounded, size: 18, color: Brand.success),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Guaranteed Reduction: File sizes never increase. Text and pages remain sharp and easy to read.',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Brand.success),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GradientButton(
          label: 'Compress PDF',
          icon: Icons.bolt_rounded,
          accent: Brand.compress,
          accentSoft: Brand.compressSoft,
          busy: busy,
          progress: progress,
          status: status,
          onCancel: _cancel,
          onPressed: file == null ? null : _run,
        ),
        if (r != null) ...[
          const SectionTitle('Result'),
          _SavingsBanner(r),
          const SizedBox(height: 12),
          FileResultTile(
            name: r.file.uri.pathSegments.last,
            detail: r.after < r.before
                ? '${formatBytes(r.after)}  •  −${r.savedPercent.toStringAsFixed(1)}%'
                : '${formatBytes(r.after)}  •  Maximally Compressed',
            accent: Brand.compress,
            path: r.file.path,
            onRemove: () => setState(() => result = null),
          ),
        ],
      ],
    );
  }
}

class _LevelTile extends StatelessWidget {
  final CompressLevel level;
  final bool selected;
  final VoidCallback onTap;
  const _LevelTile({required this.level, required this.selected, required this.onTap});

  String get _tag => switch (level) {
    CompressLevel.extreme => '−85%',
    CompressLevel.recommended => '−75%',
    CompressLevel.less => '−50%',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? (isDark
                  ? Brand.compress.withOpacity(0.12)
                  : Brand.compress.withOpacity(0.06))
              : cardColor(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? Brand.compress : theme.dividerColor.withOpacity(0.12),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? Brand.compress : theme.hintColor.withOpacity(0.5),
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                      color: selected
                          ? (isDark ? Colors.white : Brand.ink)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    level.hint,
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: 13,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (selected ? Brand.compress : Colors.grey).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _tag,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                  color: selected ? Brand.compress : theme.hintColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingsBanner extends StatelessWidget {
  final CompressResult r;
  const _SavingsBanner(this.r);

  @override
  Widget build(BuildContext context) {
    final smaller = r.after < r.before;
    final color = smaller ? Brand.success : Brand.compress;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(children: [
        Text(
          smaller ? '−${r.savedPercent.toStringAsFixed(0)}%' : 'Optimal',
          style: TextStyle(
            fontSize: smaller ? 36 : 28,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            smaller
                ? '${formatBytes(r.before)} → ${formatBytes(r.after)}'
                : 'This file is already maximally compressed and cannot be reduced further without loss.',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }
}
