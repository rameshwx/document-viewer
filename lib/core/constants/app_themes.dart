// lib/core/constants/app_themes.dart
import 'package:flutter/material.dart';

class AeroSlateThemes {
  static ThemeData get light {
    const color = Colors.blue;
    final scheme =
        ColorScheme.fromSeed(seedColor: color, brightness: Brightness.light);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      tooltipTheme:
          const TooltipThemeData(waitDuration: Duration(milliseconds: 500)),
      dividerColor: Colors.grey.shade300,
      iconTheme: const IconThemeData(size: 20),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData get dark {
    const color = Colors.blue;
    final scheme =
        ColorScheme.fromSeed(seedColor: color, brightness: Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF111315),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF111315),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      tooltipTheme:
          const TooltipThemeData(waitDuration: Duration(milliseconds: 500)),
      dividerColor: const Color(0xFF212427),
      iconTheme: const IconThemeData(size: 20),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
