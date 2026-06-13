// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bizbalance/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('BizBalance App initializes', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(BusinessMoneyManagerApp(prefs: prefs));

    // Wait for the app to initialize
    await tester.pumpAndSettle();

    // Verify that the app has loaded
    expect(find.byType(BusinessMoneyManagerApp), findsOneWidget);
  });

  testWidgets('Dashboard quick record buttons open transaction form', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(BusinessMoneyManagerApp(prefs: prefs));
    await tester.pumpAndSettle();

    final incomeButton = find.widgetWithText(ElevatedButton, 'Income');
    await tester.ensureVisible(incomeButton);
    await tester.tap(incomeButton);
    await tester.pumpAndSettle();
    expect(find.text('RECORD TRANSACTION'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    final expenseButton = find.widgetWithText(ElevatedButton, 'Expense');
    await tester.ensureVisible(expenseButton);
    await tester.tap(expenseButton);
    await tester.pumpAndSettle();
    expect(find.text('RECORD TRANSACTION'), findsOneWidget);
  });
}
