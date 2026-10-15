import 'dart:async';
import 'dart:convert';

import 'package:balora_mob/core/providers.dart';
import 'package:balora_mob/core/sync/database/app_database.dart';
import 'package:balora_mob/core/sync/queue_service.dart';
import 'package:balora_mob/features/auth/domain/auth_repository.dart';
import 'package:balora_mob/features/counts/data/count_api.dart';
import 'package:balora_mob/features/counts/domain/count_models.dart';
import 'package:balora_mob/features/counts/presentation/count_session_screen.dart';
import 'package:balora_mob/features/counts/presentation/counts_providers.dart';
import 'package:balora_mob/features/counts/presentation/counts_screen.dart';
import 'package:balora_mob/features/inventory/presentation/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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

  testWidgets('refreshes the list after returning from a count session', (
    tester,
  ) async {
    var calls = 0;
    final container = ProviderContainer(
      overrides: [
        activeCountsProvider.overrideWith((ref) async {
          calls += 1;
          return [
            ActiveCount(
              id: 'c1',
              locationId: 'loc-1',
              locationName: 'المخزن الرئيسي',
              note: 'جرد دوري',
              createdAt: null,
              total: 120,
              counted: calls == 1 ? 0 : 5,
            ),
          ];
        }),
      ],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/counts',
      routes: [
        GoRoute(path: '/counts', builder: (_, _) => const CountsScreen()),
        GoRoute(
          path: '/counts/session',
          builder: (_, _) =>
              Scaffold(appBar: AppBar(title: const Text('جلسة العدّ'))),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('جُرد 0 من أصل 120 سطر'), findsOneWidget);

    await tester.tap(find.text('المخزن الرئيسي'));
    await tester.pumpAndSettle();
    expect(find.text('جلسة العدّ'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('جُرد 5 من أصل 120 سطر'), findsOneWidget);
    expect(calls, 2);
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

  testWidgets('the offline banner follows the queue and reconciles on drain', (
    tester,
  ) async {
    final api = MockCountApi();
    final queueService = MockQueueService();
    final authRepository = MockAuthRepository();
    when(() => authRepository.getDeviceId()).thenAnswer((_) async => 'dev-1');
    when(() => api.getCountSummary('c1')).thenAnswer((_) async => _snapshot);
    final queueStream = StreamController<List<QueueItemEntry>>();
    addTearDown(queueStream.close);

    final container = ProviderContainer(
      overrides: [
        countApiProvider.overrideWithValue(api),
        queueServiceProvider.overrideWithValue(queueService),
        authRepositoryProvider.overrideWithValue(authRepository),
        pendingCountCommandsProvider.overrideWith((ref) => queueStream.stream),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      _wrap(const CountSessionScreen(count: _activeCount), container),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('بانتظار الإرسال'), findsNothing);

    final queuedItem = QueueItemEntry(
      id: 'q1',
      commandJson: jsonEncode({
        'commandId': 'q1',
        'type': 'count_scan',
        'barcode': 'AMX-PKG',
        'payload': {'countId': 'c1'},
      }),
      commandType: 'countScan',
      priority: 0,
      status: 0,
      retryCount: 0,
      maxRetries: 5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    queueStream.add([queuedItem]);
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('1 عمليات بانتظار الإرسال'), findsOneWidget);

    // Consume the initial load call so the next count only sees the reconcile.
    expect(verify(() => api.getCountSummary('c1')).callCount, greaterThan(0));

    queueStream.add([]);
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('بانتظار الإرسال'), findsNothing);
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      verify(() => api.getCountSummary('c1')).callCount,
      greaterThan(0),
      reason: 'draining the queue must reconcile the screen with the server',
    );
    await tester.pump(const Duration(seconds: 5));
  });
}
