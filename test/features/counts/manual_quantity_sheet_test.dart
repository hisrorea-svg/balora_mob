import 'package:balora_mob/features/counts/domain/count_models.dart';
import 'package:balora_mob/features/counts/presentation/widgets/manual_quantity_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _lineSingle = CountLine(
  lineId: 'l1',
  productId: 'p1',
  productName: 'مادة علبتها وحدة',
  unitsPerPackage: 1,
  expectedQuantity: 3,
  countedQuantity: 3,
  difference: 0,
);

const _linePackages = CountLine(
  lineId: 'l2',
  productId: 'p2',
  productName: 'مادة بعدة وحدات',
  unitsPerPackage: 10,
  expectedQuantity: 25,
  countedQuantity: 12,
  difference: -13,
);

Future<void> openSheet(WidgetTester tester, CountLine line) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet<ManualQuantity>(
                  context: context,
                  builder: (_) => ManualQuantitySheet(line: line),
                );
              },
              child: const Text('فتح'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('فتح'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('one quantity field when the package equals one unit', (
    tester,
  ) async {
    await openSheet(tester, _lineSingle);

    expect(find.text('الكمية (وحدة)'), findsOneWidget);
    expect(find.text('علب'), findsNothing);
    expect(find.text('وحدات مفردة'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '3',
    );
  });

  testWidgets('packages and loose units for multi-unit packages', (
    tester,
  ) async {
    await openSheet(tester, _linePackages);

    expect(find.text('علب'), findsOneWidget);
    expect(find.text('وحدات مفردة'), findsOneWidget);
    expect(find.text('الكمية (وحدة)'), findsNothing);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('saving the single field returns packages with zero units', (
    tester,
  ) async {
    ManualQuantity? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  captured = await showModalBottomSheet<ManualQuantity>(
                    context: context,
                    builder: (_) =>
                        const ManualQuantitySheet(line: _lineSingle),
                  );
                },
                child: const Text('فتح'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('فتح'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '7');
    await tester.tap(find.text('حفظ الكمية'));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.packages, 7);
    expect(captured!.looseUnits, 0);
  });
}
