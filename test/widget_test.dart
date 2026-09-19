import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aeroslate/main.dart';

void main() {
  testWidgets('Shows bootstrap loader before app is ready', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final bootstrapCompleter = Completer<void>();

    await tester.pumpWidget(
      ProviderScope(
        child: AeroSlateApp(bootstrapFuture: bootstrapCompleter.future),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
