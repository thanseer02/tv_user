import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Base test harness smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Base Project Ready'),
          ),
        ),
      ),
    );
    expect(find.text('Base Project Ready'), findsOneWidget);
  });
}
