import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maid_attendance/core/ux4g/ux4g.dart';

void main() {
  group('Ux4gSpinner & Loader Standard Tests', () {
    testWidgets('renders Ux4gSpinner with default size and semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Ux4gSpinner(),
          ),
        ),
      );

      expect(find.byType(Ux4gSpinner), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.bySemanticsLabel('प्रतीक्षा करें... लोड हो रहा है (Loading...)'), findsOneWidget);
    });

    testWidgets('renders all standard UX4G size constructors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Ux4gSpinner.small(),
                Ux4gSpinner.medium(),
                Ux4gSpinner.large(),
                Ux4gSpinner.extraLarge(),
              ],
            ),
          ),
        ),
      );

      final spinners = tester.widgetList<Ux4gSpinner>(find.byType(Ux4gSpinner)).toList();
      expect(spinners.length, 4);
      expect(spinners[0].size, 16);
      expect(spinners[0].strokeWidth, 2.0);

      expect(spinners[1].size, 24);
      expect(spinners[1].strokeWidth, 2.5);

      expect(spinners[2].size, 36);
      expect(spinners[2].strokeWidth, 3.2);

      expect(spinners[3].size, 48);
      expect(spinners[3].strokeWidth, 4.0);
    });

    testWidgets('renders Ux4gLoadingIndicator with bilingual message', (tester) async {
      const testMsg = 'मासिक उपस्थिति लोड हो रहा है...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Ux4gLoadingIndicator(
              size: 32,
              message: testMsg,
            ),
          ),
        ),
      );

      expect(find.byType(Ux4gLoadingIndicator), findsOneWidget);
      expect(find.byType(Ux4gSpinner), findsOneWidget);
      expect(find.text(testMsg), findsOneWidget);
    });

    testWidgets('Ux4gLoader alias works as drop-in replacement for Ux4gSpinner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Ux4gLoader(size: 28),
          ),
        ),
      );

      expect(find.byType(Ux4gSpinner), findsOneWidget);
    });
  });
}
