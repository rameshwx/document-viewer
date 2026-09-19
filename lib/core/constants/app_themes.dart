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
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      tooltipTheme:
          const TooltipThemeData(waitDuration: Duration(milliseconds: 500)),
      dividerColor: scheme.outlineVariant,
      iconTheme: IconThemeData(size: 20, color: scheme.onSurface),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainer,
        textStyle: TextStyle(color: scheme.onSurface),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
      ),
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
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      tooltipTheme:
          const TooltipThemeData(waitDuration: Duration(milliseconds: 500)),
      dividerColor: scheme.outlineVariant,
      iconTheme: IconThemeData(size: 20, color: scheme.onSurface),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainer,
        textStyle: TextStyle(color: scheme.onSurface),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
