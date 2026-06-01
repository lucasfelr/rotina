// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rotina/main.dart';
import 'package:rotina/services/template_service.dart';
import 'package:rotina/services/daily_routine_service.dart';

void main() {
  testWidgets('Rotina App Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final templateService = TemplateService();
    await templateService.init();
    final dailyRoutineService = DailyRoutineService();
    await dailyRoutineService.init();
    
    await tester.pumpWidget(MyApp(
      templateService: templateService,
      dailyRoutineService: dailyRoutineService,
    ));

    // Verify that our app renders
    expect(find.text('Rotinas'), findsOneWidget);
  });
}
