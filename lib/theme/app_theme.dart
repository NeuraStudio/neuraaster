import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF000000);
  static const surface = Color(0xFF17191F);
  static const surface2 = Color(0xFF202126);
  static const text = Color(0xFFF3F3F3);
  static const muted = Color(0xFFA7A9B1);
  static const blue = Color(0xFF4B7BFF);

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: blue,
        onPrimary: Colors.white,
        onSurface: text,
      ),
      splashFactory: InkSparkle.splashFactory,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: text,
        displayColor: text,
      ),
    );
  }
}
