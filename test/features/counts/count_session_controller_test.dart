import 'package:balora_mob/core/api/models/command.dart';
import 'package:balora_mob/core/providers.dart';
import 'package:balora_mob/core/result/result.dart';
import 'package:balora_mob/core/sync/queue_service.dart';
import 'package:balora_mob/features/auth/domain/auth_repository.dart';
import 'package:balora_mob/features/counts/data/count_api.dart';
import 'package:balora_mob/features/counts/domain/count_models.dart';
import 'package:balora_mob/features/counts/presentation/count_session_controller.dart';
import 'package:balora_mob/features/counts/presentation/count_session_state.dart';
import 'package:balora_mob/features/counts/presentation/counts_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCountApi extends Mock implements CountApi {}

class MockQueueService extends Mock implements QueueService {}

class MockAuthRepository extends Mock implements AuthRepository {}

const _snapshot = CountSnapshot(
  id: 'c1',
  locationId: 'loc-1',
  locationName: 'المخزن الرئيسي',
  note: '',
  status: 'draft',
  summary: CountSummary(total: 2, counted: 1, matched: 0, variance: 1),
  lines: [
    CountLine(
      lineId: 'l1',
      productId: 'p1',
      productName: 'أموكسيسيلين',
      batchId: 'b1',
      batchNumber: 'AMX-1',
      unitsPerPackage: 20,
      expectedQuantity: 50,
      countedQuantity: 45,
      difference: -5,
    ),
    CountLine(
      lineId: 'l2',
      productId: 'p2',
      productName: 'إيبوبروفين',
      unitsPerPackage: 1,
      expectedQuantity: 10,
    ),
  ],
  total: 2,
);

CountCommandResult _scanSuccess({
  required String commandId,
  int counted = 20,
}) {
  return CountCommandResult(
    commandId: commandId,
    status: 'success',
    message: 'تم تسجيل الكمية في بطاقة الجرد.',
    data: {
      'countId': 'c1',
      'lineId': 'l1',
      'productId': 'p1',
      'productName': 'أموكسيسيلين',
      'batchId': 'b1',
      'batchNumber': 'AMX-1',
      'expiryDate': '2027-01-31',
      'unitsPerPackage': 20,
      'expectedQuantity': 50,
      'countedQuantity': counted,
      'difference': counted - 50,
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(CommandType.scan);
  });

  late MockCountApi api;
  late MockQueueService queueService;
  late MockAuthRepository authRepository;

  setUp(() {
    api = MockCountApi();
    queueService = MockQueueService();
    authRepository = MockAuthRepository();
    when(() => authRepository.getDeviceId()).thenAnswer((_) async => 'dev-1');
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        countApiProvider.overrideWithValue(api),
        queueServiceProvider.overrideWithValue(queueService),
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  CountSession notifierFor(ProviderContainer container) =>
      container.read(countSessionProvider('c1').notifier);

  CountSessionState stateFor(ProviderContainer container) =>
      container.read(countSessionProvider('c1'));

  test('refresh loads the server snapshot', () async {
    when(
      () => api.getCountSummary('c1'),
    ).thenAnswer((_) async => _snapshot);

    final container = makeContainer();
    await notifierFor(container).refresh();

    final state = stateFor(container);
    expect(state.loading, isFalse);
    expect(state.snapshot, isNotNull);
    expect(state.snapshot!.locationName, 'المخزن الرئيسي');
    expect(state.snapshot!.summary.total, 2);
  });

  test('refresh surfaces an Arabic error when the server refuses', () async {
    when(() => api.getCountSummary('c1')).thenThrow(
      const CountApiException(
        'ليست لديك صلاحية عرض بطاقات الجرد.',
        code: 'count_permission_denied',
        status: 403,
      ),
    );

    final container = makeContainer();
    await notifierFor(container).refresh();

    final state = stateFor(container);
    expect(state.loading, isFalse);
    expect(state.error, 'ليست لديك صلاحية عرض بطاقات الجرد.');
  });

  test('a successful scan updates the line and the KPI locally', () async {
    when(() => api.getCountSummary('c1')).thenAnswer((_) async => _snapshot);
    when(
      () => api.scan(
        commandId: any(named: 'commandId'),
        countId: 'c1',
        barcode: 'AMX-PKG',
        batchId: any(named: 'batchId'),
      ),
    ).thenAnswer(
      (invocation) async => _scanSuccess(
        commandId: invocation.namedArguments[#commandId] as String,
      ),
    );

    final container = makeContainer();
    final notifier = notifierFor(container);
    await notifier.refresh();
    await notifier.submitScan('AMX-PKG');

    final state = stateFor(container);
    final line = state.snapshot!.lines.firstWhere((l) => l.lineId == 'l1');
    expect(line.countedQuantity, 20);
    expect(line.difference, -30);
    expect(state.snapshot!.summary.counted, 1);
    expect(state.snapshot!.summary.variance, 1);
    expect(state.offlineQueued, isFalse);
    expect(state.feedback, contains('أموكسيسيلين'));
  });

  test('an ambiguous scan surfaces the batch picker state', () async {
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
        status: 'failure',
        message: 'هذه المادة بعدة دفعات؛ اختر الدفعة المطابقة للعلبة.',
        data: {
          'code': 'count_batch_selection_required',
          'productId': 'p1',
          'productName': 'أموكسيسيلين',
          'batches': [
            {
              'batchId': 'b1',
              'batchNumber': 'AMX-1',
              'expiryDate': '2027-01-31',
              'availableQuantity': 40,
              'countedQuantity': null,
              'expectedQuantity': 50,
            },
            {
              'batchId': 'b2',
              'batchNumber': 'AMX-2',
              'expiryDate': '2027-07-31',
              'availableQuantity': 10,
              'countedQuantity': 5,
              'expectedQuantity': 10,
            },
          ],
        },
      ),
    );

    final container = makeContainer();
    final notifier = notifierFor(container);
    await notifier.refresh();
    await notifier.submitScan('AMX-PKG');

    final selection = stateFor(container).batchSelection;
    expect(selection, isNotNull);
    expect(selection!.barcode, 'AMX-PKG');
    expect(selection.productName, 'أموكسيسيلين');
    expect(selection.options, hasLength(2));
    expect(selection.options.last.batchNumber, 'AMX-2');
  });

  test('a network failure queues the offline retry with the same commandId',
      () async {
    when(() => api.getCountSummary('c1')).thenAnswer((_) async => _snapshot);
    when(
      () => api.scan(
        commandId: any(named: 'commandId'),
        countId: 'c1',
        barcode: any(named: 'barcode'),
        batchId: any(named: 'batchId'),
      ),
    ).thenThrow(const NetworkException('down'));
    when(
      () => queueService.enqueueCommand(
        type: any(named: 'type'),
        deviceId: any(named: 'deviceId'),
        barcode: any(named: 'barcode'),
        payload: any(named: 'payload'),
        commandId: any(named: 'commandId'),
        priority: any(named: 'priority'),
      ),
    ).thenAnswer((_) async => 'queued');

    final container = makeContainer();
    final notifier = notifierFor(container);
    await notifier.refresh();
    await notifier.submitScan('AMX-UNIT');

    final scannedId =
        verify(
              () => api.scan(
                commandId: captureAny(named: 'commandId'),
                countId: 'c1',
                barcode: 'AMX-UNIT',
                batchId: any(named: 'batchId'),
              ),
            ).captured.single
            as String;
    final queued = verify(
      () => queueService.enqueueCommand(
        type: CommandType.countScan,
        deviceId: 'dev-1',
        barcode: 'AMX-UNIT',
        payload: captureAny(named: 'payload'),
        commandId: captureAny(named: 'commandId'),
        priority: any(named: 'priority'),
      ),
    ).captured;
    expect(queued[1], scannedId);
    expect((queued[0] as Map<String, dynamic>)['countId'], 'c1');

    final state = stateFor(container);
    expect(state.offlineQueued, isTrue);
    expect(state.feedback, contains('لا يوجد اتصال'));
  });

  test('an explicit batch choice resends the pending scan with the batch',
      () async {
    when(() => api.getCountSummary('c1')).thenAnswer((_) async => _snapshot);
    var scanCalls = 0;
    when(
      () => api.scan(
        commandId: any(named: 'commandId'),
        countId: 'c1',
        barcode: 'AMX-PKG',
        batchId: any(named: 'batchId'),
      ),
    ).thenAnswer((invocation) async {
      scanCalls += 1;
      final commandId = invocation.namedArguments[#commandId] as String;
      if (scanCalls == 1) {
        return const CountCommandResult(
          commandId: 'cmd-1',
          status: 'failure',
          message: 'هذه المادة بعدة دفعات؛ اختر الدفعة المطابقة للعلبة.',
          data: {
            'code': 'count_batch_selection_required',
            'productId': 'p1',
            'productName': 'أموكسيسيلين',
            'batches': [
              {
                'batchId': 'b2',
                'batchNumber': 'AMX-2',
                'availableQuantity': 10,
                'expectedQuantity': 10,
              },
            ],
          },
        );
      }
      return _scanSuccess(commandId: commandId);
    });

    final container = makeContainer();
    final notifier = notifierFor(container);
    await notifier.refresh();
    await notifier.submitScan('AMX-PKG');
    expect(stateFor(container).batchSelection, isNotNull);

    notifier.resolveBatchSelection(
      const CountBatchOption(
        batchId: 'b2',
        batchNumber: 'AMX-2',
        availableQuantity: 10,
        expectedQuantity: 10,
      ),
    );
    for (var i = 0; i < 50 && scanCalls < 2; i += 1) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }

    verify(
      () => api.scan(
        commandId: any(named: 'commandId'),
        countId: 'c1',
        barcode: 'AMX-PKG',
        batchId: 'b2',
      ),
    ).called(1);
    expect(stateFor(container).batchSelection, isNull);
  });

  test('a successful count_set updates the absolute counted quantity',
      () async {
    when(() => api.getCountSummary('c1')).thenAnswer((_) async => _snapshot);
    when(
      () => api.setQuantity(
        commandId: any(named: 'commandId'),
        countId: 'c1',
        lineId: 'l2',
        packages: 3,
        looseUnits: 2,
      ),
    ).thenAnswer(
      (_) async => const CountCommandResult(
        commandId: 'cmd-9',
        status: 'success',
        data: {
          'countId': 'c1',
          'lineId': 'l2',
          'productId': 'p2',
          'productName': 'إيبوبروفين',
          'unitsPerPackage': 1,
          'expectedQuantity': 10,
          'countedQuantity': 5,
          'difference': -5,
        },
      ),
    );

    final container = makeContainer();
    final notifier = notifierFor(container);
    await notifier.refresh();
    await notifier.submitSet(lineId: 'l2', packages: 3, looseUnits: 2);

    final line = stateFor(
      container,
    ).snapshot!.lines.firstWhere((l) => l.lineId == 'l2');
    expect(line.countedQuantity, 5);
    expect(line.difference, -5);
  });
}
