import 'package:balora_mob/shared/widgets/exit_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('showExitConfirmationDialog', () {
    testWidgets('displays title and message, returns false when canceled', (
      tester,
    ) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showExitConfirmationDialog(context);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Tap to open dialog
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify content
      expect(find.text('الخروج من التطبيق'), findsOneWidget);
      expect(
        find.text('هل أنت متأكد من رغبتك في إغلاق التطبيق؟'),
        findsOneWidget,
      );
      expect(find.text('إلغاء'), findsOneWidget);
      expect(find.text('خروج'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
      expect(find.text('الخروج من التطبيق'), findsNothing);
    });

    testWidgets('returns true when exit is confirmed', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showExitConfirmationDialog(context);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap Exit
      await tester.tap(find.text('خروج'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.text('الخروج من التطبيق'), findsNothing);
    });

    testWidgets('shows pending items warning when pendingCount > 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    showExitConfirmationDialog(context, pendingCount: 5),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(
        find.text('تنبيه: لديك 5 عناصر جرد قيد الانتظار لم تُرسل بعد.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });
  });
}
