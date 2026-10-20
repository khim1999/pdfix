import 'package:flutter/material.dart';

class Brand {
  static const ink = Color(0xFF14213D);
  static const compress = Color(0xFF2F5BFF);
  static const compressSoft = Color(0xFF7C9BFF);
  static const split = Color(0xFFFF7A2F);
  static const splitSoft = Color(0xFFFFB067);
  static const merge = Color(0xFFE63946);
  static const mergeSoft = Color(0xFFFF758F);
  static const rotate = Color(0xFF7209B7);
  static const rotateSoft = Color(0xFFB5179E);
  static const image = Color(0xFF0077B6);
  static const imageSoft = Color(0xFF00B4D8);
  static const protect = Color(0xFF3A0CA3);
  static const protectSoft = Color(0xFF4361EE);
  static const watermark = Color(0xFF2A9D8F);
  static const watermarkSoft = Color(0xFF52B788);
  static const sign = Color(0xFFD90429);
  static const signSoft = Color(0xFFEF233C);
  static const unlock = Color(0xFF059669);
  static const unlockSoft = Color(0xFF34D399);
  static const pdfToImg = Color(0xFFEA580C);
  static const pdfToImgSoft = Color(0xFFFB923C);
  static const success = Color(0xFF12B76A);
}

ThemeData buildTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: Brand.compress,
    brightness: b,
    surface: dark ? const Color(0xFF0E1526) : const Color(0xFFF3F5FA),
  );
  final base = ThemeData(brightness: b, colorScheme: scheme, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF18223A) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
  );
}

Color cardColor(BuildContext c) =>
    Theme.of(c).brightness == Brightness.dark ? const Color(0xFF18223A) : Colors.white;
