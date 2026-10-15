import 'package:balora_mob/core/providers.dart';
import 'package:balora_mob/core/sync/queue_service.dart';
import 'package:balora_mob/features/auth/domain/auth_repository.dart';
import 'package:balora_mob/features/counts/data/count_api.dart';
import 'package:balora_mob/features/counts/domain/count_models.dart';
import 'package:balora_mob/features/counts/presentation/count_session_screen.dart';
import 'package:balora_mob/features/counts/presentation/counts_providers.dart';
import 'package:balora_mob/features/counts/presentation/counts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCountApi extends Mock implements CountApi {}

class MockQueueService extends Mock implements QueueService {}

class MockAuthRepository extends Mock implements AuthRepository {}

const _activeCount = ActiveCount(
  id: 'c1',
  locationId: 'loc-1',
  locationName: 'المخزن الرئيسي',
  note: 'جرد دوري',
  createdAt: null,
  total: 120,
  counted: 34,
);

const _snapshot = CountSnapshot(
  id: 'c1',
  locationId: 'loc-1',
  locationName: 'المخزن الرئيسي',
  note: '',
  status: 'draft',
  summary: CountSummary(total: 1, counted: 0, matched: 0, variance: 0),
  lines: [
    CountLine(
      lineId: 'l1',
      productId: 'p1',
      productName: 'أموكسيسيلين',
      batchId: 'b1',
      batchNumber: 'AMX-1',
      unitsPerPackage: 20,
      expectedQuantity: 50,
    ),
  ],
  total: 1,
);

Widget _wrap(Widget child, ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('counts screen lists the open drafts with their progress', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        activeCountsProvider.overrideWith((ref) async => [_activeCount]),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_wrap(const CountsScreen(), container));
    await tester.pumpAndSettle();

    expect(find.text('بطاقات الجرد'), findsOneWidget);
    expect(find.text('المخزن الرئيسي'), findsOneWidget);
    expect(find.text('جرد دوري'), findsOneWidget);
    expect(find.text('جُرد 34 من أصل 120 سطر'), findsOneWidget);
  });

  testWidgets('counts screen shows the honest empty state', (tester) async {
    final container = ProviderContainer(
      overrides: [activeCountsProvider.overrideWith((ref) async => [])],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_wrap(const CountsScreen(), container));
    await tester.pumpAndSettle();

    expect(find.text('لا توجد بطاقات جرد مفتوحة'), findsOneWidget);
    expect(
      find.textContaining('أنشئ بطاقة جرد من شاشة الجرد على الكمبيوتر'),
      findsOneWidget,
    );
  });

  testWidgets('session screen counts a typed barcode and shows the result', (
    tester,
  ) async {
    final api = MockCountApi();
    final queueService = MockQueueService();
    final authRepository = MockAuthRepository();
    when(() => authRepository.getDeviceId()).thenAnswer((_) async => 'dev-1');
    when(() => api.getCountSummary('c1')).thenAnswer((_) async => _snapshot);
    when(
      () => api.scan(
        commandId: any(named: 'commandId'),
        countId: 'c1',
        barcode: 'AMX-PKG',
        batchId: any(named: 'batchId'),
      ),
    ).thenAnswer(
      (_) async => const CountCommandResult(
        commandId: 'cmd-1',
        status: 'success',
        data: {
          'countId': 'c1',
          'lineId': 'l1',
          'productId': 'p1',
          'productName': 'أموكسيسيلين',
          'batchId': 'b1',
          'batchNumber': 'AMX-1',
          'unitsPerPackage': 20,
          'expectedQuantity': 50,
          'countedQuantity': 20,
          'difference': -30,
        },
      ),
    );

    final container = ProviderContainer(
      overrides: [
        countApiProvider.overrideWithValue(api),
        queueServiceProvider.overrideWithValue(queueService),
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      _wrap(const CountSessionScreen(count: _activeCount), container),
    );
    await tester.pumpAndSettle();

    expect(find.text('جرد — المخزن الرئيسي'), findsOneWidget);
    expect(find.text('أموكسيسيلين'), findsOneWidget);
    expect(find.text('لم يُجرد'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'AMX-PKG');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    verify(
      () => api.scan(
        commandId: any(named: 'commandId'),
        countId: 'c1',
        barcode: 'AMX-PKG',
        batchId: null,
      ),
    ).called(1);
    expect(find.text('عجز 30'), findsOneWidget);
    expect(find.textContaining('أموكسيسيلين'), findsWidgets);

    // Let the transient feedback timer fire so no fake timer stays pending.
    await tester.pump(const Duration(seconds: 5));
  });
}
