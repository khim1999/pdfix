import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_toolkit/main.dart';

void main() {
  testWidgets('PdfToolkitApp smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PdfToolkitApp());
    expect(find.text('PDFix'), findsWidgets);
    expect(find.text('Compress PDF'), findsOneWidget);
    expect(find.text('Split PDF'), findsOneWidget);
    expect(find.text('Merge PDF'), findsOneWidget);
    expect(find.text('Images to PDF'), findsOneWidget);
    expect(find.text('PDF to Images'), findsOneWidget);
    expect(find.text('Protect PDF'), findsOneWidget);
    expect(find.text('Unlock PDF'), findsOneWidget);
    expect(find.text('Sign Document'), findsOneWidget);
  });
}
