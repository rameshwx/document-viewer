import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aeroslate/core/constants/app_themes.dart';
import 'package:aeroslate/l10n/app_localizations.dart';
import 'package:aeroslate/presentation/providers/drawing_provider.dart';
import 'package:aeroslate/presentation/widgets/drawing_overlay.dart';
import 'package:aeroslate/presentation/widgets/svg_drawing_toolbar.dart';

Widget _localizedApp({required Widget child, ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? AeroSlateThemes.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  test('DrawingNotifier supports the four drawing colors', () {
    final notifier = DrawingNotifier();

    for (final color in ['black', 'red', 'green', 'yellow']) {
      notifier.setColor(color);
      expect(notifier.state.selectedColor, color);
    }

    notifier.dispose();
  });

  testWidgets('color picker exposes four colors and updates the notifier',
      (tester) async {
    final notifier = DrawingNotifier();
    final state = DrawingState(isEnabled: true);

    await tester.pumpWidget(
      _localizedApp(
        child: SvgDrawingToolbar(
          drawingState: state,
          drawingNotifier: notifier,
          onSave: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.palette_outlined), findsOneWidget);

    final colors = <String, String>{
      'Black': 'black',
      'Red': 'red',
      'Green': 'green',
      'Yellow': 'yellow',
    };

    for (final entry in colors.entries) {
      await tester.tap(find.byIcon(Icons.palette_outlined));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is PopupMenuItem<String>),
        findsNWidgets(4),
      );
      expect(find.text(entry.key), findsOneWidget);
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      expect(notifier.state.selectedColor, entry.value);
    }

    notifier.dispose();
  });

  testWidgets('color picker remains available in text annotation mode',
      (tester) async {
    final notifier = DrawingNotifier();

    await tester.pumpWidget(
      _localizedApp(
        child: SvgDrawingToolbar(
          drawingState: DrawingState(isEnabled: true, isTextMode: true),
          drawingNotifier: notifier,
          onSave: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.palette_outlined), findsOneWidget);

    notifier.dispose();
  });

  testWidgets('annotation input preserves spaces in submitted text',
      (tester) async {
    final completed = <DrawingElement>[];

    await tester.pumpWidget(
      _localizedApp(
        child: SizedBox(
          width: 500,
          height: 300,
          child: DrawingOverlay(
            drawingState: DrawingState(isEnabled: true, isTextMode: true),
            transformationController: TransformationController(),
            onElementComplete: completed.add,
          ),
        ),
      ),
    );

    await tester.tapAt(const Offset(100, 100));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    final controller =
        tester.widget<TextField>(find.byType(TextField)).controller!;
    await tester.enterText(find.byType(TextField), 'inspection');
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(controller.text, 'inspection ');
    await tester.enterText(find.byType(TextField), 'inspection note');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(completed, hasLength(1));
    expect((completed.single.data as Map<String, dynamic>)['text'],
        'inspection note');
  });

  test('light and dark themes expose distinct surface colors', () {
    final light = AeroSlateThemes.light;
    final dark = AeroSlateThemes.dark;

    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
    expect(light.colorScheme.surface, isNot(dark.colorScheme.surface));
    expect(light.scaffoldBackgroundColor, light.colorScheme.surface);
    expect(dark.scaffoldBackgroundColor, dark.colorScheme.surface);
  });
}
