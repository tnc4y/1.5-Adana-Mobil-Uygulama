import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('smoke test renders text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('1.5 Adana'),
        ),
      ),
    );

    expect(find.text('1.5 Adana'), findsOneWidget);
  });
}
