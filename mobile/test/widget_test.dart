import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shivaay_tailor/main.dart';
import 'package:shivaay_tailor/providers/auth_provider.dart';

import 'package:shivaay_tailor/providers/language_provider.dart';
import 'package:shivaay_tailor/providers/theme_provider.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const ShivaayTailorApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);

    // Allow splash timer to complete and avoid pending timers exception
    await tester.pump(const Duration(seconds: 3));
  });
}
