import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/painting.dart' show Offset;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as px;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

class PickedPdf {
  final String path;
  final String name;
  final int size;
  final int pages;
  const PickedPdf(this.path, this.name, this.size, this.pages);
}

enum CompressLevel {
  light('Light (Max Quality)', 'Sharp & crisp text. Best visual clarity (15–35% smaller).'),
  balanced('Balanced (Recommended)', 'Crystal clear readability, high savings (60–80% smaller).'),
  strong('Strong Compression', 'Clean readable text for email & messaging (75–85% smaller).'),
  extreme('Extreme Compression', 'Smallest file size with preserved text legibility (85–92% smaller).');

  final String title;
  final String hint;
  const CompressLevel(this.title, this.hint);
}

class CompressResult {
  final File file;
  final int before;
  final int after;
  const CompressResult(this.file, this.before, this.after);
  double get savedPercent => before == 0 ? 0 : (1 - after / before) * 100;
}

enum SplitMode { ranges, everyPage, everyN }

String formatBytes(int b) {
  if (b < 1024) return '$b B';
  if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
  return '${(b / 1024 / 1024).toStringAsFixed(2)} MB';
}

class PdfService {
  static Future<PickedPdf?> pick() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final path = res?.files.single.path;
    if (path == null) return null;
    final f = File(path);
    final doc = sf.PdfDocument(inputBytes: await f.readAsBytes());
    final pages = doc.pages.count;
    doc.dispose();
    return PickedPdf(path, p.basename(path), await f.length(), pages);
  }

  static Future<List<PickedPdf>> pickMultiple() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (res == null || res.files.isEmpty) return [];
    final list = <PickedPdf>[];
    for (final file in res.files) {
      if (file.path == null) continue;
      final f = File(file.path!);
      final bytes = await f.readAsBytes();
      final doc = sf.PdfDocument(inputBytes: bytes);
      final count = doc.pages.count;
      doc.dispose();
      list.add(PickedPdf(file.path!, file.name, bytes.length, count));
    }
    return list;
  }

  static Future<List<String>> pickImages() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (res == null) return [];
    return res.files.where((f) => f.path != null).map((f) => f.path!).toList();
  }

  static Future<Directory> _outDir() async {
    final base = await getApplicationDocumentsDirectory();
    final newDir = Directory(p.join(base.path, 'PDFix'));
    final oldDir = Directory(p.join(base.path, 'PDF Toolkit'));
    if (await oldDir.exists() && !await newDir.exists()) {
      try {
        await oldDir.rename(newDir.path);
      } catch (_) {}
    }
    if (!await newDir.exists()) await newDir.create(recursive: true);
    return newDir;
  }

  // ---------------------------------------------------------------- Compress
  static Future<CompressResult> compress(
    PickedPdf src,
    CompressLevel level,
    void Function(double) onProgress,
  ) async {
    final out = await _outDir();
    final base = p.basenameWithoutExtension(src.name);
    final target = File(p.join(out.path, '${base}_compressed.pdf'));

    // 1. Attempt lossless stream compression first
    final srcBytes = await File(src.path).readAsBytes();
    final doc = sf.PdfDocument(inputBytes: srcBytes);
    doc.fileStructure.incrementalUpdate = false;
    doc.compressionLevel = sf.PdfCompressionLevel.best;
    final losslessBytes = Uint8List.fromList(await doc.save());
    doc.dispose();

    // If lossless stream compression achieves target savings,
    // we preserve 100% original vector sharpness with zero rasterization
    final minLosslessRatio = switch (level) {
      CompressLevel.light => 0.10,
      CompressLevel.balanced => 0.30,
      CompressLevel.strong => 0.50,
      CompressLevel.extreme => 0.70,
    };
    if (losslessBytes.length <= srcBytes.length * (1.0 - minLosslessRatio)) {
      onProgress(1);
      await target.writeAsBytes(losslessBytes);
      return CompressResult(target, src.size, losslessBytes.length);
    }

    // 2. High-clarity raster resampling with crisp resolution & high JPEG quality
    // Light: 180 DPI @ 85% quality (ultra-sharp, print-ready clarity)
    // Balanced: 150 DPI @ 78% quality (crystal clear readability, ~70-80% savings)
    // Strong: 130 DPI @ 68% quality (clean readable text, ~80-85% savings)
    // Extreme: 110 DPI @ 58% quality (compact size, preserved legibility)
    final (dpi, quality) = switch (level) {
      CompressLevel.light => (180.0, 85),
      CompressLevel.balanced => (150.0, 78),
      CompressLevel.strong => (130.0, 68),
      CompressLevel.extreme => (110.0, 58),
    };
    final scale = dpi / 72.0;

    final input = await px.PdfDocument.openFile(src.path);
    final output = pw.Document(compress: true);
    for (var i = 1; i <= input.pagesCount; i++) {
      final page = await input.getPage(i);
      final img = await page.render(
        width: page.width * scale,
        height: page.height * scale,
        format: px.PdfPageImageFormat.jpeg,
        quality: quality,
        backgroundColor: '#FFFFFF',
      );
      final fmt = PdfPageFormat(page.width, page.height);
      await page.close();
      if (img != null) {
        output.addPage(pw.Page(
          pageFormat: fmt,
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Image(pw.MemoryImage(img.bytes), fit: pw.BoxFit.fill),
        ));
      }
      onProgress(i / input.pagesCount);
    }
    await input.close();
    final resBytes = await output.save();

    // If rasterization accidentally resulted in a larger file than lossless, use lossless
    if (resBytes.length >= srcBytes.length && losslessBytes.length < srcBytes.length) {
      await target.writeAsBytes(losslessBytes);
      return CompressResult(target, src.size, losslessBytes.length);
    }

    await target.writeAsBytes(resBytes);
    return CompressResult(target, src.size, resBytes.length);
  }

  // ------------------------------------------------------------------- Split
  static List<List<int>> parseRanges(String input, int total) {
    final groups = <List<int>>[];
    for (final part in input.split(',')) {
      final s = part.trim();
      if (s.isEmpty) continue;
      final m = RegExp(r'^(\d+)(?:\s*-\s*(\d+))?$').firstMatch(s);
      if (m == null) throw FormatException('"$s" is not a valid range.');
      final a = int.parse(m.group(1)!);
      final b = int.parse(m.group(2) ?? m.group(1)!);
      if (a < 1 || b > total || a > b) {
        throw FormatException('"$s" is outside 1–$total.');
      }
      groups.add([for (var i = a; i <= b; i++) i]);
    }
    if (groups.isEmpty) throw const FormatException('Enter at least one range.');
    return groups;
  }

  static List<List<int>> everyN(int n, int total) {
    final groups = <List<int>>[];
    for (var i = 1; i <= total; i += n) {
      groups.add([for (var j = i; j < i + n && j <= total; j++) j]);
    }
    return groups;
  }

  static Future<List<File>> split(
    PickedPdf src,
    List<List<int>> groups,
    void Function(double) onProgress,
  ) async {
    final out = await _outDir();
    final base = p.basenameWithoutExtension(src.name);
    final srcDoc = sf.PdfDocument(inputBytes: await File(src.path).readAsBytes());
    final files = <File>[];

    for (var g = 0; g < groups.length; g++) {
      final dst = sf.PdfDocument();
      dst.pageSettings.margins.all = 0;
      for (final n in groups[g]) {
        final sp = srcDoc.pages[n - 1];
        dst.pageSettings.size = sp.size;
        dst.pages.add().graphics.drawPdfTemplate(sp.createTemplate(), Offset.zero);
      }
      final range = groups[g].length == 1
          ? 'p${groups[g].first}'
          : 'p${groups[g].first}-${groups[g].last}';
      final f = File(p.join(out.path, '${base}_$range.pdf'));
      await f.writeAsBytes(await dst.save());
      dst.dispose();
      files.add(f);
      onProgress((g + 1) / groups.length);
    }
    srcDoc.dispose();
    return files;
  }

  // ------------------------------------------------------------------- Merge
  static Future<File> merge(
    List<PickedPdf> files,
    void Function(double) onProgress,
  ) async {
    final out = await _outDir();
    final dst = sf.PdfDocument();
    dst.pageSettings.margins.all = 0;

    for (var i = 0; i < files.length; i++) {
      final bytes = await File(files[i].path).readAsBytes();
      final srcDoc = sf.PdfDocument(inputBytes: bytes);
      for (var pIndex = 0; pIndex < srcDoc.pages.count; pIndex++) {
        final sp = srcDoc.pages[pIndex];
        dst.pageSettings.size = sp.size;
        dst.pages.add().graphics.drawPdfTemplate(sp.createTemplate(), Offset.zero);
      }
      srcDoc.dispose();
      onProgress((i + 1) / files.length);
    }
    final target = File(p.join(out.path, 'merged_${DateTime.now().millisecondsSinceEpoch}.pdf'));
    await target.writeAsBytes(await dst.save());
    dst.dispose();
    return target;
  }

  // ------------------------------------------------------------------ Rotate
  static Future<File> rotate(
    PickedPdf src,
    int degrees,
    void Function(double) onProgress,
  ) async {
    final out = await _outDir();
    final doc = sf.PdfDocument(inputBytes: await File(src.path).readAsBytes());
    final angle = switch (degrees) {
      90 => sf.PdfPageRotateAngle.rotateAngle90,
      180 => sf.PdfPageRotateAngle.rotateAngle180,
      270 => sf.PdfPageRotateAngle.rotateAngle270,
      _ => sf.PdfPageRotateAngle.rotateAngle0,
    };
    for (var i = 0; i < doc.pages.count; i++) {
      doc.pages[i].rotation = angle;
      onProgress((i + 1) / doc.pages.count);
    }
    final base = p.basenameWithoutExtension(src.name);
    final target = File(p.join(out.path, '${base}_rot$degrees.pdf'));
    await target.writeAsBytes(await doc.save());
    doc.dispose();
    return target;
  }

  // ------------------------------------------------------------ Images to PDF
  static Future<File> imagesToPdf(
    List<String> imagePaths,
    void Function(double) onProgress,
  ) async {
    final out = await _outDir();
    final doc = sf.PdfDocument();
    doc.pageSettings.margins.all = 0;
    doc.pageSettings.size = sf.PdfPageSize.a4;

    for (var i = 0; i < imagePaths.length; i++) {
      final bytes = await File(imagePaths[i]).readAsBytes();
      final bitmap = sf.PdfBitmap(bytes);
      final page = doc.pages.add();
      final size = page.getClientSize();
      page.graphics.drawImage(
        bitmap,
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
      onProgress((i + 1) / imagePaths.length);
    }
    final target = File(p.join(out.path, 'images_${DateTime.now().millisecondsSinceEpoch}.pdf'));
    await target.writeAsBytes(await doc.save());
    doc.dispose();
    return target;
  }

  // ---------------------------------------------------------- Protect with Password
  static Future<File> protect(
    PickedPdf src,
    String password,
  ) async {
    final out = await _outDir();
    final doc = sf.PdfDocument(inputBytes: await File(src.path).readAsBytes());
    doc.security.userPassword = password;
    doc.security.ownerPassword = password;
    doc.security.algorithm = sf.PdfEncryptionAlgorithm.aesx256Bit;
    final base = p.basenameWithoutExtension(src.name);
    final target = File(p.join(out.path, '${base}_protected.pdf'));
    await target.writeAsBytes(await doc.save());
    doc.dispose();
    return target;
  }

  // --------------------------------------------------------------- Watermark
  static Future<File> watermark(
    PickedPdf src,
    String text,
  ) async {
    final out = await _outDir();
    final doc = sf.PdfDocument(inputBytes: await File(src.path).readAsBytes());
    final font = sf.PdfStandardFont(sf.PdfFontFamily.helvetica, 44, style: sf.PdfFontStyle.bold);
    final brush = sf.PdfSolidBrush(sf.PdfColor(170, 170, 170, 80));

    for (var i = 0; i < doc.pages.count; i++) {
      final page = doc.pages[i];
      final size = page.getClientSize();
      final g = page.graphics;
      final state = g.save();
      g.translateTransform(size.width / 2, size.height / 2);
      g.rotateTransform(-45);
      final textSize = font.measureString(text);
      g.drawString(
        text,
        font,
        brush: brush,
        bounds: Rect.fromLTWH(-textSize.width / 2, -textSize.height / 2, textSize.width, textSize.height),
      );
      g.restore(state);
    }
    final base = p.basenameWithoutExtension(src.name);
    final target = File(p.join(out.path, '${base}_watermarked.pdf'));
    await target.writeAsBytes(await doc.save());
    doc.dispose();
    return target;
  }

  // -------------------------------------------------------------------- Sign
  static Future<File> signPdf(
    PickedPdf src,
    Uint8List signaturePngBytes,
    int pageNumber,
  ) async {
    final out = await _outDir();
    final doc = sf.PdfDocument(inputBytes: await File(src.path).readAsBytes());
    final pageIndex = (pageNumber - 1).clamp(0, doc.pages.count - 1);
    final page = doc.pages[pageIndex];
    final size = page.getClientSize();
    final bitmap = sf.PdfBitmap(signaturePngBytes);
    const sigW = 160.0;
    const sigH = 80.0;
    final x = (size.width - sigW - 30).clamp(0.0, size.width);
    final y = (size.height - sigH - 40).clamp(0.0, size.height);
    page.graphics.drawImage(bitmap, Rect.fromLTWH(x, y, sigW, sigH));
    final base = p.basenameWithoutExtension(src.name);
    final target = File(p.join(out.path, '${base}_signed.pdf'));
    await target.writeAsBytes(await doc.save());
    doc.dispose();
    return target;
  }

  // ------------------------------------------------------------------ Unlock
  static Future<File> unlock(
    PickedPdf src,
    String password,
  ) async {
    final out = await _outDir();
    final base = p.basenameWithoutExtension(src.name);
    final srcBytes = await File(src.path).readAsBytes();
    final doc = sf.PdfDocument(inputBytes: srcBytes, password: password);
    doc.security.userPassword = '';
    doc.security.ownerPassword = '';
    doc.security.permissions.clear();
    final outBytes = await doc.save();
    doc.dispose();
    final target = File(p.join(out.path, '${base}_unlocked.pdf'));
    await target.writeAsBytes(outBytes);
    return target;
  }

  // ----------------------------------------------------------- PDF to Images
  static Future<List<File>> pdfToImages(
    PickedPdf src,
    void Function(double) onProgress,
  ) async {
    final out = await _outDir();
    final base = p.basenameWithoutExtension(src.name);
    final doc = await px.PdfDocument.openFile(src.path);
    final files = <File>[];

    for (var i = 1; i <= doc.pagesCount; i++) {
      final page = await doc.getPage(i);
      final img = await page.render(
        width: page.width * 2.0,
        height: page.height * 2.0,
        format: px.PdfPageImageFormat.jpeg,
        backgroundColor: '#FFFFFF',
        quality: 90,
      );
      await page.close();
      if (img != null) {
        final f = File(p.join(out.path, '${base}_page_$i.jpg'));
        await f.writeAsBytes(img.bytes);
        files.add(f);
      }
      onProgress(i / doc.pagesCount);
    }
    await doc.close();
    return files;
  }

  // ------------------------------------------------------------ Recent Files
  static Future<List<File>> getRecentFiles() async {
    try {
      final dir = await _outDir();
      if (!await dir.exists()) return [];
      final entities = dir.listSync();
      final files = entities.whereType<File>().toList()
        ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      return files.take(8).toList();
    } catch (_) {
      return [];
    }
  }

  // -------------------------------------------------------------- Save / share
  static Future<bool> saveToDevice(File f) async {
    final bytes = await f.readAsBytes();
    final res = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF',
      fileName: p.basename(f.path),
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      bytes: bytes,
    );
    return res != null;
  }

  static Future<bool> saveAllToFolder(List<File> files) async {
    final dir = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Choose a folder');
    if (dir == null) return false;
    for (final f in files) {
      await f.copy(p.join(dir, p.basename(f.path)));
    }
    return true;
  }
}
