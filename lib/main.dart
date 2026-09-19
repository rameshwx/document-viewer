// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pdfrx/pdfrx.dart';

import 'package:aeroslate/presentation/providers/locale_provider.dart';
import 'package:aeroslate/presentation/providers/theme_provider.dart';
import 'package:aeroslate/core/constants/app_themes.dart';
import 'package:aeroslate/data/models/drawing_model.dart';
import 'package:aeroslate/presentation/screens/main_screen.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrapCompleter = Completer<void>();

  runApp(
    ProviderScope(
      child: AeroSlateApp(bootstrapFuture: bootstrapCompleter.future),
    ),
  );

  // Defer heavyweight bootstrap so the first frame (splash/loading) can paint immediately.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await _bootstrapApp();
      bootstrapCompleter.complete();
    } catch (e, st) {
      bootstrapCompleter.completeError(e, st);
    }
  });
}

Future<void> _bootstrapApp() async {
  // Use locally-hosted WASM modules under /pdfrx to avoid cross-origin/MIME issues.
  Pdfrx.pdfiumWasmModulesUrl = '/pdfrx/';
  pdfrxFlutterInitialize();

  await Hive.initFlutter();
  Hive.registerAdapter(DrawingModelAdapter());
  Hive.registerAdapter(DrawingShapeAdapter());
}

class AeroSlateApp extends ConsumerWidget {
  const AeroSlateApp({super.key, required this.bootstrapFuture});

  final Future<void> bootstrapFuture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return FutureBuilder<void>(
      future: bootstrapFuture,
      builder: (context, snapshot) {
        final ready = snapshot.connectionState == ConnectionState.done &&
            snapshot.hasError == false;

        return MaterialApp(
          title: 'AeroSlate',
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalizations.delegate,
          ],
          theme: AeroSlateThemes.light,
          darkTheme: AeroSlateThemes.dark,
          themeMode: themeMode,
          home: ready ? const MainScreen() : const _BootstrapLoadingScreen(),
        );
      },
    );
  }
}

class _BootstrapLoadingScreen extends StatelessWidget {
  const _BootstrapLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
